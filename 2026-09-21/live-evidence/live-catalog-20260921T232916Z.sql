WITH target AS (
  SELECT c.oid, n.nspname, c.relname, c.relowner, c.relacl,
         c.relrowsecurity, c.relforcerowsecurity
  FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
  WHERE (n.nspname='public' AND c.relname IN (
    'ClientAssetGrant','CoachMediaAsset','CoachPackageContent',
    'DripResolverMarker','DunningAttempt','MuxProcessedEvent','NudgeLog',
    'PaymentRecoveryToken','PayoutMethod','PurchaseFanout','ScheduledDrop',
    'UserAIQuota','coach_ltv_peak','recent_auth_nonce'
  )) OR c.oid IN (
    SELECT inhrelid FROM pg_inherits
    WHERE inhparent='public.community_messages'::regclass
  )
)
SELECT jsonb_build_object(
  'observed_at',clock_timestamp(),
  'connector_session_role',current_user,
  'server_version',current_setting('server_version'),
  'roles',(
    SELECT jsonb_agg(jsonb_build_object(
      'name',rolname,'superuser',rolsuper,'bypassrls',rolbypassrls,
      'inherit',rolinherit,'login',rolcanlogin
    ) ORDER BY rolname)
    FROM pg_roles
    WHERE rolname IN (
      'postgres','service_role','authenticator','anon','authenticated','supabase_admin'
    )
  ),
  'relations',(
    SELECT jsonb_agg(jsonb_build_object(
      'schema',nspname,'name',relname,'owner',pg_get_userbyid(relowner),
      'rls',relrowsecurity,'force_rls',relforcerowsecurity,'acl',relacl::text,
      'anon_truncate',has_table_privilege('anon',oid,'TRUNCATE'),
      'authenticated_truncate',has_table_privilege('authenticated',oid,'TRUNCATE')
    ) ORDER BY nspname,relname) FROM target
  ),
  'functions',(
    SELECT jsonb_agg(jsonb_build_object(
      'schema',n.nspname,'name',p.proname,
      'arguments',pg_get_function_identity_arguments(p.oid),
      'owner',pg_get_userbyid(p.proowner),'security_definer',p.prosecdef
    ) ORDER BY n.nspname,p.proname)
    FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE (n.nspname='public' AND p.proname IN (
      'community_messages_create_month_partition','community_messages_protect_partition'
    )) OR (n.nspname='app' AND p.proname IN (
      'is_community_workspace_coach','is_community_workspace_member','shares_community_cohort'
    ))
  ),
  'partitions',(
    SELECT jsonb_agg(jsonb_build_object(
      'schema',n.nspname,'name',c.relname,
      'parent_schema',pn.nspname,'parent_name',pc.relname
    ) ORDER BY n.nspname,c.relname)
    FROM pg_inherits i
    JOIN pg_class c ON c.oid=i.inhrelid
    JOIN pg_namespace n ON n.oid=c.relnamespace
    JOIN pg_class pc ON pc.oid=i.inhparent
    JOIN pg_namespace pn ON pn.oid=pc.relnamespace
    WHERE i.inhparent='public.community_messages'::regclass
  )
) AS evidence;
