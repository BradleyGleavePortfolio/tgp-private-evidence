--
-- PostgreSQL database dump
--



SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: app; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA app;


--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA auth;


--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: AIDraftStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."AIDraftStatus" AS ENUM (
    'DRAFT',
    'APPROVED',
    'REJECTED',
    'EXPIRED'
);


--
-- Name: AIDraftType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."AIDraftType" AS ENUM (
    'WORKOUT_PROGRAM',
    'MEAL_PLAN',
    'INSIGHT'
);


--
-- Name: ActivityLevel; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."ActivityLevel" AS ENUM (
    'sedentary',
    'light',
    'moderate',
    'active',
    'very_active'
);


--
-- Name: ApplicationStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."ApplicationStatus" AS ENUM (
    'submitted',
    'screening',
    'shortlisted',
    'offered',
    'placed',
    'rejected',
    'withdrawn'
);


--
-- Name: CalendarProvider; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."CalendarProvider" AS ENUM (
    'stub',
    'google_calendar'
);


--
-- Name: CheckInType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."CheckInType" AS ENUM (
    'morning',
    'evening'
);


--
-- Name: CoachCompensationType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."CoachCompensationType" AS ENUM (
    'commission',
    'rev_share',
    'flat',
    'hybrid'
);


--
-- Name: CoachOfferStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."CoachOfferStatus" AS ENUM (
    'pending',
    'accepted',
    'rejected',
    'withdrawn'
);


--
-- Name: CoachPracticeType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."CoachPracticeType" AS ENUM (
    'fitness_only',
    'finance_only',
    'both'
);


--
-- Name: CoachTier; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."CoachTier" AS ENUM (
    'free',
    'pro',
    'enterprise'
);


--
-- Name: CommunityChallengeStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."CommunityChallengeStatus" AS ENUM (
    'draft',
    'active',
    'completed',
    'archived'
);


--
-- Name: CommunityClassroomPostStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."CommunityClassroomPostStatus" AS ENUM (
    'draft',
    'scheduled',
    'published',
    'archived'
);


--
-- Name: CommunityCohortStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."CommunityCohortStatus" AS ENUM (
    'draft',
    'active',
    'archived'
);


--
-- Name: CommunityEventRsvpStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."CommunityEventRsvpStatus" AS ENUM (
    'going',
    'maybe',
    'declined',
    'attended',
    'missed'
);


--
-- Name: CommunityEventState; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."CommunityEventState" AS ENUM (
    'scheduled',
    'tomorrow',
    'live',
    'replay',
    'reflected'
);


--
-- Name: CommunityMembershipRole; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."CommunityMembershipRole" AS ENUM (
    'coach',
    'assistant',
    'student'
);


--
-- Name: CommunityMembershipStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."CommunityMembershipStatus" AS ENUM (
    'invited',
    'active',
    'muted',
    'removed'
);


--
-- Name: CommunityMessageKind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."CommunityMessageKind" AS ENUM (
    'text',
    'voice',
    'system'
);


--
-- Name: CommunityMessageScope; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."CommunityMessageScope" AS ENUM (
    'cohort',
    'dm'
);


--
-- Name: CommunityModerationStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."CommunityModerationStatus" AS ENUM (
    'open',
    'reviewed',
    'actioned',
    'dismissed'
);


--
-- Name: CommunityModerationTargetType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."CommunityModerationTargetType" AS ENUM (
    'message',
    'post',
    'reaction',
    'event',
    'challenge',
    'member'
);


--
-- Name: CommunityPostScope; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."CommunityPostScope" AS ENUM (
    'hall',
    'cohort'
);


--
-- Name: CommunityPostType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."CommunityPostType" AS ENUM (
    'text',
    'lesson',
    'replay',
    'poll',
    'win'
);


--
-- Name: CommunityResponseTargetType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."CommunityResponseTargetType" AS ENUM (
    'message',
    'post',
    'comment',
    'event',
    'challenge'
);


--
-- Name: CommunitySearchKind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."CommunitySearchKind" AS ENUM (
    'post',
    'classroom_lesson',
    'voice_note_transcript',
    'event'
);


--
-- Name: ContractEnvelopeStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."ContractEnvelopeStatus" AS ENUM (
    'DRAFT',
    'SENT',
    'VIEWED',
    'SIGNED',
    'DECLINED',
    'EXPIRED'
);


--
-- Name: CrmProvider; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."CrmProvider" AS ENUM (
    'hubspot',
    'gohighlevel',
    'mailchimp',
    'activecampaign',
    'webhook'
);


--
-- Name: CrmSyncStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."CrmSyncStatus" AS ENUM (
    'pending',
    'synced',
    'failed',
    'skipped',
    'syncing'
);


--
-- Name: DataExportStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."DataExportStatus" AS ENUM (
    'PENDING',
    'RUNNING',
    'READY',
    'EXPIRED',
    'FAILED'
);


--
-- Name: ExerciseVideoStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."ExerciseVideoStatus" AS ENUM (
    'none',
    'uploading',
    'processing',
    'ready',
    'errored'
);


--
-- Name: FoodCategory; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."FoodCategory" AS ENUM (
    'generic',
    'packaged',
    'fast_food',
    'restaurant',
    'recipe_ingredient'
);


--
-- Name: GoalType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."GoalType" AS ENUM (
    'fat_loss',
    'muscle_gain',
    'maintenance',
    'performance'
);


--
-- Name: Intensity; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."Intensity" AS ENUM (
    'light',
    'moderate',
    'hard',
    'max'
);


--
-- Name: JobListingStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."JobListingStatus" AS ENUM (
    'draft',
    'published',
    'closed'
);


--
-- Name: LandingCtaType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."LandingCtaType" AS ENUM (
    'checkout',
    'lead_form',
    'book_call'
);


--
-- Name: LandingPageStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."LandingPageStatus" AS ENUM (
    'draft',
    'published',
    'archived'
);


--
-- Name: LandingPageTemplate; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."LandingPageTemplate" AS ENUM (
    'transformation',
    'authority',
    'community',
    'offer'
);


--
-- Name: LandingSectionKind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."LandingSectionKind" AS ENUM (
    'hero',
    'before_after',
    'testimonials',
    'pricing',
    'faq',
    'lead_form',
    'offer_stack',
    'guarantee',
    'problem_solution',
    'mechanism',
    'trust'
);


--
-- Name: MealType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."MealType" AS ENUM (
    'breakfast',
    'lunch',
    'dinner',
    'snack'
);


--
-- Name: MuscleGroup; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."MuscleGroup" AS ENUM (
    'chest',
    'back',
    'legs',
    'shoulders',
    'arms',
    'core',
    'cardio',
    'full_body'
);


--
-- Name: NutrientBasis; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."NutrientBasis" AS ENUM (
    'PER_100G',
    'PER_SERVING'
);


--
-- Name: PayoutMethodKind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."PayoutMethodKind" AS ENUM (
    'STRIPE_EXPRESS',
    'STRIPE_CONNECT_CUSTOM_BANK',
    'STRIPE_TREASURY'
);


--
-- Name: PayoutMethodStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."PayoutMethodStatus" AS ENUM (
    'PENDING_VERIFICATION',
    'VERIFIED',
    'DISABLED'
);


--
-- Name: PersonState; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."PersonState" AS ENUM (
    'InvitePending',
    'Invited',
    'Claimed',
    'Suspended',
    'Deleted'
);


--
-- Name: PtmOutcomeType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."PtmOutcomeType" AS ENUM (
    'churned',
    'completed_90day',
    'upgraded',
    'referred',
    'milestone_hit',
    'dropped_off',
    'renewed'
);


--
-- Name: PtmPredictionBasis; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."PtmPredictionBasis" AS ENUM (
    'heuristic_v1',
    'weighted_v2',
    'model_v3'
);


--
-- Name: PtmSignalType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."PtmSignalType" AS ENUM (
    'checkin_streak',
    'checkin_miss',
    'weight_logged',
    'weight_skipped',
    'message_sent',
    'message_received',
    'coach_note_received',
    'workout_logged',
    'workout_skipped',
    'meal_logged',
    'meal_skipped',
    'finance_eod',
    'finance_milestone',
    'app_open',
    'consistency_low',
    'streak_dropped'
);


--
-- Name: Role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."Role" AS ENUM (
    'coach',
    'student',
    'owner',
    'sub_coach'
);


--
-- Name: RomanMessageRole; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."RomanMessageRole" AS ENUM (
    'user',
    'roman'
);


--
-- Name: RomanSurface; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."RomanSurface" AS ENUM (
    'client',
    'coach'
);


--
-- Name: SessionParticipantRole; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."SessionParticipantRole" AS ENUM (
    'coach',
    'client',
    'admin',
    'assistant_coach'
);


--
-- Name: SessionStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."SessionStatus" AS ENUM (
    'requested',
    'scheduled',
    'declined',
    'canceled',
    'no_show',
    'completed',
    'pending_provider'
);


--
-- Name: Sex; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."Sex" AS ENUM (
    'male',
    'female',
    'prefer_not_to_say'
);


--
-- Name: SubscriptionStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."SubscriptionStatus" AS ENUM (
    'active',
    'trialing',
    'past_due',
    'canceled',
    'paused'
);


--
-- Name: TeamAuditEventKind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."TeamAuditEventKind" AS ENUM (
    'session_held',
    'message_sent',
    'plan_assigned',
    'checkin_logged',
    'macro_target_set',
    'meal_plan_assigned',
    'workout_assigned',
    'client_progress_logged',
    'sub_coach_assigned',
    'sub_coach_removed',
    'client_reassigned',
    'invite_sent_by_sub_coach',
    'tier_changed',
    'staff_seat_added',
    'staff_seat_removed',
    'revenue_sharing_changed'
);


--
-- Name: VideoProvider; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."VideoProvider" AS ENUM (
    'stub',
    'google_meet',
    'zoom',
    'manual'
);


--
-- Name: WearableMetricBucket; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."WearableMetricBucket" AS ENUM (
    'HEALTH_FITNESS',
    'SLEEP_RECOVERY'
);


--
-- Name: WearableMetricType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."WearableMetricType" AS ENUM (
    'STEPS',
    'ACTIVE_ENERGY_KCAL',
    'RESTING_HEART_RATE_BPM',
    'HEART_RATE_BPM',
    'VO2_MAX',
    'WORKOUT_DURATION_MIN',
    'WORKOUT_DISTANCE_M',
    'TRAINING_LOAD',
    'BODY_WEIGHT_KG',
    'BODY_FAT_PCT',
    'BLOOD_PRESSURE_SYS',
    'BLOOD_PRESSURE_DIA',
    'SLEEP_TOTAL_MIN',
    'SLEEP_REM_MIN',
    'SLEEP_DEEP_MIN',
    'SLEEP_LIGHT_MIN',
    'SLEEP_AWAKE_MIN',
    'SLEEP_EFFICIENCY_PCT',
    'HRV_MS',
    'RECOVERY_SCORE',
    'READINESS_SCORE',
    'STRAIN_SCORE',
    'BODY_BATTERY',
    'BODY_TEMP_DEVIATION_C',
    'RESPIRATORY_RATE_BRPM',
    'SPO2_PCT',
    'SLEEP_DURATION_MIN',
    'SLEEP_ONSET_ISO',
    'SLEEP_WAKE_ISO'
);


--
-- Name: WearableProvider; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."WearableProvider" AS ENUM (
    'APPLE_HEALTHKIT',
    'HEALTH_CONNECT',
    'GARMIN',
    'FITBIT',
    'STRAVA',
    'POLAR',
    'SAMSUNG_HEALTH',
    'WAHOO',
    'WITHINGS',
    'PELOTON',
    'MYFITNESSPAL',
    'OURA',
    'WHOOP',
    'EIGHT_SLEEP',
    'BEDDIT'
);


--
-- Name: WorkoutExperience; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."WorkoutExperience" AS ENUM (
    'beginner',
    'intermediate',
    'advanced'
);


--
-- Name: WorkoutPlanType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."WorkoutPlanType" AS ENUM (
    'strength',
    'cardio',
    'mobility'
);


--
-- Name: current_user_id(); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.current_user_id() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  SELECT NULLIF(current_setting('app.current_user_id', true), '')
$$;


--
-- Name: FUNCTION current_user_id(); Type: COMMENT; Schema: app; Owner: -
--

COMMENT ON FUNCTION app.current_user_id() IS 'Returns the NestJS-authenticated User.id stored in app.current_user_id for RLS policies; NULL means unauthenticated/no tenant context.';


--
-- Name: current_user_role(); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.current_user_role() RETURNS text
    LANGUAGE sql STABLE
    SET search_path TO ''
    AS $$
  SELECT NULLIF(pg_catalog.current_setting('app.current_user_role', true), '')
$$;


--
-- Name: FUNCTION current_user_role(); Type: COMMENT; Schema: app; Owner: -
--

COMMENT ON FUNCTION app.current_user_role() IS 'Returns the NestJS-authenticated role stored in app.current_user_role for RLS policies; NULL means unauthenticated/no role context.';


--
-- Name: is_community_workspace_coach(uuid); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.is_community_workspace_coach(p_workspace_id uuid) RETURNS boolean
    LANGUAGE sql STABLE
    SET search_path TO ''
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM public."community_workspaces" w
    WHERE w."id" = p_workspace_id
      AND w."coach_id"::text = app.current_user_id()
  )
$$;


--
-- Name: FUNCTION is_community_workspace_coach(p_workspace_id uuid); Type: COMMENT; Schema: app; Owner: -
--

COMMENT ON FUNCTION app.is_community_workspace_coach(p_workspace_id uuid) IS 'Caller owns the community workspace. search_path pinned to '''' (S1-DB-01).';


--
-- Name: is_community_workspace_member(uuid); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.is_community_workspace_member(p_workspace_id uuid) RETURNS boolean
    LANGUAGE sql STABLE
    SET search_path TO ''
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM public."community_memberships" m
    WHERE m."workspace_id" = p_workspace_id
      AND m."user_id"::text = app.current_user_id()
      AND m."status" <> 'removed'
  )
$$;


--
-- Name: FUNCTION is_community_workspace_member(p_workspace_id uuid); Type: COMMENT; Schema: app; Owner: -
--

COMMENT ON FUNCTION app.is_community_workspace_member(p_workspace_id uuid) IS 'Caller holds a non-removed membership in the workspace. search_path pinned to '''' (S1-DB-01).';


--
-- Name: is_current_coach_of(text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.is_current_coach_of(client_user_id text) RETURNS boolean
    LANGUAGE sql STABLE
    SET search_path TO ''
    AS $$
  SELECT app.current_user_id() IS NOT NULL
     AND app.is_user_coached_by(client_user_id, app.current_user_id())
$$;


--
-- Name: FUNCTION is_current_coach_of(client_user_id text); Type: COMMENT; Schema: app; Owner: -
--

COMMENT ON FUNCTION app.is_current_coach_of(client_user_id text) IS 'True when app.current_user_id() is the current coach of the supplied client User.id.';


--
-- Name: is_owner(); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.is_owner() RETURNS boolean
    LANGUAGE sql STABLE
    SET search_path TO ''
    AS $$
  SELECT app.current_user_id() IS NOT NULL AND app.current_user_role() = 'owner'
$$;


--
-- Name: FUNCTION is_owner(); Type: COMMENT; Schema: app; Owner: -
--

COMMENT ON FUNCTION app.is_owner() IS 'True when the RLS context identifies an authenticated owner user.';


--
-- Name: is_subcoach_of(text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.is_subcoach_of(client_user_id text) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
  SELECT client_user_id IS NOT NULL
     AND app.current_user_id() IS NOT NULL
     AND EXISTS (
       SELECT 1
       FROM public."SubCoachAssignment" sca
       WHERE sca."sub_coach_id" = app.current_user_id()
         AND sca."client_id" = client_user_id
         AND sca."unassigned_at" IS NULL
     )
$$;


--
-- Name: FUNCTION is_subcoach_of(client_user_id text); Type: COMMENT; Schema: app; Owner: -
--

COMMENT ON FUNCTION app.is_subcoach_of(client_user_id text) IS 'Security-definer RLS helper: true when app.current_user_id() has an open SubCoachAssignment (unassigned_at IS NULL) to the supplied client User.id. Mirrors SubCoachScopeService sub-coach scope.';


--
-- Name: is_subcoach_on_coach_team(text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.is_subcoach_on_coach_team(head_coach_user_id text) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
  SELECT head_coach_user_id IS NOT NULL
     AND app.current_user_id() IS NOT NULL
     AND EXISTS (
       SELECT 1
       FROM public."User" u
       WHERE u."id" = app.current_user_id()
         AND u."role" = 'coach'
         AND u."coach_id" = head_coach_user_id
     )
$$;


--
-- Name: FUNCTION is_subcoach_on_coach_team(head_coach_user_id text); Type: COMMENT; Schema: app; Owner: -
--

COMMENT ON FUNCTION app.is_subcoach_on_coach_team(head_coach_user_id text) IS 'Security-definer RLS helper: true when app.current_user_id() is a sub-coach (role=coach with a non-null coach_id) on the supplied head coach''s team.';


--
-- Name: is_user_coached_by(text, text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.is_user_coached_by(client_user_id text, coach_user_id text) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
  SELECT client_user_id IS NOT NULL
     AND coach_user_id IS NOT NULL
     AND EXISTS (
       SELECT 1
       FROM public."User" u
       WHERE u."id" = client_user_id
         AND u."coach_id" = coach_user_id
         AND u."role" = 'student'
     )
$$;


--
-- Name: FUNCTION is_user_coached_by(client_user_id text, coach_user_id text); Type: COMMENT; Schema: app; Owner: -
--

COMMENT ON FUNCTION app.is_user_coached_by(client_user_id text, coach_user_id text) IS 'Security-definer helper for RLS policies: true when the first User.id is a student currently assigned to the second User.id coach.';


--
-- Name: mark_message_read(text); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.mark_message_read(p_message_id text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public'
    AS $$
DECLARE
  v_caller text;
BEGIN
  -- Resolve the authenticated caller from the session config var.
  -- app.current_user_id() returns NULL if the session is unauthenticated;
  -- the IS NOT NULL check below makes this function a no-op for anon callers.
  v_caller := app.current_user_id();

  IF v_caller IS NULL THEN
    RAISE EXCEPTION 'mark_message_read: unauthenticated caller'
      USING ERRCODE = 'insufficient_privilege';
  END IF;

  -- Only update the row if the caller is the recipient.
  -- If p_message_id does not exist or the caller is not the recipient,
  -- the UPDATE simply affects 0 rows — no error is raised, which avoids
  -- leaking message-existence information to non-parties.
  UPDATE "Message"
     SET read    = true,
         read_at = NOW()
   WHERE id           = p_message_id
     AND recipient_id = v_caller
     AND read         = false;  -- idempotent: skip already-read rows
END;
$$;


--
-- Name: shares_community_cohort(uuid); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.shares_community_cohort(p_cohort_id uuid) RETURNS boolean
    LANGUAGE sql STABLE
    SET search_path TO ''
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM public."community_memberships" m
    WHERE m."cohort_id" = p_cohort_id
      AND m."user_id"::text = app.current_user_id()
      AND m."status" <> 'removed'
  )
$$;


--
-- Name: FUNCTION shares_community_cohort(p_cohort_id uuid); Type: COMMENT; Schema: app; Owner: -
--

COMMENT ON FUNCTION app.shares_community_cohort(p_cohort_id uuid) IS 'Caller shares the cohort via a non-removed membership. search_path pinned to '''' (S1-DB-01).';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  SELECT COALESCE(NULLIF(current_setting('request.jwt.claims', true), '')::jsonb, '{}'::jsonb)
$$;


--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  SELECT NULLIF(current_setting('request.jwt.claims', true)::jsonb ->> 'role', '')
$$;


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  SELECT NULLIF(current_setting('request.jwt.claims', true)::jsonb ->> 'sub', '')::uuid
$$;


--
-- Name: community_messages_create_month_partition(date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.community_messages_create_month_partition(p_month date) RETURNS text
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
DECLARE
  v_start DATE := date_trunc('month', p_month)::date;
  v_end   DATE := (date_trunc('month', p_month) + INTERVAL '1 month')::date;
  v_name  TEXT := 'community_messages_' || to_char(v_start, 'YYYY_MM');
BEGIN
  EXECUTE format(
    'CREATE TABLE IF NOT EXISTS public.%I PARTITION OF public."community_messages" FOR VALUES FROM (%L) TO (%L)',
    v_name, v_start, v_end
  );
  PERFORM public.community_messages_protect_partition(format('public.%I', v_name)::regclass);
  RETURN v_name;
END;
$$;


--
-- Name: FUNCTION community_messages_create_month_partition(p_month date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.community_messages_create_month_partition(p_month date) IS 'Idempotently provisions the monthly community_messages partition covering p_month AND protects it (RLS enabled+forced, deny-all anon/authenticated, service_role bypass, API grants revoked). search_path pinned (S1-DB-01). Parent RLS does NOT propagate to partitions on its own.';


--
-- Name: community_messages_protect_partition(regclass); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.community_messages_protect_partition(p_partition regclass) RETURNS void
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
DECLARE
  v_name text;
  v_nsp  text;
BEGIN
  SELECT c.relname, n.nspname INTO v_name, v_nsp
    FROM pg_catalog.pg_class c JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
   WHERE c.oid = p_partition;
  IF v_name IS NULL THEN
    RAISE EXCEPTION 'community_messages_protect_partition: relation % does not exist', p_partition;
  END IF;
  -- Only ever act on a real partition of public.community_messages (guards
  -- against a same-named relation in another schema or an unrelated table).
  IF v_nsp <> 'public' OR NOT EXISTS (
       SELECT 1 FROM pg_catalog.pg_inherits i
        WHERE i.inhrelid = p_partition
          AND i.inhparent = 'public.community_messages'::regclass) THEN
    RAISE EXCEPTION 'community_messages_protect_partition: % is not a partition of public.community_messages', p_partition;
  END IF;
  EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', v_name);
  EXECUTE format('ALTER TABLE public.%I FORCE ROW LEVEL SECURITY', v_name);
  EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I', 'p_' || v_name || '_service_role_all', v_name);
  EXECUTE format(
    'CREATE POLICY %I ON public.%I AS PERMISSIVE FOR ALL TO service_role USING (true) WITH CHECK (true)',
    'p_' || v_name || '_service_role_all', v_name);
  EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I', 'deny_all_anon_' || v_name, v_name);
  EXECUTE format(
    'CREATE POLICY %I ON public.%I AS RESTRICTIVE FOR ALL TO anon USING (false) WITH CHECK (false)',
    'deny_all_anon_' || v_name, v_name);
  EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I', 'deny_all_authenticated_' || v_name, v_name);
  EXECUTE format(
    'CREATE POLICY %I ON public.%I AS RESTRICTIVE FOR ALL TO authenticated USING (false) WITH CHECK (false)',
    'deny_all_authenticated_' || v_name, v_name);
  EXECUTE format('REVOKE ALL PRIVILEGES ON TABLE public.%I FROM anon, authenticated', v_name);
END
$$;


--
-- Name: FUNCTION community_messages_protect_partition(p_partition regclass); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.community_messages_protect_partition(p_partition regclass) IS 'S1-DB-01: enables+forces RLS, installs service_role/deny-all policies and revokes anon/authenticated grants on one community_messages partition. Idempotent. Called for every existing partition and by community_messages_create_month_partition().';


--
-- Name: enforce_subcoach_head_cap(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.enforce_subcoach_head_cap() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO ''
    AS $$
DECLARE
  head_count integer;
BEGIN
  IF NEW.archived_at IS NOT NULL THEN
    RETURN NEW;
  END IF;
  SELECT COUNT(*) INTO head_count
  FROM public."TeamSubCoachAssignment"
  WHERE "sub_coach_id" = NEW."sub_coach_id"
    AND "archived_at" IS NULL
    AND "id" <> NEW."id";
  IF head_count >= 2 THEN
    RAISE EXCEPTION 'sub_coach_head_cap_exceeded: sub-coach % already assigned under 2 head coaches', NEW."sub_coach_id"
      USING ERRCODE = 'check_violation';
  END IF;
  RETURN NEW;
END;
$$;


--
-- Name: FUNCTION enforce_subcoach_head_cap(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.enforce_subcoach_head_cap() IS 'BEFORE INSERT/UPDATE trigger on TeamSubCoachAssignment: caps a sub-coach at 2 non-archived head-coach assignments. search_path pinned to '''' (PR-RLS-FN).';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: AICallLog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."AICallLog" (
    id text NOT NULL,
    model text NOT NULL,
    "tokensIn" integer NOT NULL,
    "tokensOut" integer NOT NULL,
    "costCents" integer NOT NULL,
    "latencyMs" integer NOT NULL,
    success boolean NOT NULL,
    "errorMessage" text,
    "coachId" text,
    "clientId" text,
    capability text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."AICallLog" FORCE ROW LEVEL SECURITY;


--
-- Name: AIDraft; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."AIDraft" (
    id text NOT NULL,
    "coachId" text NOT NULL,
    "clientId" text NOT NULL,
    type public."AIDraftType" NOT NULL,
    "inputContext" jsonb NOT NULL,
    "modelUsed" text NOT NULL,
    "promptVersion" text NOT NULL,
    "generatedPayload" jsonb NOT NULL,
    status public."AIDraftStatus" DEFAULT 'DRAFT'::public."AIDraftStatus" NOT NULL,
    "approvedAsId" text,
    "rejectionReason" text,
    "tokensIn" integer DEFAULT 0 NOT NULL,
    "tokensOut" integer DEFAULT 0 NOT NULL,
    "costCents" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);

ALTER TABLE ONLY public."AIDraft" FORCE ROW LEVEL SECURITY;


--
-- Name: ActivityEvent; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ActivityEvent" (
    id text NOT NULL,
    actor_id text,
    actor_role text,
    coach_id text,
    client_id text,
    type text NOT NULL,
    summary text,
    payload jsonb,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."ActivityEvent" FORCE ROW LEVEL SECURITY;


--
-- Name: AiActionDraft; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."AiActionDraft" (
    id text NOT NULL,
    capability text NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    requester_id text,
    subject_user_id text,
    tenant_coach_id text,
    payload jsonb NOT NULL,
    rationale text,
    redacted_inputs jsonb,
    provenance jsonb,
    decided_by_id text,
    decided_at timestamp(3) without time zone,
    decision_note text,
    expires_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    materialised_at timestamp(3) without time zone,
    materialised_ref text
);

ALTER TABLE ONLY public."AiActionDraft" FORCE ROW LEVEL SECURITY;


--
-- Name: AiRequestAudit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."AiRequestAudit" (
    id text NOT NULL,
    request_id text NOT NULL,
    capability text NOT NULL,
    requester_id text,
    requester_role text,
    subject_user_id text,
    tenant_coach_id text,
    provider text NOT NULL,
    model text,
    enabled boolean DEFAULT false NOT NULL,
    context_source_count integer DEFAULT 0 NOT NULL,
    context_source_refs jsonb,
    redactions_applied jsonb,
    prompt_token_estimate integer,
    response_token_estimate integer,
    prompt_hash text,
    response_hash text,
    approval_status text DEFAULT 'not_required'::text NOT NULL,
    approval_draft_id text,
    error text,
    ip text,
    user_agent text,
    metadata jsonb,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."AiRequestAudit" FORCE ROW LEVEL SECURITY;


--
-- Name: AiRoadmap; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."AiRoadmap" (
    id text NOT NULL,
    submission_id text NOT NULL,
    generated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    prompt_version text DEFAULT 'v1'::text NOT NULL,
    status text DEFAULT 'ready'::text NOT NULL,
    payload jsonb,
    tokens_used integer,
    model text DEFAULT 'sonar-pro'::text NOT NULL,
    error_message text
);

ALTER TABLE ONLY public."AiRoadmap" FORCE ROW LEVEL SECURITY;


--
-- Name: Applicant; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Applicant" (
    id text NOT NULL,
    user_id text NOT NULL,
    email text NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    headline text,
    bio text,
    specialties text[],
    certifications text[],
    years_experience integer,
    sample_program_url text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);

ALTER TABLE ONLY public."Applicant" FORCE ROW LEVEL SECURITY;


--
-- Name: Application; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Application" (
    id text NOT NULL,
    listing_id text NOT NULL,
    applicant_id text NOT NULL,
    applicant_user_id text NOT NULL,
    hirer_id text NOT NULL,
    cover_note text,
    fit_score integer,
    status public."ApplicationStatus" DEFAULT 'submitted'::public."ApplicationStatus" NOT NULL,
    idempotency_key text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);

ALTER TABLE ONLY public."Application" FORCE ROW LEVEL SECURITY;


--
-- Name: AuditLog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."AuditLog" (
    id text NOT NULL,
    action text NOT NULL,
    actor_id text,
    actor_role text,
    actor_email_snapshot text,
    target_user_id text,
    target_type text,
    target_id text,
    tenant_coach_id text,
    ip text,
    user_agent text,
    metadata jsonb,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."AuditLog" FORCE ROW LEVEL SECURITY;


--
-- Name: BloodworkAttachment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."BloodworkAttachment" (
    id text NOT NULL,
    panel_id text NOT NULL,
    storage_ref text,
    storage_backend text,
    content_type text,
    byte_size integer,
    scan_status text DEFAULT 'pending_scan'::text NOT NULL,
    scan_message text,
    scanned_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."BloodworkAttachment" FORCE ROW LEVEL SECURITY;


--
-- Name: BloodworkPanel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."BloodworkPanel" (
    id text NOT NULL,
    client_id text NOT NULL,
    coach_id text,
    collection_date timestamp(3) without time zone NOT NULL,
    source text DEFAULT 'manual_entry'::text NOT NULL,
    panel_label text,
    notes text,
    review_state text DEFAULT 'draft'::text NOT NULL,
    reviewed_by_id text,
    reviewed_at timestamp(3) without time zone,
    review_note text,
    disclaimer_level text DEFAULT 'educational_only'::text NOT NULL,
    validation_status text DEFAULT 'ok'::text NOT NULL,
    is_stale boolean DEFAULT false NOT NULL,
    stale_marked_at timestamp(3) without time zone,
    source_missing boolean DEFAULT false NOT NULL,
    ai_processing_allowed boolean DEFAULT false NOT NULL,
    encryption_key_ref text,
    kms_key_version text,
    submitted_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    encrypted_notes text,
    encrypted_review_note text
);

ALTER TABLE ONLY public."BloodworkPanel" FORCE ROW LEVEL SECURITY;


--
-- Name: BloodworkResult; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."BloodworkResult" (
    id text NOT NULL,
    panel_id text NOT NULL,
    marker_name text NOT NULL,
    marker_code text,
    value_numeric numeric(20,6),
    value_text text,
    unit text,
    reference_low numeric(20,6),
    reference_high numeric(20,6),
    reference_text text,
    out_of_range boolean DEFAULT false NOT NULL,
    validation_status text DEFAULT 'ok'::text NOT NULL,
    validation_message text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."BloodworkResult" FORCE ROW LEVEL SECURITY;


--
-- Name: BuildWeekDay; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."BuildWeekDay" (
    id text NOT NULL,
    day_number integer NOT NULL,
    title text NOT NULL,
    focus_area text NOT NULL,
    narrative text NOT NULL,
    prompt_questions jsonb NOT NULL,
    action_items jsonb NOT NULL,
    expected_artifact text NOT NULL
);

ALTER TABLE ONLY public."BuildWeekDay" FORCE ROW LEVEL SECURITY;


--
-- Name: BuildWeekDayCompletion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."BuildWeekDayCompletion" (
    id text NOT NULL,
    enrollment_id text NOT NULL,
    day_number integer NOT NULL,
    completed_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    responses jsonb NOT NULL,
    artifact_text text
);

ALTER TABLE ONLY public."BuildWeekDayCompletion" FORCE ROW LEVEL SECURITY;


--
-- Name: BuildWeekEnrollment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."BuildWeekEnrollment" (
    id text NOT NULL,
    user_id text NOT NULL,
    started_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    current_day integer DEFAULT 1 NOT NULL,
    status text DEFAULT 'active'::text NOT NULL,
    completed_at timestamp(3) without time zone
);

ALTER TABLE ONLY public."BuildWeekEnrollment" FORCE ROW LEVEL SECURITY;


--
-- Name: CalendarConnection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CalendarConnection" (
    id text NOT NULL,
    user_id text NOT NULL,
    provider public."CalendarProvider" NOT NULL,
    external_account_id text,
    credentials_secret_ref text,
    last_synced_at timestamp(3) without time zone,
    disconnected_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    encrypted_refresh_token text,
    channel_id text,
    resource_id text,
    channel_expires_at timestamp(3) without time zone
);

ALTER TABLE ONLY public."CalendarConnection" FORCE ROW LEVEL SECURITY;


--
-- Name: ChargeDispute; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChargeDispute" (
    id text NOT NULL,
    purchase_id text NOT NULL,
    stripe_dispute_id text NOT NULL,
    stripe_charge_id text NOT NULL,
    amount_cents integer NOT NULL,
    currency text DEFAULT 'usd'::text NOT NULL,
    status text DEFAULT 'needs_response'::text NOT NULL,
    reason text,
    evidence_due_by timestamp(3) without time zone,
    evidence_submitted_at timestamp(3) without time zone,
    ledger_reversed boolean DEFAULT false NOT NULL,
    closed_at timestamp(3) without time zone,
    balance_transaction_id text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);

ALTER TABLE ONLY public."ChargeDispute" FORCE ROW LEVEL SECURITY;


--
-- Name: ChargeRefund; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChargeRefund" (
    id text NOT NULL,
    purchase_id text NOT NULL,
    stripe_refund_id text NOT NULL,
    stripe_charge_id text NOT NULL,
    amount_cents integer NOT NULL,
    currency text DEFAULT 'usd'::text NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    reason text,
    note text,
    initiated_by_user_id text,
    failure_reason text,
    ledger_reversed boolean DEFAULT false NOT NULL,
    transfer_reversed boolean DEFAULT false NOT NULL,
    posted_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);

ALTER TABLE ONLY public."ChargeRefund" FORCE ROW LEVEL SECURITY;


--
-- Name: CheckIn; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CheckIn" (
    id text NOT NULL,
    user_id text NOT NULL,
    date date NOT NULL,
    mood integer,
    energy integer,
    soreness integer NOT NULL,
    notes text,
    type public."CheckInType" DEFAULT 'morning'::public."CheckInType" NOT NULL,
    logged_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    coach_id text,
    sleep_hours double precision,
    weight_kg double precision,
    reviewed_by_coach boolean DEFAULT false NOT NULL,
    coach_reviewed_at timestamp(3) without time zone
);

ALTER TABLE ONLY public."CheckIn" FORCE ROW LEVEL SECURITY;


--
-- Name: ChurnIntervention; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChurnIntervention" (
    id text NOT NULL,
    coach_id text NOT NULL,
    client_id text NOT NULL,
    draft_text text NOT NULL,
    edited_text text,
    status text DEFAULT 'draft'::text NOT NULL,
    alert_id text,
    risk_score_at_draft double precision,
    top_factor text,
    idempotency_key text NOT NULL,
    send_idempotency_key text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    sent_at timestamp(3) without time zone,
    dismissed_at timestamp(3) without time zone,
    nudge_id text
);

ALTER TABLE ONLY public."ChurnIntervention" FORCE ROW LEVEL SECURITY;


--
-- Name: ClientAssetGrant; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ClientAssetGrant" (
    id text NOT NULL,
    client_id text NOT NULL,
    media_asset_id text NOT NULL,
    granted_via_drop_id text,
    granted_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    revoked_at timestamp(3) without time zone
);

ALTER TABLE ONLY public."ClientAssetGrant" FORCE ROW LEVEL SECURITY;


--
-- Name: ClientCoachConsent; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ClientCoachConsent" (
    id text NOT NULL,
    client_id text NOT NULL,
    coach_id text NOT NULL,
    scope text NOT NULL,
    granted_at timestamp(3) without time zone,
    revoked_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."ClientCoachConsent" FORCE ROW LEVEL SECURITY;


--
-- Name: ClientOutcome; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ClientOutcome" (
    id text NOT NULL,
    user_id text NOT NULL,
    outcome_type public."PtmOutcomeType" NOT NULL,
    labelled_by_id text,
    labelled_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    notes text,
    signal_snapshot jsonb
);

ALTER TABLE ONLY public."ClientOutcome" FORCE ROW LEVEL SECURITY;


--
-- Name: ClientPurchase; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ClientPurchase" (
    id text NOT NULL,
    client_user_id text NOT NULL,
    coach_user_id text NOT NULL,
    package_id text NOT NULL,
    amount_cents integer NOT NULL,
    currency text DEFAULT 'usd'::text NOT NULL,
    billing_type text DEFAULT 'one_time'::text NOT NULL,
    stripe_checkout_session_id text NOT NULL,
    stripe_payment_intent_id text,
    stripe_subscription_id text,
    stripe_customer_id text,
    stripe_destination_account text,
    status text DEFAULT 'pending'::text NOT NULL,
    entitlement_active boolean DEFAULT false NOT NULL,
    access_expires_at timestamp(3) without time zone,
    current_period_end timestamp(3) without time zone,
    cancel_at_period_end boolean DEFAULT false NOT NULL,
    canceled_at timestamp(3) without time zone,
    idempotency_key text NOT NULL,
    last_error text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    stripe_client_secret text,
    stripe_ephemeral_key text,
    landing_page_id text,
    contract_envelope_id text
);

ALTER TABLE ONLY public."ClientPurchase" FORCE ROW LEVEL SECURITY;


--
-- Name: COLUMN "ClientPurchase".stripe_client_secret; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."ClientPurchase".stripe_client_secret IS 'Phase 7 PaymentIntent dedup — cached PaymentIntent client_secret. Null on the Checkout-session (web redirect) path.';


--
-- Name: COLUMN "ClientPurchase".stripe_ephemeral_key; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."ClientPurchase".stripe_ephemeral_key IS 'Phase 7 PaymentIntent dedup — cached Stripe EphemeralKey secret. Null on the Checkout-session (web redirect) path.';


--
-- Name: ClientSignal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ClientSignal" (
    id text NOT NULL,
    user_id text NOT NULL,
    signal_type public."PtmSignalType" NOT NULL,
    value double precision DEFAULT 0 NOT NULL,
    metadata jsonb,
    recorded_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."ClientSignal" FORCE ROW LEVEL SECURITY;


--
-- Name: ClientWorkoutAssignment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ClientWorkoutAssignment" (
    id text NOT NULL,
    workout_plan_id text NOT NULL,
    client_id text NOT NULL,
    assigned_by_coach_id text NOT NULL,
    scheduled_for timestamp(3) without time zone NOT NULL,
    completed_at timestamp(3) without time zone,
    post_rpe integer,
    post_notes text,
    completion_idempotency_key text,
    started_at timestamp(3) without time zone,
    completion_payload jsonb,
    approved_by_coach_at timestamp(3) without time zone,
    idempotency_key text,
    ai_draft_id text
);

ALTER TABLE ONLY public."ClientWorkoutAssignment" FORCE ROW LEVEL SECURITY;


--
-- Name: ClientWorkoutAssignmentSnapshot; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ClientWorkoutAssignmentSnapshot" (
    id text NOT NULL,
    assignment_id text NOT NULL,
    plan_name text NOT NULL,
    plan_type public."WorkoutPlanType" NOT NULL,
    exercises_json jsonb NOT NULL,
    source_plan_id text NOT NULL,
    source_version integer NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."ClientWorkoutAssignmentSnapshot" FORCE ROW LEVEL SECURITY;


--
-- Name: CoachAIBudget; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CoachAIBudget" (
    id text NOT NULL,
    coach_user_id text NOT NULL,
    period_start timestamp(3) without time zone NOT NULL,
    period_end timestamp(3) without time zone NOT NULL,
    base_actual_cents integer DEFAULT 4000 NOT NULL,
    value_multiplier numeric(6,3) DEFAULT 3.125 NOT NULL,
    base_displayed_cents integer DEFAULT 12500 NOT NULL,
    pack_paid_cents integer DEFAULT 0 NOT NULL,
    pack_displayed_cents integer DEFAULT 0 NOT NULL,
    actual_used_cents integer DEFAULT 0 NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    last_rollover_at timestamp(3) without time zone,
    total_pack_actual_cents integer DEFAULT 0 NOT NULL,
    CONSTRAINT "CoachAIBudget_actual_used_nonneg" CHECK ((actual_used_cents >= 0)),
    CONSTRAINT "CoachAIBudget_base_actual_nonneg" CHECK ((base_actual_cents >= 0)),
    CONSTRAINT "CoachAIBudget_pack_paid_nonneg" CHECK ((pack_paid_cents >= 0)),
    CONSTRAINT "CoachAIBudget_period_bounds" CHECK ((period_end > period_start)),
    CONSTRAINT "CoachAIBudget_total_pack_actual_nonneg" CHECK ((total_pack_actual_cents >= 0))
);

ALTER TABLE ONLY public."CoachAIBudget" FORCE ROW LEVEL SECURITY;


--
-- Name: CoachAlert; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CoachAlert" (
    id text NOT NULL,
    coach_id text NOT NULL,
    client_id text NOT NULL,
    alert_type text NOT NULL,
    severity text DEFAULT 'warning'::text NOT NULL,
    message text NOT NULL,
    payload jsonb,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    acknowledged_at timestamp(3) without time zone
);

ALTER TABLE ONLY public."CoachAlert" FORCE ROW LEVEL SECURITY;


--
-- Name: CoachAvailability; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CoachAvailability" (
    id text NOT NULL,
    coach_id text NOT NULL,
    day_of_week integer NOT NULL,
    start_minute integer NOT NULL,
    end_minute integer NOT NULL,
    session_type_id text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."CoachAvailability" FORCE ROW LEVEL SECURITY;


--
-- Name: CoachAvailabilityOverride; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CoachAvailabilityOverride" (
    id text NOT NULL,
    coach_id text NOT NULL,
    date date NOT NULL,
    start_minute integer,
    end_minute integer,
    kind text NOT NULL,
    note text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT "CoachAvailabilityOverride_kind_check" CHECK ((kind = ANY (ARRAY['holiday'::text, 'block'::text, 'extra'::text]))),
    CONSTRAINT "CoachAvailabilityOverride_window_check" CHECK ((((start_minute IS NULL) AND (end_minute IS NULL)) OR ((start_minute IS NOT NULL) AND (end_minute IS NOT NULL) AND (start_minute >= 0) AND (end_minute <= 1440) AND (start_minute < end_minute))))
);

ALTER TABLE ONLY public."CoachAvailabilityOverride" FORCE ROW LEVEL SECURITY;


--
-- Name: CoachBrief; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CoachBrief" (
    id text NOT NULL,
    coach_id text NOT NULL,
    brief_date text NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    generated_at timestamp(3) without time zone,
    narrative text,
    brief_context jsonb,
    action_items jsonb,
    generated_by text,
    brief_mode text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    read_at timestamp(3) without time zone,
    generation_started_at timestamp(3) without time zone,
    CONSTRAINT "CoachBrief_brief_date_format_check" CHECK (((brief_date ~ '^\d{4}-\d{2}-\d{2}$'::text) AND (to_char((to_date(brief_date, 'YYYY-MM-DD'::text))::timestamp with time zone, 'YYYY-MM-DD'::text) = brief_date))),
    CONSTRAINT "CoachBrief_brief_mode_check" CHECK (((brief_mode IS NULL) OR (brief_mode = ANY (ARRAY['solo_coach'::text, 'head_coach'::text, 'sub_coach'::text])))),
    CONSTRAINT "CoachBrief_claim_before_generated_check" CHECK (((generated_at IS NULL) OR (generation_started_at IS NULL) OR (generated_at >= generation_started_at))),
    CONSTRAINT "CoachBrief_generated_by_check" CHECK (((generated_by IS NULL) OR (generated_by = ANY (ARRAY['ai'::text, 'fallback'::text])))),
    CONSTRAINT "CoachBrief_narrative_length_check" CHECK (((narrative IS NULL) OR (char_length(narrative) <= 600))),
    CONSTRAINT "CoachBrief_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'generating'::text, 'generated'::text, 'failed'::text])))
);

ALTER TABLE ONLY public."CoachBrief" FORCE ROW LEVEL SECURITY;


--
-- Name: CoachBriefPreferences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CoachBriefPreferences" (
    id text NOT NULL,
    coach_id text NOT NULL,
    notification_time text DEFAULT '05:00'::text NOT NULL,
    timezone text DEFAULT 'America/Los_Angeles'::text NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT "CoachBriefPreferences_notification_time_check" CHECK ((notification_time ~ '^([01]\d|2[0-3]):[0-5]\d$'::text)),
    CONSTRAINT "CoachBriefPreferences_timezone_format_check" CHECK ((timezone ~ '^[A-Za-z0-9_+\-/]+$'::text)),
    CONSTRAINT "CoachBriefPreferences_timezone_length_check" CHECK (((char_length(timezone) >= 1) AND (char_length(timezone) <= 80)))
);

ALTER TABLE ONLY public."CoachBriefPreferences" FORCE ROW LEVEL SECURITY;


--
-- Name: CoachBriefPushLedger; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CoachBriefPushLedger" (
    id text NOT NULL,
    coach_id text NOT NULL,
    last_push_attempt_date text,
    last_push_date text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    push_attempt_lease_until timestamp(3) without time zone,
    push_attempts_today integer DEFAULT 0 NOT NULL
);

ALTER TABLE ONLY public."CoachBriefPushLedger" FORCE ROW LEVEL SECURITY;


--
-- Name: CoachCreditPackPurchase; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CoachCreditPackPurchase" (
    id text NOT NULL,
    coach_user_id text NOT NULL,
    budget_id text NOT NULL,
    stripe_checkout_session_id text,
    stripe_invoice_id text,
    stripe_payment_intent_id text,
    paid_cents integer NOT NULL,
    actual_credit_cents integer NOT NULL,
    displayed_credit_cents integer NOT NULL,
    status text NOT NULL,
    applied_at timestamp(3) without time zone,
    refunded_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    is_free_grant boolean DEFAULT false NOT NULL,
    CONSTRAINT "CCPP_actual_credit_nonneg" CHECK ((actual_credit_cents >= 0)),
    CONSTRAINT "CCPP_displayed_credit_ge_paid" CHECK ((displayed_credit_cents >= paid_cents)),
    CONSTRAINT "CCPP_free_grant_paid_zero" CHECK ((((is_free_grant = true) AND (paid_cents = 0)) OR ((is_free_grant = false) AND (paid_cents >= 0)))),
    CONSTRAINT "CCPP_paid_nonneg" CHECK ((paid_cents >= 0)),
    CONSTRAINT "CCPP_status_valid" CHECK ((status = ANY (ARRAY['pending'::text, 'paid'::text, 'refunded'::text, 'failed'::text])))
);

ALTER TABLE ONLY public."CoachCreditPackPurchase" FORCE ROW LEVEL SECURITY;


--
-- Name: CoachCrmIntegration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CoachCrmIntegration" (
    id text NOT NULL,
    coach_id text NOT NULL,
    provider public."CrmProvider" NOT NULL,
    credentials_encrypted text NOT NULL,
    field_mapping jsonb DEFAULT '{}'::jsonb NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    last_synced_at timestamp(3) without time zone,
    last_error text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."CoachCrmIntegration" FORCE ROW LEVEL SECURITY;


--
-- Name: CoachDailyLog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CoachDailyLog" (
    id text NOT NULL,
    coach_id text NOT NULL,
    log_date text NOT NULL,
    content text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT "CoachDailyLog_content_length_check" CHECK ((char_length(content) <= 4000)),
    CONSTRAINT "CoachDailyLog_log_date_format_check" CHECK (((log_date ~ '^\d{4}-\d{2}-\d{2}$'::text) AND (to_char((to_date(log_date, 'YYYY-MM-DD'::text))::timestamp with time zone, 'YYYY-MM-DD'::text) = log_date)))
);

ALTER TABLE ONLY public."CoachDailyLog" FORCE ROW LEVEL SECURITY;


--
-- Name: CoachEffectivenessScore; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CoachEffectivenessScore" (
    id text NOT NULL,
    coach_id text NOT NULL,
    score double precision NOT NULL,
    bucket text NOT NULL,
    factors jsonb,
    basis text DEFAULT 'v1'::text NOT NULL,
    computed_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."CoachEffectivenessScore" FORCE ROW LEVEL SECURITY;


--
-- Name: CoachGuideline; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CoachGuideline" (
    id text NOT NULL,
    coach_id text,
    client_id text,
    content text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);

ALTER TABLE ONLY public."CoachGuideline" FORCE ROW LEVEL SECURITY;


--
-- Name: CoachLandingLead; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CoachLandingLead" (
    id text NOT NULL,
    page_id text NOT NULL,
    coach_id text NOT NULL,
    email text NOT NULL,
    name text,
    phone text,
    payload jsonb DEFAULT '{}'::jsonb NOT NULL,
    crm_sync_status public."CrmSyncStatus" DEFAULT 'pending'::public."CrmSyncStatus" NOT NULL,
    crm_synced_at timestamp(3) without time zone,
    crm_error text,
    converted_user_id text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    synced_to text[] DEFAULT ARRAY[]::text[] NOT NULL,
    external_ids jsonb DEFAULT '{}'::jsonb NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    next_eligible_at timestamp with time zone
);

ALTER TABLE ONLY public."CoachLandingLead" FORCE ROW LEVEL SECURITY;


--
-- Name: CoachLandingPage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CoachLandingPage" (
    id text NOT NULL,
    coach_id text NOT NULL,
    slug text NOT NULL,
    template public."LandingPageTemplate" NOT NULL,
    status public."LandingPageStatus" DEFAULT 'draft'::public."LandingPageStatus" NOT NULL,
    headline character varying(120) NOT NULL,
    subheadline character varying(280),
    hero_image_url text,
    accent_color text,
    primary_cta_type public."LandingCtaType" NOT NULL,
    primary_cta_label character varying(40) NOT NULL,
    package_ids text[] DEFAULT '{}'::text[] NOT NULL,
    lead_capture_fields text[] DEFAULT '{}'::text[] NOT NULL,
    crm_integration_id text,
    custom_domain text,
    custom_domain_verified_at timestamp(3) without time zone,
    published_at timestamp(3) without time zone,
    unpublished_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."CoachLandingPage" FORCE ROW LEVEL SECURITY;


--
-- Name: CoachLandingPageSection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CoachLandingPageSection" (
    id text NOT NULL,
    page_id text NOT NULL,
    kind public."LandingSectionKind" NOT NULL,
    order_index integer NOT NULL,
    payload jsonb DEFAULT '{}'::jsonb NOT NULL
);

ALTER TABLE ONLY public."CoachLandingPageSection" FORCE ROW LEVEL SECURITY;


--
-- Name: CoachLandingPageView; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CoachLandingPageView" (
    id text NOT NULL,
    page_id text NOT NULL,
    ip_hash text NOT NULL,
    ua_hash text NOT NULL,
    referrer_host text,
    utm_source text,
    utm_medium text,
    utm_campaign text,
    scroll_depth integer,
    cta_clicked boolean DEFAULT false NOT NULL,
    form_submitted boolean DEFAULT false NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."CoachLandingPageView" FORCE ROW LEVEL SECURITY;


--
-- Name: CoachMediaAsset; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CoachMediaAsset" (
    id text NOT NULL,
    coach_id text NOT NULL,
    kind text NOT NULL,
    title text NOT NULL,
    description text,
    storage_key text NOT NULL,
    provider text NOT NULL,
    byte_size bigint,
    content_type text,
    duration_sec integer,
    page_count integer,
    mux_playback_id text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    archived_at timestamp(3) without time zone,
    status text DEFAULT 'ready'::text NOT NULL,
    mux_upload_id text,
    mux_error_message text
);

ALTER TABLE ONLY public."CoachMediaAsset" FORCE ROW LEVEL SECURITY;


--
-- Name: CoachMessage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CoachMessage" (
    id text NOT NULL,
    coach_id text,
    client_id text,
    sender_id text,
    body text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    read_at timestamp(3) without time zone,
    voice_url text,
    voice_duration_sec integer,
    voice_size_bytes integer,
    voice_content_type text,
    ai_draft_id text
);

ALTER TABLE ONLY public."CoachMessage" FORCE ROW LEVEL SECURITY;


--
-- Name: CoachNudge; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CoachNudge" (
    id text NOT NULL,
    coach_id text,
    client_id text,
    title text NOT NULL,
    body text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    read_at timestamp(3) without time zone
);

ALTER TABLE ONLY public."CoachNudge" FORCE ROW LEVEL SECURITY;


--
-- Name: CoachOffer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CoachOffer" (
    id text NOT NULL,
    head_coach_id text NOT NULL,
    application_id text NOT NULL,
    applicant_user_id text NOT NULL,
    compensation_type public."CoachCompensationType" NOT NULL,
    compensation_terms jsonb NOT NULL,
    client_capacity integer NOT NULL,
    onboarding_message text,
    status public."CoachOfferStatus" DEFAULT 'pending'::public."CoachOfferStatus" NOT NULL,
    accepted_at timestamp(3) without time zone,
    idempotency_key text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);

ALTER TABLE ONLY public."CoachOffer" FORCE ROW LEVEL SECURITY;


--
-- Name: CoachOnboardingProgress; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CoachOnboardingProgress" (
    id text NOT NULL,
    coach_id text NOT NULL,
    started_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    completed_at timestamp(3) without time zone,
    current_step integer DEFAULT 1 NOT NULL,
    step_data jsonb
);

ALTER TABLE ONLY public."CoachOnboardingProgress" FORCE ROW LEVEL SECURITY;


--
-- Name: CoachPackage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CoachPackage" (
    id text NOT NULL,
    coach_id text NOT NULL,
    name text NOT NULL,
    description text,
    amount_cents integer NOT NULL,
    currency text DEFAULT 'usd'::text NOT NULL,
    billing_type text DEFAULT 'one_time'::text NOT NULL,
    "interval" text,
    interval_count integer DEFAULT 1 NOT NULL,
    duration_periods integer,
    stripe_price_id text,
    stripe_product_id text,
    is_active boolean DEFAULT true NOT NULL,
    archived_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    share_token text,
    share_link_enabled boolean DEFAULT true NOT NULL,
    share_link_generated_at timestamp(3) without time zone,
    share_link_expires_at timestamp(3) without time zone,
    share_link_revoked_at timestamp(3) without time zone,
    is_sellable boolean DEFAULT false NOT NULL,
    published_at timestamp(3) without time zone,
    recurring_amount_cents integer,
    recurring_interval text,
    recurring_interval_count integer,
    recurring_stripe_price_id text,
    requires_contract boolean DEFAULT false NOT NULL,
    contract_template_id text
);

ALTER TABLE ONLY public."CoachPackage" FORCE ROW LEVEL SECURITY;


--
-- Name: CoachPackageContent; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CoachPackageContent" (
    id text NOT NULL,
    package_id text NOT NULL,
    asset_type text NOT NULL,
    asset_id text NOT NULL,
    asset_revision_id text,
    display_order integer DEFAULT 0 NOT NULL,
    cadence_kind text DEFAULT 'immediate'::text NOT NULL,
    cadence_payload jsonb NOT NULL,
    display_title text,
    display_caption text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    removed_at timestamp(3) without time zone
);

ALTER TABLE ONLY public."CoachPackageContent" FORCE ROW LEVEL SECURITY;


--
-- Name: CoachProfile; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CoachProfile" (
    id text NOT NULL,
    user_id text NOT NULL,
    business_name text,
    bio text,
    timezone text,
    branding_accent_color text,
    branding_logo_url text,
    invite_code text NOT NULL,
    stripe_customer_id text,
    stripe_subscription_id text,
    subscription_status public."SubscriptionStatus",
    plan_tier text DEFAULT 'flat_300'::text NOT NULL,
    current_period_end timestamp(3) without time zone,
    trial_end timestamp(3) without time zone,
    ai_monthly_spend_cap_cents integer DEFAULT 5000 NOT NULL,
    created_by_owner_id text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."CoachProfile" FORCE ROW LEVEL SECURITY;


--
-- Name: CoachSubscription; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CoachSubscription" (
    id text NOT NULL,
    coach_id text NOT NULL,
    stripe_customer_id text,
    stripe_subscription_id text,
    stripe_price_id text,
    status text DEFAULT 'incomplete'::text NOT NULL,
    current_period_end timestamp(3) without time zone,
    trial_end timestamp(3) without time zone,
    cancel_at_period_end boolean DEFAULT false NOT NULL,
    last_payment_failed_at timestamp(3) without time zone,
    failed_payments_this_month integer DEFAULT 0 NOT NULL,
    billing_email text,
    card_last4 text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    tier public."CoachTier" DEFAULT 'free'::public."CoachTier" NOT NULL
);

ALTER TABLE ONLY public."CoachSubscription" FORCE ROW LEVEL SECURITY;


--
-- Name: CoachingSession; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CoachingSession" (
    id text NOT NULL,
    coach_id text NOT NULL,
    client_id text,
    session_type_id text,
    status public."SessionStatus" DEFAULT 'requested'::public."SessionStatus" NOT NULL,
    start_at timestamp(3) without time zone NOT NULL,
    end_at timestamp(3) without time zone NOT NULL,
    title text NOT NULL,
    coach_notes_md text,
    client_recap_md text,
    video_provider public."VideoProvider" DEFAULT 'stub'::public."VideoProvider" NOT NULL,
    video_url text,
    video_meeting_id text,
    calendar_provider public."CalendarProvider" DEFAULT 'stub'::public."CalendarProvider" NOT NULL,
    calendar_event_id text,
    provider_idempotency_key text,
    approved_at timestamp(3) without time zone,
    ended_at timestamp(3) without time zone,
    end_reason text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."CoachingSession" FORCE ROW LEVEL SECURITY;


--
-- Name: CommunityWin; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CommunityWin" (
    id text NOT NULL,
    user_id text NOT NULL,
    coach_id text,
    title text NOT NULL,
    description text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    visibility text DEFAULT 'circle'::text NOT NULL
);

ALTER TABLE ONLY public."CommunityWin" FORCE ROW LEVEL SECURITY;


--
-- Name: ConnectAccount; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ConnectAccount" (
    id text NOT NULL,
    coach_user_id text NOT NULL,
    stripe_account_id text NOT NULL,
    country text DEFAULT 'US'::text NOT NULL,
    default_currency text DEFAULT 'usd'::text NOT NULL,
    charges_enabled boolean DEFAULT false NOT NULL,
    payouts_enabled boolean DEFAULT false NOT NULL,
    details_submitted boolean DEFAULT false NOT NULL,
    requirements_due jsonb,
    disabled_reason text,
    deauthorized_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: ConnectCustomer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ConnectCustomer" (
    id text NOT NULL,
    client_user_id text NOT NULL,
    stripe_customer_id text NOT NULL,
    default_payment_method_id text,
    default_card_brand text,
    default_card_last4 text,
    default_card_exp_month integer,
    default_card_exp_year integer,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);

ALTER TABLE ONLY public."ConnectCustomer" FORCE ROW LEVEL SECURITY;


--
-- Name: ConnectTransfer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ConnectTransfer" (
    id text NOT NULL,
    purchase_id text NOT NULL,
    ledger_entry_id text,
    destination_stripe_account_id text NOT NULL,
    destination_user_id text,
    amount_cents integer NOT NULL,
    currency text DEFAULT 'usd'::text NOT NULL,
    source_stripe_charge_id text,
    stripe_transfer_id text,
    status text DEFAULT 'pending'::text NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    max_attempts integer DEFAULT 6 NOT NULL,
    next_attempt_at timestamp(3) without time zone,
    last_attempt_at timestamp(3) without time zone,
    last_error text,
    idempotency_key text NOT NULL,
    posted_at timestamp(3) without time zone,
    reversed_at timestamp(3) without time zone,
    reversed_amount_cents integer DEFAULT 0 NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);

ALTER TABLE ONLY public."ConnectTransfer" FORCE ROW LEVEL SECURITY;


--
-- Name: ContractAuditEvent; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ContractAuditEvent" (
    id text NOT NULL,
    envelope_id text NOT NULL,
    actor_id text,
    action text NOT NULL,
    ip text,
    user_agent text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."ContractAuditEvent" FORCE ROW LEVEL SECURITY;


--
-- Name: ContractEnvelope; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ContractEnvelope" (
    id text NOT NULL,
    template_id text NOT NULL,
    template_version integer NOT NULL,
    client_id text NOT NULL,
    coach_id text NOT NULL,
    purchase_id text,
    status public."ContractEnvelopeStatus" DEFAULT 'DRAFT'::public."ContractEnvelopeStatus" NOT NULL,
    hellosign_request_id text,
    signed_pdf_url text,
    ip text,
    user_agent text,
    signed_at timestamp(3) without time zone,
    expires_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."ContractEnvelope" FORCE ROW LEVEL SECURITY;


--
-- Name: ContractTemplate; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ContractTemplate" (
    id text NOT NULL,
    coach_id text NOT NULL,
    is_platform boolean DEFAULT false NOT NULL,
    name text NOT NULL,
    body_markdown text NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    dynamic_fields_json jsonb NOT NULL,
    requires_signature boolean DEFAULT true NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."ContractTemplate" FORCE ROW LEVEL SECURITY;


--
-- Name: ConversationReview; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ConversationReview" (
    id text NOT NULL,
    coach_id text NOT NULL,
    client_id text NOT NULL,
    coach_reviewed_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);

ALTER TABLE ONLY public."ConversationReview" FORCE ROW LEVEL SECURITY;


--
-- Name: DailyMealPlan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."DailyMealPlan" (
    id text NOT NULL,
    coach_id text NOT NULL,
    name text NOT NULL,
    notes text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    archived_at timestamp(3) without time zone
);

ALTER TABLE ONLY public."DailyMealPlan" FORCE ROW LEVEL SECURITY;


--
-- Name: DailyMealPlanAssignment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."DailyMealPlanAssignment" (
    id text NOT NULL,
    daily_meal_plan_id text NOT NULL,
    client_id text NOT NULL,
    assigned_by_coach_id text NOT NULL,
    starts_on date NOT NULL,
    ends_on date,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ai_draft_id text,
    drip_drop_id text
);

ALTER TABLE ONLY public."DailyMealPlanAssignment" FORCE ROW LEVEL SECURITY;


--
-- Name: DailyMealPlanSlot; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."DailyMealPlanSlot" (
    id text NOT NULL,
    daily_meal_plan_id text NOT NULL,
    meal_template_id text NOT NULL,
    slot_label text NOT NULL,
    "order" integer DEFAULT 0 NOT NULL
);

ALTER TABLE ONLY public."DailyMealPlanSlot" FORCE ROW LEVEL SECURITY;


--
-- Name: DataExportRequest; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."DataExportRequest" (
    id text NOT NULL,
    user_id text NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    payload jsonb,
    error text,
    requested_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fulfilled_at timestamp(3) without time zone,
    delivered_at timestamp(3) without time zone
);

ALTER TABLE ONLY public."DataExportRequest" FORCE ROW LEVEL SECURITY;


--
-- Name: DiagnosticSubmission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."DiagnosticSubmission" (
    id text NOT NULL,
    email text NOT NULL,
    name text,
    age integer,
    source text,
    answers jsonb NOT NULL,
    scores jsonb NOT NULL,
    bucket jsonb NOT NULL,
    submitted_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    user_id text,
    ip text,
    user_agent text
);

ALTER TABLE ONLY public."DiagnosticSubmission" FORCE ROW LEVEL SECURITY;


--
-- Name: DripResolverMarker; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."DripResolverMarker" (
    id text NOT NULL,
    purpose text NOT NULL,
    purchase_id text NOT NULL,
    content_id text NOT NULL,
    materialised_ref text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);

ALTER TABLE ONLY public."DripResolverMarker" FORCE ROW LEVEL SECURITY;


--
-- Name: DunningAttempt; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."DunningAttempt" (
    id text NOT NULL,
    dunning_state_id text NOT NULL,
    step_index integer NOT NULL,
    kind text NOT NULL,
    scheduled_for timestamp(3) without time zone NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    sent_at timestamp(3) without time zone,
    email_idempotency_key text,
    provider_message_id text,
    failure_reason text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    retry_count integer DEFAULT 0 NOT NULL,
    next_retry_at timestamp(3) without time zone,
    superseded_at timestamp(3) without time zone
);

ALTER TABLE ONLY public."DunningAttempt" FORCE ROW LEVEL SECURITY;


--
-- Name: DunningState; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."DunningState" (
    id text NOT NULL,
    purchase_id text NOT NULL,
    status text DEFAULT 'active'::text NOT NULL,
    failure_count integer DEFAULT 0 NOT NULL,
    last_attempt_number integer,
    last_failed_amount_cents integer,
    last_failure_at timestamp(3) without time zone,
    last_failure_reason text,
    grace_period_ends_at timestamp(3) without time zone,
    cancel_scheduled_at timestamp(3) without time zone,
    resolved_at timestamp(3) without time zone,
    abandoned_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    step_index integer DEFAULT '-1'::integer NOT NULL,
    next_attempt_at timestamp(3) without time zone,
    entered_at timestamp(3) without time zone,
    recovered_at timestamp(3) without time zone,
    escalated_at timestamp(3) without time zone,
    locked_out_at timestamp(3) without time zone,
    reversal_count integer DEFAULT 0 NOT NULL
);

ALTER TABLE ONLY public."DunningState" FORCE ROW LEVEL SECURITY;


--
-- Name: EmailSendLog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."EmailSendLog" (
    id text NOT NULL,
    idempotency_key text NOT NULL,
    template_key text NOT NULL,
    recipient_email text NOT NULL,
    status text DEFAULT 'sending'::text NOT NULL,
    provider_message_id text,
    error text,
    sent_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."EmailSendLog" FORCE ROW LEVEL SECURITY;


--
-- Name: ExerciseCatalogItem; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ExerciseCatalogItem" (
    id text NOT NULL,
    slug text NOT NULL,
    name text NOT NULL,
    category text NOT NULL,
    primary_muscle text NOT NULL,
    secondary_muscles text[] DEFAULT ARRAY[]::text[] NOT NULL,
    equipment text[] DEFAULT ARRAY[]::text[] NOT NULL,
    difficulty text DEFAULT 'beginner'::text NOT NULL,
    instructions text[] DEFAULT ARRAY[]::text[] NOT NULL,
    source_ref text,
    mux_asset_id text,
    mux_playback_id text,
    mux_playback_policy text DEFAULT 'public'::text NOT NULL,
    mux_asset_status public."ExerciseVideoStatus" DEFAULT 'none'::public."ExerciseVideoStatus" NOT NULL,
    mux_duration_seconds double precision,
    mux_error_message text,
    mux_upload_id text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    video_url text,
    video_provider text
);

ALTER TABLE ONLY public."ExerciseCatalogItem" FORCE ROW LEVEL SECURITY;


--
-- Name: ExerciseSet; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ExerciseSet" (
    id text NOT NULL,
    workout_id text NOT NULL,
    exercise_name text NOT NULL,
    muscle_group public."MuscleGroup" NOT NULL,
    sets_completed integer NOT NULL,
    reps_per_set integer[],
    weight_per_set double precision[],
    rpe double precision,
    notes text,
    video_url text
);

ALTER TABLE ONLY public."ExerciseSet" FORCE ROW LEVEL SECURITY;


--
-- Name: ExtensionPairCode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ExtensionPairCode" (
    id text NOT NULL,
    code text NOT NULL,
    coach_id text NOT NULL,
    chosen_platform text NOT NULL,
    expires_at timestamp(3) without time zone NOT NULL,
    used_at timestamp(3) without time zone,
    failed_attempts integer DEFAULT 0 NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."ExtensionPairCode" FORCE ROW LEVEL SECURITY;


--
-- Name: FastingWindow; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."FastingWindow" (
    id text NOT NULL,
    user_id text NOT NULL,
    start_time timestamp(3) without time zone NOT NULL,
    end_time timestamp(3) without time zone,
    protocol text,
    notes text
);

ALTER TABLE ONLY public."FastingWindow" FORCE ROW LEVEL SECURITY;


--
-- Name: FeePolicy; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."FeePolicy" (
    id text NOT NULL,
    coach_id text NOT NULL,
    platform_application_fee_bps integer,
    head_coach_split_bps integer,
    notes text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);

ALTER TABLE ONLY public."FeePolicy" FORCE ROW LEVEL SECURITY;


--
-- Name: FoodItem; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."FoodItem" (
    id text NOT NULL,
    name text NOT NULL,
    brand_or_restaurant text,
    category public."FoodCategory" DEFAULT 'generic'::public."FoodCategory" NOT NULL,
    serving_description text NOT NULL,
    serving_size_grams double precision NOT NULL,
    calories double precision NOT NULL,
    protein_g double precision NOT NULL,
    carbs_g double precision NOT NULL,
    fat_g double precision NOT NULL,
    saturated_fat_g double precision,
    mono_fat_g double precision,
    poly_fat_g double precision,
    fiber_g double precision,
    sugar_g double precision,
    sodium_mg double precision,
    tags text[],
    search_aliases text[],
    image_url text,
    barcode text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    nutrient_basis public."NutrientBasis" DEFAULT 'PER_100G'::public."NutrientBasis" NOT NULL
);

ALTER TABLE ONLY public."FoodItem" FORCE ROW LEVEL SECURITY;


--
-- Name: GuestCheckout; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."GuestCheckout" (
    id text NOT NULL,
    package_id text NOT NULL,
    stripe_payment_intent_id text NOT NULL,
    stripe_customer_id text,
    guest_email text NOT NULL,
    guest_name text NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    created_user_id text,
    idempotency_key text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    expires_at timestamp(3) without time zone NOT NULL,
    retry_count integer DEFAULT 0 NOT NULL,
    last_error text,
    last_retry_at timestamp(3) without time zone,
    data_retention_at timestamp(3) without time zone,
    scrubbed_at timestamp(3) without time zone,
    landing_page_id text,
    last_reconciled_at timestamp(3) without time zone,
    reconcile_attempts integer DEFAULT 0 NOT NULL,
    package_snapshot jsonb,
    refunded_at timestamp(3) without time zone,
    disputed_at timestamp(3) without time zone,
    dispute_reason character varying(500),
    receipt_url text,
    stripe_subscription_id text,
    CONSTRAINT "GuestCheckout_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'paid'::text, 'failed'::text, 'converted'::text, 'conversion_failed_retryable'::text, 'conversion_failed_terminal'::text, 'refunded'::text, 'disputed'::text])))
);

ALTER TABLE ONLY public."GuestCheckout" FORCE ROW LEVEL SECURITY;


--
-- Name: Habit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Habit" (
    id text NOT NULL,
    user_id text NOT NULL,
    name text NOT NULL,
    category text DEFAULT 'custom'::text NOT NULL,
    target_value double precision,
    unit text
);

ALTER TABLE ONLY public."Habit" FORCE ROW LEVEL SECURITY;


--
-- Name: HabitLog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."HabitLog" (
    id text NOT NULL,
    habit_id text NOT NULL,
    date date NOT NULL,
    value double precision,
    completed boolean DEFAULT false NOT NULL,
    logged_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."HabitLog" FORCE ROW LEVEL SECURITY;


--
-- Name: HolisticInsightCache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."HolisticInsightCache" (
    id text NOT NULL,
    user_id text NOT NULL,
    window_days integer NOT NULL,
    payload jsonb NOT NULL,
    generated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    expires_at timestamp(3) without time zone NOT NULL
);

ALTER TABLE ONLY public."HolisticInsightCache" FORCE ROW LEVEL SECURITY;


--
-- Name: InviteCode; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."InviteCode" (
    id text NOT NULL,
    code text NOT NULL,
    coach_id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    expires_at timestamp(3) without time zone,
    max_uses integer,
    used_count integer DEFAULT 0 NOT NULL,
    revoked boolean DEFAULT false NOT NULL,
    invited_by_user_id text,
    intended_email text,
    accepted_by_user_id text,
    accepted_at timestamp(3) without time zone
);

ALTER TABLE ONLY public."InviteCode" FORCE ROW LEVEL SECURITY;


--
-- Name: Invoice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Invoice" (
    id text NOT NULL,
    coach_id text NOT NULL,
    stripe_invoice_id text NOT NULL,
    stripe_customer_id text,
    amount_paid_cents integer DEFAULT 0 NOT NULL,
    amount_due_cents integer DEFAULT 0 NOT NULL,
    currency text DEFAULT 'usd'::text NOT NULL,
    status text DEFAULT 'open'::text NOT NULL,
    hosted_invoice_url text,
    invoice_pdf text,
    period_start timestamp(3) without time zone,
    period_end timestamp(3) without time zone,
    paid_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: JobListing; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."JobListing" (
    id text NOT NULL,
    hirer_id text NOT NULL,
    title text NOT NULL,
    description text NOT NULL,
    specialty text,
    location text,
    modality text,
    compensation_type public."CoachCompensationType" NOT NULL,
    compensation_terms jsonb NOT NULL,
    expectations text,
    status public."JobListingStatus" DEFAULT 'draft'::public."JobListingStatus" NOT NULL,
    published_at timestamp(3) without time zone,
    closed_at timestamp(3) without time zone,
    idempotency_key text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);

ALTER TABLE ONLY public."JobListing" FORCE ROW LEVEL SECURITY;


--
-- Name: Lesson; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Lesson" (
    id text NOT NULL,
    coach_id text NOT NULL,
    title text NOT NULL,
    description text,
    video_url text,
    article_url text,
    tags text[],
    goal_tags public."GoalType"[],
    order_index integer DEFAULT 0 NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."Lesson" FORCE ROW LEVEL SECURITY;


--
-- Name: LessonCompletion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."LessonCompletion" (
    id text NOT NULL,
    lesson_id text NOT NULL,
    user_id text NOT NULL,
    completed_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."LessonCompletion" FORCE ROW LEVEL SECURITY;


--
-- Name: LoggedFoodEntry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."LoggedFoodEntry" (
    id text NOT NULL,
    user_id text NOT NULL,
    date date NOT NULL,
    meal_type public."MealType" NOT NULL,
    food_item_id text NOT NULL,
    quantity_multiplier double precision DEFAULT 1.0 NOT NULL,
    notes text,
    logged_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    original_quantity double precision,
    original_unit text,
    client_uuid text
);

ALTER TABLE ONLY public."LoggedFoodEntry" FORCE ROW LEVEL SECURITY;


--
-- Name: MacroTarget; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."MacroTarget" (
    id text NOT NULL,
    client_id text NOT NULL,
    coach_id text NOT NULL,
    calories_kcal integer NOT NULL,
    protein_g integer NOT NULL,
    carbs_g integer NOT NULL,
    fats_g integer NOT NULL,
    fiber_g integer,
    notes text,
    effective_from timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    archived_at timestamp(3) without time zone
);

ALTER TABLE ONLY public."MacroTarget" FORCE ROW LEVEL SECURITY;


--
-- Name: MarketplaceAbuseSignal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."MarketplaceAbuseSignal" (
    id text NOT NULL,
    surface text NOT NULL,
    ip_hash text NOT NULL,
    identity_hash text NOT NULL,
    device_hash text NOT NULL,
    reason text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."MarketplaceAbuseSignal" FORCE ROW LEVEL SECURITY;


--
-- Name: MarketplaceConnectEvent; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."MarketplaceConnectEvent" (
    stripe_event_id text NOT NULL,
    type text NOT NULL,
    stripe_account_id text NOT NULL,
    coach_user_id text,
    onboarding_completed boolean DEFAULT false NOT NULL,
    processed_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."MarketplaceConnectEvent" FORCE ROW LEVEL SECURITY;


--
-- Name: MarketplaceMutationIdempotency; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."MarketplaceMutationIdempotency" (
    id text NOT NULL,
    user_id text NOT NULL,
    route_key text NOT NULL,
    idempotency_key text NOT NULL,
    response jsonb,
    status text DEFAULT 'completed'::text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    completed_at timestamp(3) without time zone,
    claim_nonce text
);

ALTER TABLE ONLY public."MarketplaceMutationIdempotency" FORCE ROW LEVEL SECURITY;


--
-- Name: MealPlan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."MealPlan" (
    id text NOT NULL,
    coach_id text,
    client_id text,
    title text NOT NULL,
    notes text,
    items jsonb NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    archived_at timestamp(3) without time zone,
    days jsonb
);

ALTER TABLE ONLY public."MealPlan" FORCE ROW LEVEL SECURITY;


--
-- Name: MealTemplate; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."MealTemplate" (
    id text NOT NULL,
    coach_id text NOT NULL,
    name text NOT NULL,
    description text,
    calories_kcal integer NOT NULL,
    protein_g integer NOT NULL,
    carbs_g integer NOT NULL,
    fats_g integer NOT NULL,
    fiber_g integer,
    items jsonb,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    archived_at timestamp(3) without time zone
);

ALTER TABLE ONLY public."MealTemplate" FORCE ROW LEVEL SECURITY;


--
-- Name: Message; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Message" (
    id text NOT NULL,
    sender_id text NOT NULL,
    recipient_id text NOT NULL,
    body text NOT NULL,
    read boolean DEFAULT false NOT NULL,
    read_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."Message" FORCE ROW LEVEL SECURITY;


--
-- Name: MessageDraft; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."MessageDraft" (
    id text NOT NULL,
    coach_id text NOT NULL,
    client_id text NOT NULL,
    body text NOT NULL,
    snippet_id text,
    updated_at timestamp(3) without time zone NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."MessageDraft" FORCE ROW LEVEL SECURITY;


--
-- Name: MessageReport; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."MessageReport" (
    id text NOT NULL,
    reporter_id text NOT NULL,
    message_id text NOT NULL,
    coach_id text,
    client_id text,
    reason text NOT NULL,
    details text,
    status text DEFAULT 'pending'::text NOT NULL,
    action text,
    reviewed_at timestamp(3) without time zone,
    reviewed_by_admin_id text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."MessageReport" FORCE ROW LEVEL SECURITY;


--
-- Name: MuxProcessedEvent; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."MuxProcessedEvent" (
    mux_event_id text NOT NULL,
    type text NOT NULL,
    processed_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    handler_completed_at timestamp(3) without time zone
);

ALTER TABLE ONLY public."MuxProcessedEvent" FORCE ROW LEVEL SECURITY;


--
-- Name: Notification; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Notification" (
    id text DEFAULT (gen_random_uuid())::text NOT NULL,
    user_id text NOT NULL,
    kind text NOT NULL,
    payload jsonb,
    body text NOT NULL,
    deep_link text,
    channel text DEFAULT 'inapp'::text NOT NULL,
    read_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT now() NOT NULL,
    ai_draft_id text
);

ALTER TABLE ONLY public."Notification" FORCE ROW LEVEL SECURITY;


--
-- Name: NotificationDeliveryLog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."NotificationDeliveryLog" (
    id text NOT NULL,
    user_id text NOT NULL,
    session_id text NOT NULL,
    kind text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."NotificationDeliveryLog" FORCE ROW LEVEL SECURITY;


--
-- Name: NotificationDigestLog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."NotificationDigestLog" (
    id text DEFAULT (gen_random_uuid())::text NOT NULL,
    user_id text NOT NULL,
    digest_kind text NOT NULL,
    window_date text NOT NULL,
    status text DEFAULT 'sending'::text NOT NULL,
    sent_at timestamp(3) without time zone,
    error text,
    created_at timestamp(3) without time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY public."NotificationDigestLog" FORCE ROW LEVEL SECURITY;


--
-- Name: NotificationPreferences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."NotificationPreferences" (
    id text NOT NULL,
    user_id text NOT NULL,
    water_enabled boolean DEFAULT true NOT NULL,
    workout_enabled boolean DEFAULT true NOT NULL,
    eat_enabled boolean DEFAULT true NOT NULL,
    mindset_enabled boolean DEFAULT true NOT NULL,
    fasting_enabled boolean DEFAULT true NOT NULL,
    quiet_hours_start text DEFAULT '22:00'::text NOT NULL,
    quiet_hours_end text DEFAULT '06:00'::text NOT NULL,
    timezone text DEFAULT 'America/Los_Angeles'::text NOT NULL,
    muted boolean DEFAULT false NOT NULL,
    milestone_email boolean DEFAULT true NOT NULL,
    milestone_push boolean DEFAULT true NOT NULL,
    milestone_inapp boolean DEFAULT true NOT NULL,
    message_email boolean DEFAULT false NOT NULL,
    message_push boolean DEFAULT true NOT NULL,
    message_inapp boolean DEFAULT true NOT NULL,
    missed_checkin_email boolean DEFAULT false NOT NULL,
    missed_checkin_push boolean DEFAULT true NOT NULL,
    missed_checkin_inapp boolean DEFAULT true NOT NULL,
    weight_trend_email boolean DEFAULT false NOT NULL,
    weight_trend_push boolean DEFAULT true NOT NULL,
    weight_trend_inapp boolean DEFAULT true NOT NULL,
    checkin_submitted_email boolean DEFAULT false NOT NULL,
    checkin_submitted_push boolean DEFAULT false NOT NULL,
    checkin_submitted_inapp boolean DEFAULT true NOT NULL,
    build_week_email boolean DEFAULT true NOT NULL,
    build_week_push boolean DEFAULT true NOT NULL,
    build_week_inapp boolean DEFAULT true NOT NULL,
    coach_alert_email boolean DEFAULT false NOT NULL,
    coach_alert_push boolean DEFAULT true NOT NULL,
    coach_alert_inapp boolean DEFAULT true NOT NULL,
    digest_email boolean DEFAULT true NOT NULL,
    digest_push boolean DEFAULT false NOT NULL,
    digest_inapp boolean DEFAULT false NOT NULL,
    booking_email boolean DEFAULT false NOT NULL,
    booking_push boolean DEFAULT true NOT NULL,
    booking_inapp boolean DEFAULT true NOT NULL,
    nudge_missed_checkin_email boolean DEFAULT false NOT NULL,
    nudge_missed_checkin_push boolean DEFAULT true NOT NULL,
    nudge_missed_checkin_inapp boolean DEFAULT true NOT NULL,
    nudge_practice_paused_email boolean DEFAULT false NOT NULL,
    nudge_practice_paused_push boolean DEFAULT true NOT NULL,
    nudge_practice_paused_inapp boolean DEFAULT true NOT NULL,
    nudge_onboarding_abandoned_email boolean DEFAULT true NOT NULL,
    nudge_onboarding_abandoned_push boolean DEFAULT true NOT NULL,
    nudge_onboarding_abandoned_inapp boolean DEFAULT true NOT NULL,
    nudge_inactive_email boolean DEFAULT true NOT NULL,
    nudge_inactive_push boolean DEFAULT true NOT NULL,
    nudge_inactive_inapp boolean DEFAULT true NOT NULL,
    drip_released_email boolean DEFAULT false NOT NULL,
    drip_released_push boolean DEFAULT true NOT NULL,
    drip_released_inapp boolean DEFAULT true NOT NULL,
    coach_new_purchase_email boolean DEFAULT false NOT NULL,
    coach_new_purchase_push boolean DEFAULT true NOT NULL,
    coach_new_purchase_inapp boolean DEFAULT true NOT NULL
);

ALTER TABLE ONLY public."NotificationPreferences" FORCE ROW LEVEL SECURITY;


--
-- Name: NudgeLog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."NudgeLog" (
    id text NOT NULL,
    user_id text NOT NULL,
    trigger_type text NOT NULL,
    signal_key text NOT NULL,
    status text NOT NULL,
    channels text[] DEFAULT ARRAY[]::text[] NOT NULL,
    attempted_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    sent_at timestamp(3) without time zone,
    deferred_until timestamp(3) without time zone,
    cap_bucket timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."NudgeLog" FORCE ROW LEVEL SECURITY;


--
-- Name: PartialRefundDecision; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."PartialRefundDecision" (
    id text NOT NULL,
    client_purchase_id text NOT NULL,
    stripe_refund_id text NOT NULL,
    decision text DEFAULT 'pending'::text NOT NULL,
    decided_at timestamp(3) without time zone,
    decided_by_coach_user_id text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."PartialRefundDecision" FORCE ROW LEVEL SECURITY;


--
-- Name: PaymentFailure; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."PaymentFailure" (
    id text NOT NULL,
    coach_id text NOT NULL,
    stripe_invoice_id text,
    stripe_event_id text,
    amount_due_cents integer DEFAULT 0 NOT NULL,
    reason text,
    occurred_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."PaymentFailure" FORCE ROW LEVEL SECURITY;


--
-- Name: PaymentRecoveryToken; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."PaymentRecoveryToken" (
    id text NOT NULL,
    dunning_attempt_id text NOT NULL,
    jwt_jti text NOT NULL,
    expires_at timestamp(3) without time zone NOT NULL,
    used_at timestamp(3) without time zone,
    ip text,
    ua text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."PaymentRecoveryToken" FORCE ROW LEVEL SECURITY;


--
-- Name: PaymentReminder; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."PaymentReminder" (
    id text NOT NULL,
    purchase_id text NOT NULL,
    kind text NOT NULL,
    channel text NOT NULL,
    recipient_user_id text NOT NULL,
    status text DEFAULT 'queued'::text NOT NULL,
    sent_at timestamp(3) without time zone,
    failure_reason text,
    window_key text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."PaymentReminder" FORCE ROW LEVEL SECURITY;


--
-- Name: PayoutMethod; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."PayoutMethod" (
    id text NOT NULL,
    coach_id text NOT NULL,
    kind public."PayoutMethodKind" NOT NULL,
    stripe_external_account_id text,
    last4 text,
    bank_name text,
    status public."PayoutMethodStatus" DEFAULT 'PENDING_VERIFICATION'::public."PayoutMethodStatus" NOT NULL,
    "default" boolean DEFAULT false NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."PayoutMethod" FORCE ROW LEVEL SECURITY;


--
-- Name: PayoutSnapshot; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."PayoutSnapshot" (
    id text NOT NULL,
    coach_user_id text NOT NULL,
    stripe_account_id text NOT NULL,
    readiness_status text DEFAULT 'needs_action'::text NOT NULL,
    charges_enabled boolean DEFAULT false NOT NULL,
    payouts_enabled boolean DEFAULT false NOT NULL,
    details_submitted boolean DEFAULT false NOT NULL,
    requirements_due jsonb,
    disabled_reason text,
    available_cents integer DEFAULT 0 NOT NULL,
    pending_cents integer DEFAULT 0 NOT NULL,
    in_transit_cents integer DEFAULT 0 NOT NULL,
    reserved_cents integer DEFAULT 0 NOT NULL,
    currency text DEFAULT 'usd'::text NOT NULL,
    raw_balance jsonb,
    last_payout_stripe_id text,
    last_payout_amount_cents integer,
    last_payout_status text,
    last_payout_arrival_at timestamp(3) without time zone,
    last_payout_failure_message text,
    next_payout_at timestamp(3) without time zone,
    refreshed_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    stale_after timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);

ALTER TABLE ONLY public."PayoutSnapshot" FORCE ROW LEVEL SECURITY;


--
-- Name: Person; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Person" (
    id text NOT NULL,
    coach_id text NOT NULL,
    source_platform text NOT NULL,
    source_person_id text NOT NULL,
    display_name text,
    state public."PersonState" DEFAULT 'InvitePending'::public."PersonState" NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."Person" FORCE ROW LEVEL SECURITY;


--
-- Name: PtmPrediction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."PtmPrediction" (
    id text NOT NULL,
    user_id text NOT NULL,
    risk_score double precision NOT NULL,
    success_score double precision NOT NULL,
    prediction_basis public."PtmPredictionBasis" NOT NULL,
    factors jsonb,
    computed_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."PtmPrediction" FORCE ROW LEVEL SECURITY;


--
-- Name: PurchaseFanout; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."PurchaseFanout" (
    id text NOT NULL,
    purchase_id text NOT NULL,
    state text DEFAULT 'pending'::text NOT NULL,
    entrypoint text NOT NULL,
    started_at timestamp(3) without time zone,
    finished_at timestamp(3) without time zone,
    retry_count integer DEFAULT 0 NOT NULL,
    last_error text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."PurchaseFanout" FORCE ROW LEVEL SECURITY;


--
-- Name: ReconciliationSnapshot; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ReconciliationSnapshot" (
    id text NOT NULL,
    purchase_id text NOT NULL,
    status text DEFAULT 'ok'::text NOT NULL,
    drift_cents integer,
    stripe_amount_cents integer,
    stripe_refunded_cents integer,
    stripe_application_fee_cents integer,
    stripe_transfers_cents integer,
    ledger_destination_cents integer,
    ledger_application_fee_cents integer,
    ledger_head_coach_cents integer,
    ledger_reversed_cents integer,
    notes text,
    last_checked_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);

ALTER TABLE ONLY public."ReconciliationSnapshot" FORCE ROW LEVEL SECURITY;


--
-- Name: RomanMessage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."RomanMessage" (
    id text NOT NULL,
    session_id text NOT NULL,
    user_id text NOT NULL,
    role public."RomanMessageRole" NOT NULL,
    content text NOT NULL,
    prompt_tokens integer,
    completion_tokens integer,
    model_id text,
    interrupted boolean DEFAULT false NOT NULL,
    parent_message_id text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."RomanMessage" FORCE ROW LEVEL SECURITY;


--
-- Name: RomanSession; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."RomanSession" (
    id text NOT NULL,
    user_id text NOT NULL,
    surface public."RomanSurface" NOT NULL,
    day_key text NOT NULL,
    message_count integer DEFAULT 0 NOT NULL,
    started_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_activity_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    quips_in_session integer DEFAULT 0 NOT NULL,
    exclamation_used boolean DEFAULT false NOT NULL,
    subject_context_json jsonb,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    deleted_at timestamp(3) without time zone
);

ALTER TABLE ONLY public."RomanSession" FORCE ROW LEVEL SECURITY;


--
-- Name: RoutineExercise; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."RoutineExercise" (
    id text NOT NULL,
    routine_id text NOT NULL,
    exercise_name text NOT NULL,
    muscle_group public."MuscleGroup" NOT NULL,
    default_sets integer NOT NULL,
    default_reps integer NOT NULL,
    default_rest_seconds integer DEFAULT 90 NOT NULL,
    video_url text,
    order_index integer NOT NULL
);

ALTER TABLE ONLY public."RoutineExercise" FORCE ROW LEVEL SECURITY;


--
-- Name: ScheduledDrop; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ScheduledDrop" (
    id text NOT NULL,
    client_purchase_id text NOT NULL,
    content_id text NOT NULL,
    asset_type text NOT NULL,
    asset_id text NOT NULL,
    asset_revision_id text,
    cadence_kind text NOT NULL,
    cadence_payload jsonb NOT NULL,
    display_title text,
    display_caption text,
    fire_at timestamp(3) without time zone,
    fired_at timestamp(3) without time zone,
    status text DEFAULT 'pending'::text NOT NULL,
    attempt_count integer DEFAULT 0 NOT NULL,
    materialised_ref text,
    failure_reason text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    locked_at timestamp(3) without time zone,
    next_retry_at timestamp(3) without time zone,
    alert_dispatched_at timestamp(3) without time zone,
    push_seq integer DEFAULT 0 NOT NULL
);

ALTER TABLE ONLY public."ScheduledDrop" FORCE ROW LEVEL SECURITY;


--
-- Name: ScoutImport; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ScoutImport" (
    id text NOT NULL,
    coach_id text NOT NULL,
    intent_id text NOT NULL,
    state text DEFAULT 'in_progress'::text NOT NULL,
    terminal_status text,
    started_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    completed_at timestamp(3) without time zone
);

ALTER TABLE ONLY public."ScoutImport" FORCE ROW LEVEL SECURITY;


--
-- Name: ScoutImportCompletion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ScoutImportCompletion" (
    id text NOT NULL,
    coach_id text NOT NULL,
    intent_id text NOT NULL,
    terminal_status text NOT NULL,
    final_counts jsonb,
    error_summary text,
    completed_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."ScoutImportCompletion" FORCE ROW LEVEL SECURITY;


--
-- Name: ScoutIngestEntity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ScoutIngestEntity" (
    id text NOT NULL,
    coach_id text NOT NULL,
    intent_id text NOT NULL,
    entity_type text NOT NULL,
    source_id text NOT NULL,
    source_platform text NOT NULL,
    captured_at timestamp(3) without time zone,
    payload jsonb NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."ScoutIngestEntity" FORCE ROW LEVEL SECURITY;


--
-- Name: ScoutProgressSnapshot; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ScoutProgressSnapshot" (
    id text NOT NULL,
    coach_id text NOT NULL,
    intent_id text NOT NULL,
    device_id text NOT NULL,
    snapshot jsonb NOT NULL,
    last_error text,
    updated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."ScoutProgressSnapshot" FORCE ROW LEVEL SECURITY;


--
-- Name: ScoutReconstructedEntity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ScoutReconstructedEntity" (
    id text NOT NULL,
    coach_id text NOT NULL,
    source_platform text NOT NULL,
    entity_type text NOT NULL,
    source_id text NOT NULL,
    client_source_id text,
    label text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."ScoutReconstructedEntity" FORCE ROW LEVEL SECURITY;


--
-- Name: ScoutReconstructionLedger; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ScoutReconstructionLedger" (
    id text NOT NULL,
    coach_id text NOT NULL,
    intent_id text NOT NULL,
    entity_type text NOT NULL,
    source_id text NOT NULL,
    status text NOT NULL,
    target_id text,
    reason text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."ScoutReconstructionLedger" FORCE ROW LEVEL SECURITY;


--
-- Name: SessionParticipant; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."SessionParticipant" (
    id text NOT NULL,
    session_id text NOT NULL,
    user_id text NOT NULL,
    role public."SessionParticipantRole" NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."SessionParticipant" FORCE ROW LEVEL SECURITY;


--
-- Name: SessionType; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."SessionType" (
    id text NOT NULL,
    coach_id text NOT NULL,
    name text NOT NULL,
    description text,
    duration_minutes integer DEFAULT 30 NOT NULL,
    auto_approve boolean DEFAULT false NOT NULL,
    default_video_provider public."VideoProvider" DEFAULT 'stub'::public."VideoProvider" NOT NULL,
    archived_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."SessionType" FORCE ROW LEVEL SECURITY;


--
-- Name: SplitLedgerEntry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."SplitLedgerEntry" (
    id text NOT NULL,
    purchase_id text NOT NULL,
    kind text NOT NULL,
    payee_user_id text,
    payee_stripe_account_id text,
    amount_cents integer NOT NULL,
    currency text DEFAULT 'usd'::text NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    stripe_charge_id text,
    stripe_application_fee_id text,
    stripe_transfer_id text,
    reversed_cents integer DEFAULT 0 NOT NULL,
    idempotency_key text,
    last_error text,
    posted_at timestamp(3) without time zone,
    reversed_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);

ALTER TABLE ONLY public."SplitLedgerEntry" FORCE ROW LEVEL SECURITY;


--
-- Name: StripeProcessedEvent; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."StripeProcessedEvent" (
    stripe_event_id text NOT NULL,
    type text NOT NULL,
    processed_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    handler_completed_at timestamp(3) without time zone
);

ALTER TABLE ONLY public."StripeProcessedEvent" FORCE ROW LEVEL SECURITY;


--
-- Name: SubCoachAssignment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."SubCoachAssignment" (
    id text NOT NULL,
    head_coach_id text NOT NULL,
    sub_coach_id text NOT NULL,
    client_id text NOT NULL,
    assigned_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    unassigned_at timestamp(3) without time zone,
    assigned_by_id text,
    reason text
);

ALTER TABLE ONLY public."SubCoachAssignment" FORCE ROW LEVEL SECURITY;


--
-- Name: SubCoachInvite; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."SubCoachInvite" (
    id text NOT NULL,
    head_coach_id text NOT NULL,
    email text NOT NULL,
    name text,
    max_clients integer,
    token text,
    expires_at timestamp(3) without time zone NOT NULL,
    accepted_at timestamp(3) without time zone,
    accepted_by_user_id text,
    revoked_at timestamp(3) without time zone,
    revoked_by_user_id text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    token_hash text
);

ALTER TABLE ONLY public."SubCoachInvite" FORCE ROW LEVEL SECURITY;


--
-- Name: SubCoachMutationIdempotency; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."SubCoachMutationIdempotency" (
    id text NOT NULL,
    actor_id text NOT NULL,
    idempotency_key text NOT NULL,
    action text NOT NULL,
    request_hash text,
    response jsonb NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status text DEFAULT 'completed'::text NOT NULL,
    updated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."SubCoachMutationIdempotency" FORCE ROW LEVEL SECURITY;


--
-- Name: TeamAuditEvent; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TeamAuditEvent" (
    id text NOT NULL,
    head_coach_id text NOT NULL,
    actor_user_id text NOT NULL,
    target_client_id text,
    event_kind public."TeamAuditEventKind" NOT NULL,
    summary text NOT NULL,
    metadata jsonb,
    occurred_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."TeamAuditEvent" FORCE ROW LEVEL SECURITY;


--
-- Name: TeamProfile; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TeamProfile" (
    id text NOT NULL,
    head_coach_id text NOT NULL,
    business_name text NOT NULL,
    team_code text NOT NULL,
    client_capacity integer DEFAULT 0 NOT NULL,
    clients_assigned integer DEFAULT 0 NOT NULL,
    payouts_enabled boolean DEFAULT false NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);

ALTER TABLE ONLY public."TeamProfile" FORCE ROW LEVEL SECURITY;


--
-- Name: TeamSubCoachAssignment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TeamSubCoachAssignment" (
    id text NOT NULL,
    head_coach_id text NOT NULL,
    sub_coach_id text NOT NULL,
    stripe_subscription_item_id text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    archived_at timestamp(3) without time zone
);

ALTER TABLE ONLY public."TeamSubCoachAssignment" FORCE ROW LEVEL SECURITY;


--
-- Name: User; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."User" (
    id text NOT NULL,
    supabase_id text NOT NULL,
    email text NOT NULL,
    name text NOT NULL,
    phone text,
    role public."Role" DEFAULT 'student'::public."Role" NOT NULL,
    coach_id text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deletion_scheduled_at timestamp(3) without time zone,
    deleted_at timestamp(3) without time zone,
    first_win_completed_at timestamp(3) without time zone,
    show_on_leaderboard boolean DEFAULT false NOT NULL,
    leaderboard_display_name text,
    deletion_requested_at timestamp(3) without time zone,
    deletion_confirmed_at timestamp(3) without time zone,
    deletion_token_hash text,
    deletion_token_expires_at timestamp(3) without time zone,
    coach_practice_type public."CoachPracticeType",
    expo_push_token text,
    default_payout_method_id text,
    signup_ref text
);

ALTER TABLE ONLY public."User" FORCE ROW LEVEL SECURITY;


--
-- Name: UserAIQuota; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."UserAIQuota" (
    id text NOT NULL,
    user_id text NOT NULL,
    quota_date date NOT NULL,
    tokens_used integer DEFAULT 0 NOT NULL,
    request_count integer DEFAULT 0 NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);

ALTER TABLE ONLY public."UserAIQuota" FORCE ROW LEVEL SECURITY;


--
-- Name: UserBlock; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."UserBlock" (
    id text NOT NULL,
    blocker_id text NOT NULL,
    blocked_id text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."UserBlock" FORCE ROW LEVEL SECURITY;


--
-- Name: UserProfile; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."UserProfile" (
    id text NOT NULL,
    user_id text NOT NULL,
    height_cm double precision,
    current_weight_lbs double precision,
    target_weight_lbs double precision,
    date_of_birth timestamp(3) without time zone,
    sex public."Sex" DEFAULT 'prefer_not_to_say'::public."Sex" NOT NULL,
    activity_level public."ActivityLevel" DEFAULT 'moderate'::public."ActivityLevel" NOT NULL,
    goal_type public."GoalType" DEFAULT 'fat_loss'::public."GoalType" NOT NULL,
    workout_experience public."WorkoutExperience" DEFAULT 'beginner'::public."WorkoutExperience" NOT NULL,
    has_gym_membership boolean DEFAULT false NOT NULL,
    preferred_snacks text[],
    macro_target_calories double precision,
    macro_target_protein_g double precision,
    macro_target_carbs_g double precision,
    macro_target_fat_g double precision,
    avatar_url text,
    updated_at timestamp(3) without time zone NOT NULL,
    dietary_pattern text,
    dietary_restrictions text[] DEFAULT ARRAY[]::text[],
    workout_days_per_week integer,
    equipment_access text[] DEFAULT ARRAY[]::text[],
    injuries text[] DEFAULT '{}'::text[] NOT NULL,
    food_preferences jsonb,
    preferred_training_time text
);

ALTER TABLE ONLY public."UserProfile" FORCE ROW LEVEL SECURITY;


--
-- Name: WearableConnection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."WearableConnection" (
    id text NOT NULL,
    user_id text NOT NULL,
    provider public."WearableProvider" NOT NULL,
    external_account_id text,
    credentials_secret_ref text,
    encrypted_refresh_token text,
    encrypted_access_token text,
    access_token_expires_at timestamp(3) without time zone,
    scopes text[] DEFAULT ARRAY[]::text[],
    webhook_subscription_id text,
    webhook_secret_ref text,
    channel_expires_at timestamp(3) without time zone,
    status text DEFAULT 'connected'::text NOT NULL,
    last_error text,
    last_synced_at timestamp(3) without time zone,
    backfilled_until timestamp(3) without time zone,
    disconnected_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."WearableConnection" FORCE ROW LEVEL SECURITY;


--
-- Name: WearableConnectionSafe; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public."WearableConnectionSafe" WITH (security_invoker='true') AS
 SELECT id,
    user_id,
    provider,
    external_account_id,
    access_token_expires_at,
    scopes,
    webhook_subscription_id,
    channel_expires_at,
    status,
    last_error,
    last_synced_at,
    backfilled_until,
    disconnected_at,
    created_at,
    updated_at
   FROM public."WearableConnection";


--
-- Name: WearableInsightCache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."WearableInsightCache" (
    id text NOT NULL,
    user_id text NOT NULL,
    side text NOT NULL,
    bucket public."WearableMetricBucket" NOT NULL,
    window_days integer NOT NULL,
    payload jsonb NOT NULL,
    model_used text NOT NULL,
    prompt_version text NOT NULL,
    generated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    expires_at timestamp(3) without time zone NOT NULL
);

ALTER TABLE ONLY public."WearableInsightCache" FORCE ROW LEVEL SECURITY;


--
-- Name: WearableMetricDef; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."WearableMetricDef" (
    metric public."WearableMetricType" NOT NULL,
    bucket public."WearableMetricBucket" NOT NULL,
    unit text NOT NULL,
    display_name text NOT NULL,
    aggregation text NOT NULL,
    norm_band jsonb,
    sort_order integer DEFAULT 0 NOT NULL
);

ALTER TABLE ONLY public."WearableMetricDef" FORCE ROW LEVEL SECURITY;


--
-- Name: WearableProcessedEvent; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."WearableProcessedEvent" (
    provider public."WearableProvider" NOT NULL,
    provider_event_id text NOT NULL,
    type text NOT NULL,
    processed_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    handler_completed_at timestamp(3) without time zone
);

ALTER TABLE ONLY public."WearableProcessedEvent" FORCE ROW LEVEL SECURITY;


--
-- Name: WearableSample; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."WearableSample" (
    id text NOT NULL,
    user_id text NOT NULL,
    connection_id text NOT NULL,
    provider public."WearableProvider" NOT NULL,
    metric public."WearableMetricType" NOT NULL,
    bucket public."WearableMetricBucket" NOT NULL,
    value double precision NOT NULL,
    unit text NOT NULL,
    start_at timestamp(3) without time zone NOT NULL,
    end_at timestamp(3) without time zone NOT NULL,
    source_tz text,
    dedup_key text NOT NULL,
    source_record_id text,
    recorded_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    raw_ref text
);

ALTER TABLE ONLY public."WearableSample" FORCE ROW LEVEL SECURITY;


--
-- Name: WearableUserMetricPreference; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."WearableUserMetricPreference" (
    id text NOT NULL,
    user_id text NOT NULL,
    metric public."WearableMetricType" NOT NULL,
    preferred_provider public."WearableProvider" NOT NULL,
    updated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."WearableUserMetricPreference" FORCE ROW LEVEL SECURITY;


--
-- Name: WeightLog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."WeightLog" (
    id text NOT NULL,
    user_id text NOT NULL,
    date date NOT NULL,
    weight_lbs double precision NOT NULL,
    notes text,
    logged_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."WeightLog" FORCE ROW LEVEL SECURITY;


--
-- Name: WorkoutBuilderIdempotencyKey; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."WorkoutBuilderIdempotencyKey" (
    id text NOT NULL,
    user_id text NOT NULL,
    route_key text NOT NULL,
    idempotency_key text NOT NULL,
    response_json jsonb,
    status_code integer,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status character varying(20) DEFAULT 'completed'::character varying NOT NULL,
    updated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."WorkoutBuilderIdempotencyKey" FORCE ROW LEVEL SECURITY;


--
-- Name: WorkoutPlan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."WorkoutPlan" (
    id text NOT NULL,
    coach_id text NOT NULL,
    name text NOT NULL,
    type public."WorkoutPlanType" NOT NULL,
    duration_estimate_minutes integer,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    archived_at timestamp(3) without time zone,
    cloned_from_plan_id text,
    day_index integer,
    head_revision_id text,
    is_template boolean DEFAULT false NOT NULL,
    program_id text,
    version integer DEFAULT 1 NOT NULL,
    week_index integer
);

ALTER TABLE ONLY public."WorkoutPlan" FORCE ROW LEVEL SECURITY;


--
-- Name: WorkoutPlanExercise; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."WorkoutPlanExercise" (
    id text NOT NULL,
    workout_plan_id text NOT NULL,
    exercise_external_id text NOT NULL,
    "order" integer NOT NULL,
    sets integer NOT NULL,
    reps_or_duration_seconds integer NOT NULL,
    weight_lbs double precision,
    rest_seconds integer,
    superset_group_id text,
    notes text,
    archived_at timestamp(3) without time zone
);

ALTER TABLE ONLY public."WorkoutPlanExercise" FORCE ROW LEVEL SECURITY;


--
-- Name: WorkoutPlanRevision; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."WorkoutPlanRevision" (
    id text NOT NULL,
    workout_plan_id text NOT NULL,
    revision_index integer NOT NULL,
    exercises_json jsonb NOT NULL,
    plan_meta_json jsonb NOT NULL,
    author_id text NOT NULL,
    author_kind text NOT NULL,
    cause text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."WorkoutPlanRevision" FORCE ROW LEVEL SECURITY;


--
-- Name: WorkoutProgram; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."WorkoutProgram" (
    id text NOT NULL,
    coach_id text NOT NULL,
    owner_user_id text NOT NULL,
    visibility text DEFAULT 'owner_only'::text NOT NULL,
    forked_from_id text,
    name text NOT NULL,
    description text,
    weeks integer NOT NULL,
    days_per_week integer NOT NULL,
    is_template boolean DEFAULT true NOT NULL,
    cloned_from_id text,
    goal_tag text,
    version integer DEFAULT 1 NOT NULL,
    head_revision_id text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    archived_at timestamp(3) without time zone,
    is_regime boolean DEFAULT false NOT NULL,
    regime_display_name text,
    revision_retention_count integer DEFAULT 3 NOT NULL
);

ALTER TABLE ONLY public."WorkoutProgram" FORCE ROW LEVEL SECURITY;


--
-- Name: WorkoutProgramRevision; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."WorkoutProgramRevision" (
    id text NOT NULL,
    program_id text NOT NULL,
    revision_index integer NOT NULL,
    structure_json jsonb NOT NULL,
    author_id text NOT NULL,
    author_kind text NOT NULL,
    cause text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."WorkoutProgramRevision" FORCE ROW LEVEL SECURITY;


--
-- Name: WorkoutRoutine; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."WorkoutRoutine" (
    id text NOT NULL,
    creator_id text NOT NULL,
    name text NOT NULL,
    description text,
    is_template boolean DEFAULT false NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."WorkoutRoutine" FORCE ROW LEVEL SECURITY;


--
-- Name: WorkoutSession; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."WorkoutSession" (
    id text NOT NULL,
    user_id text NOT NULL,
    date date NOT NULL,
    workout_name text NOT NULL,
    workout_type text NOT NULL,
    duration_minutes integer,
    intensity public."Intensity" DEFAULT 'moderate'::public."Intensity" NOT NULL,
    notes text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public."WorkoutSession" FORCE ROW LEVEL SECURITY;


--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


--
-- Name: coach_first_payment_notification; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.coach_first_payment_notification (
    id text NOT NULL,
    "coachId" text NOT NULL,
    amount integer NOT NULL,
    currency text NOT NULL,
    "clientId" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public.coach_first_payment_notification FORCE ROW LEVEL SECURITY;


--
-- Name: coach_ltv_peak; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.coach_ltv_peak (
    id text NOT NULL,
    coach_id text NOT NULL,
    zero_churn_streak integer DEFAULT 0 NOT NULL,
    all_time_peak_rpcm numeric(20,6) DEFAULT 0 NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);

ALTER TABLE ONLY public.coach_ltv_peak FORCE ROW LEVEL SECURITY;


--
-- Name: community_challenge_participations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.community_challenge_participations (
    id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    challenge_id uuid NOT NULL,
    user_id text NOT NULL,
    progress_value numeric(12,2) DEFAULT 0 NOT NULL,
    completed_at timestamp(6) with time zone,
    last_logged_at timestamp(6) with time zone,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL
);

ALTER TABLE ONLY public.community_challenge_participations FORCE ROW LEVEL SECURITY;


--
-- Name: community_challenges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.community_challenges (
    id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    cohort_id uuid,
    created_by_id text NOT NULL,
    title character varying(160) NOT NULL,
    description text,
    status public."CommunityChallengeStatus" DEFAULT 'draft'::public."CommunityChallengeStatus" NOT NULL,
    starts_at timestamp(6) with time zone,
    ends_at timestamp(6) with time zone,
    metric_key character varying(80),
    target_value numeric(12,2),
    unit character varying(40),
    leaderboard_enabled boolean DEFAULT false NOT NULL,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL,
    archived_at timestamp(6) with time zone
);

ALTER TABLE ONLY public.community_challenges FORCE ROW LEVEL SECURITY;


--
-- Name: community_classroom_media_assets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.community_classroom_media_assets (
    id uuid NOT NULL,
    post_id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    kind character varying(16) NOT NULL,
    storage_key text NOT NULL,
    duration_sec integer,
    bytes bigint,
    mime_type character varying(120),
    width integer,
    height integer,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public.community_classroom_media_assets FORCE ROW LEVEL SECURITY;


--
-- Name: community_classroom_posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.community_classroom_posts (
    id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    cohort_id uuid,
    coach_id text NOT NULL,
    title character varying(200) NOT NULL,
    body_markdown text NOT NULL,
    status public."CommunityClassroomPostStatus" DEFAULT 'draft'::public."CommunityClassroomPostStatus" NOT NULL,
    pinned boolean DEFAULT false NOT NULL,
    pinned_order integer,
    release_at timestamp(6) with time zone,
    published_at timestamp(6) with time zone,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL,
    soft_deleted_at timestamp(6) with time zone
);

ALTER TABLE ONLY public.community_classroom_posts FORCE ROW LEVEL SECURITY;


--
-- Name: community_cohorts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.community_cohorts (
    id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    name character varying(120) NOT NULL,
    description text,
    status public."CommunityCohortStatus" DEFAULT 'active'::public."CommunityCohortStatus" NOT NULL,
    starts_at timestamp(6) with time zone,
    ends_at timestamp(6) with time zone,
    capacity integer,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL,
    archived_at timestamp(6) with time zone
);

ALTER TABLE ONLY public.community_cohorts FORCE ROW LEVEL SECURITY;


--
-- Name: community_event_rsvps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.community_event_rsvps (
    id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    event_id uuid NOT NULL,
    user_id text NOT NULL,
    status public."CommunityEventRsvpStatus" NOT NULL,
    reminded_at timestamp(6) with time zone,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL
);

ALTER TABLE ONLY public.community_event_rsvps FORCE ROW LEVEL SECURITY;


--
-- Name: community_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.community_events (
    id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    cohort_id uuid,
    created_by_id text NOT NULL,
    title character varying(160) NOT NULL,
    description text,
    state public."CommunityEventState" DEFAULT 'scheduled'::public."CommunityEventState" NOT NULL,
    starts_at timestamp(6) with time zone NOT NULL,
    ends_at timestamp(6) with time zone,
    live_url text,
    replay_media_asset_id uuid,
    reflected_at timestamp(6) with time zone,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL,
    canceled_at timestamp(6) with time zone
);

ALTER TABLE ONLY public.community_events FORCE ROW LEVEL SECURITY;


--
-- Name: community_memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.community_memberships (
    id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    cohort_id uuid NOT NULL,
    user_id text NOT NULL,
    role public."CommunityMembershipRole" DEFAULT 'student'::public."CommunityMembershipRole" NOT NULL,
    status public."CommunityMembershipStatus" DEFAULT 'active'::public."CommunityMembershipStatus" NOT NULL,
    dm_enabled boolean,
    notify_level character varying(32) DEFAULT 'digest'::character varying NOT NULL,
    joined_at timestamp(6) with time zone,
    last_read_message_at timestamp(6) with time zone,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL,
    removed_at timestamp(6) with time zone
);

ALTER TABLE ONLY public.community_memberships FORCE ROW LEVEL SECURITY;


--
-- Name: community_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.community_messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    workspace_id uuid NOT NULL,
    cohort_id uuid,
    scope public."CommunityMessageScope" NOT NULL,
    dm_key character varying(160),
    recipient_user_id text,
    sender_id text NOT NULL,
    kind public."CommunityMessageKind" DEFAULT 'text'::public."CommunityMessageKind" NOT NULL,
    body character varying(4000),
    voice_url text,
    voice_duration_ms integer,
    voice_mime_type character varying(80),
    voice_size_bytes integer,
    plan_context_type character varying(40),
    plan_context_id uuid,
    plan_week_start date,
    parent_message_id uuid,
    parent_message_at timestamp(6) with time zone,
    coach_seen_at timestamp(6) with time zone,
    coach_acked_at timestamp(6) with time zone,
    coach_replied_at timestamp(6) with time zone,
    visibility character varying(24) DEFAULT 'active'::character varying NOT NULL,
    deleted_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone NOT NULL,
    plan_context_payload jsonb,
    CONSTRAINT community_messages_scope_shape_check CHECK ((((scope = 'cohort'::public."CommunityMessageScope") AND (cohort_id IS NOT NULL) AND (dm_key IS NULL)) OR ((scope = 'dm'::public."CommunityMessageScope") AND (cohort_id IS NULL) AND (dm_key IS NOT NULL))))
)
PARTITION BY RANGE (created_at);

ALTER TABLE ONLY public.community_messages FORCE ROW LEVEL SECURITY;


--
-- Name: community_messages_2026_12; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.community_messages_2026_12 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    workspace_id uuid NOT NULL,
    cohort_id uuid,
    scope public."CommunityMessageScope" NOT NULL,
    dm_key character varying(160),
    recipient_user_id text,
    sender_id text NOT NULL,
    kind public."CommunityMessageKind" DEFAULT 'text'::public."CommunityMessageKind" NOT NULL,
    body character varying(4000),
    voice_url text,
    voice_duration_ms integer,
    voice_mime_type character varying(80),
    voice_size_bytes integer,
    plan_context_type character varying(40),
    plan_context_id uuid,
    plan_week_start date,
    parent_message_id uuid,
    parent_message_at timestamp(6) with time zone,
    coach_seen_at timestamp(6) with time zone,
    coach_acked_at timestamp(6) with time zone,
    coach_replied_at timestamp(6) with time zone,
    visibility character varying(24) DEFAULT 'active'::character varying NOT NULL,
    deleted_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone NOT NULL,
    plan_context_payload jsonb,
    CONSTRAINT community_messages_scope_shape_check CHECK ((((scope = 'cohort'::public."CommunityMessageScope") AND (cohort_id IS NOT NULL) AND (dm_key IS NULL)) OR ((scope = 'dm'::public."CommunityMessageScope") AND (cohort_id IS NULL) AND (dm_key IS NOT NULL))))
);

ALTER TABLE ONLY public.community_messages_2026_12 FORCE ROW LEVEL SECURITY;


--
-- Name: community_messages_2027_01; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.community_messages_2027_01 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    workspace_id uuid NOT NULL,
    cohort_id uuid,
    scope public."CommunityMessageScope" NOT NULL,
    dm_key character varying(160),
    recipient_user_id text,
    sender_id text NOT NULL,
    kind public."CommunityMessageKind" DEFAULT 'text'::public."CommunityMessageKind" NOT NULL,
    body character varying(4000),
    voice_url text,
    voice_duration_ms integer,
    voice_mime_type character varying(80),
    voice_size_bytes integer,
    plan_context_type character varying(40),
    plan_context_id uuid,
    plan_week_start date,
    parent_message_id uuid,
    parent_message_at timestamp(6) with time zone,
    coach_seen_at timestamp(6) with time zone,
    coach_acked_at timestamp(6) with time zone,
    coach_replied_at timestamp(6) with time zone,
    visibility character varying(24) DEFAULT 'active'::character varying NOT NULL,
    deleted_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone NOT NULL,
    plan_context_payload jsonb,
    CONSTRAINT community_messages_scope_shape_check CHECK ((((scope = 'cohort'::public."CommunityMessageScope") AND (cohort_id IS NOT NULL) AND (dm_key IS NULL)) OR ((scope = 'dm'::public."CommunityMessageScope") AND (cohort_id IS NULL) AND (dm_key IS NOT NULL))))
);

ALTER TABLE ONLY public.community_messages_2027_01 FORCE ROW LEVEL SECURITY;


--
-- Name: community_messages_2027_02; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.community_messages_2027_02 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    workspace_id uuid NOT NULL,
    cohort_id uuid,
    scope public."CommunityMessageScope" NOT NULL,
    dm_key character varying(160),
    recipient_user_id text,
    sender_id text NOT NULL,
    kind public."CommunityMessageKind" DEFAULT 'text'::public."CommunityMessageKind" NOT NULL,
    body character varying(4000),
    voice_url text,
    voice_duration_ms integer,
    voice_mime_type character varying(80),
    voice_size_bytes integer,
    plan_context_type character varying(40),
    plan_context_id uuid,
    plan_week_start date,
    parent_message_id uuid,
    parent_message_at timestamp(6) with time zone,
    coach_seen_at timestamp(6) with time zone,
    coach_acked_at timestamp(6) with time zone,
    coach_replied_at timestamp(6) with time zone,
    visibility character varying(24) DEFAULT 'active'::character varying NOT NULL,
    deleted_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone NOT NULL,
    plan_context_payload jsonb,
    CONSTRAINT community_messages_scope_shape_check CHECK ((((scope = 'cohort'::public."CommunityMessageScope") AND (cohort_id IS NOT NULL) AND (dm_key IS NULL)) OR ((scope = 'dm'::public."CommunityMessageScope") AND (cohort_id IS NULL) AND (dm_key IS NOT NULL))))
);

ALTER TABLE ONLY public.community_messages_2027_02 FORCE ROW LEVEL SECURITY;


--
-- Name: community_messages_2028_03; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.community_messages_2028_03 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    workspace_id uuid NOT NULL,
    cohort_id uuid,
    scope public."CommunityMessageScope" NOT NULL,
    dm_key character varying(160),
    recipient_user_id text,
    sender_id text NOT NULL,
    kind public."CommunityMessageKind" DEFAULT 'text'::public."CommunityMessageKind" NOT NULL,
    body character varying(4000),
    voice_url text,
    voice_duration_ms integer,
    voice_mime_type character varying(80),
    voice_size_bytes integer,
    plan_context_type character varying(40),
    plan_context_id uuid,
    plan_week_start date,
    parent_message_id uuid,
    parent_message_at timestamp(6) with time zone,
    coach_seen_at timestamp(6) with time zone,
    coach_acked_at timestamp(6) with time zone,
    coach_replied_at timestamp(6) with time zone,
    visibility character varying(24) DEFAULT 'active'::character varying NOT NULL,
    deleted_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone NOT NULL,
    plan_context_payload jsonb,
    CONSTRAINT community_messages_scope_shape_check CHECK ((((scope = 'cohort'::public."CommunityMessageScope") AND (cohort_id IS NOT NULL) AND (dm_key IS NULL)) OR ((scope = 'dm'::public."CommunityMessageScope") AND (cohort_id IS NULL) AND (dm_key IS NOT NULL))))
);

ALTER TABLE ONLY public.community_messages_2028_03 FORCE ROW LEVEL SECURITY;


--
-- Name: community_messages_default; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.community_messages_default (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    workspace_id uuid NOT NULL,
    cohort_id uuid,
    scope public."CommunityMessageScope" NOT NULL,
    dm_key character varying(160),
    recipient_user_id text,
    sender_id text NOT NULL,
    kind public."CommunityMessageKind" DEFAULT 'text'::public."CommunityMessageKind" NOT NULL,
    body character varying(4000),
    voice_url text,
    voice_duration_ms integer,
    voice_mime_type character varying(80),
    voice_size_bytes integer,
    plan_context_type character varying(40),
    plan_context_id uuid,
    plan_week_start date,
    parent_message_id uuid,
    parent_message_at timestamp(6) with time zone,
    coach_seen_at timestamp(6) with time zone,
    coach_acked_at timestamp(6) with time zone,
    coach_replied_at timestamp(6) with time zone,
    visibility character varying(24) DEFAULT 'active'::character varying NOT NULL,
    deleted_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone NOT NULL,
    plan_context_payload jsonb,
    CONSTRAINT community_messages_scope_shape_check CHECK ((((scope = 'cohort'::public."CommunityMessageScope") AND (cohort_id IS NOT NULL) AND (dm_key IS NULL)) OR ((scope = 'dm'::public."CommunityMessageScope") AND (cohort_id IS NULL) AND (dm_key IS NOT NULL))))
);

ALTER TABLE ONLY public.community_messages_default FORCE ROW LEVEL SECURITY;


--
-- Name: community_moderation_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.community_moderation_actions (
    id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    target_type public."CommunityModerationTargetType" NOT NULL,
    target_id uuid NOT NULL,
    reported_by_id text,
    actor_id text,
    status public."CommunityModerationStatus" DEFAULT 'open'::public."CommunityModerationStatus" NOT NULL,
    reason character varying(80) NOT NULL,
    notes text,
    action character varying(80),
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    resolved_at timestamp(6) with time zone
);

ALTER TABLE ONLY public.community_moderation_actions FORCE ROW LEVEL SECURITY;


--
-- Name: community_posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.community_posts (
    id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    cohort_id uuid,
    author_id text NOT NULL,
    scope public."CommunityPostScope" NOT NULL,
    type public."CommunityPostType" DEFAULT 'text'::public."CommunityPostType" NOT NULL,
    title character varying(160),
    body text,
    media_asset_id uuid,
    event_id uuid,
    pinned_at timestamp(6) with time zone,
    release_at timestamp(6) with time zone,
    expires_at timestamp(6) with time zone,
    visibility character varying(24) DEFAULT 'active'::character varying NOT NULL,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL,
    deleted_at timestamp(6) with time zone
);

ALTER TABLE ONLY public.community_posts FORCE ROW LEVEL SECURITY;


--
-- Name: community_responses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.community_responses (
    id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    target_type public."CommunityResponseTargetType" NOT NULL,
    target_id uuid NOT NULL,
    target_created_at timestamp(6) with time zone,
    user_id text NOT NULL,
    response_kind character varying(32) NOT NULL,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public.community_responses FORCE ROW LEVEL SECURITY;


--
-- Name: community_search_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.community_search_entries (
    id text NOT NULL,
    "workspaceId" uuid NOT NULL,
    "cohortId" uuid,
    kind public."CommunitySearchKind" NOT NULL,
    "targetId" uuid NOT NULL,
    "authorId" uuid,
    excerpt text NOT NULL,
    "visibleToRoles" text[],
    "createdAt" timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "softDeletedAt" timestamp(6) with time zone,
    search_tsv tsvector GENERATED ALWAYS AS (to_tsvector('english'::regconfig, excerpt)) STORED
);

ALTER TABLE ONLY public.community_search_entries FORCE ROW LEVEL SECURITY;


--
-- Name: community_voice_notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.community_voice_notes (
    id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    cohort_id uuid,
    conversation_id uuid,
    author_id text NOT NULL,
    storage_key text NOT NULL,
    duration_ms integer NOT NULL,
    bytes bigint NOT NULL,
    mime_type character varying(120) NOT NULL,
    waveform_peaks bytea,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    soft_deleted_at timestamp(6) with time zone
);

ALTER TABLE ONLY public.community_voice_notes FORCE ROW LEVEL SECURITY;


--
-- Name: community_wearable_prompt_sources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.community_wearable_prompt_sources (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    "promptId" uuid NOT NULL,
    "sampleId" text NOT NULL,
    "metricKey" character varying(64) NOT NULL,
    "observedValue" numeric(18,6) NOT NULL
);

ALTER TABLE ONLY public.community_wearable_prompt_sources FORCE ROW LEVEL SECURITY;


--
-- Name: community_wearable_prompts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.community_wearable_prompts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    "workspaceId" uuid NOT NULL,
    "coachId" text NOT NULL,
    "clientId" text NOT NULL,
    "metricKey" character varying(64) NOT NULL,
    "promptText" text NOT NULL,
    "generatedAt" timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "dismissedAt" timestamp(6) with time zone,
    "actedOnAt" timestamp(6) with time zone
);

ALTER TABLE ONLY public.community_wearable_prompts FORCE ROW LEVEL SECURITY;


--
-- Name: community_workspaces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.community_workspaces (
    id uuid NOT NULL,
    coach_id text NOT NULL,
    name character varying(120) NOT NULL,
    slug character varying(80) NOT NULL,
    description text,
    dm_enabled_default boolean DEFAULT false NOT NULL,
    hall_enabled boolean DEFAULT true NOT NULL,
    events_enabled boolean DEFAULT false NOT NULL,
    challenges_enabled boolean DEFAULT false NOT NULL,
    max_cohort_members integer,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(6) with time zone NOT NULL,
    archived_at timestamp(6) with time zone
);

ALTER TABLE ONLY public.community_workspaces FORCE ROW LEVEL SECURITY;


--
-- Name: data_export_request; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.data_export_request (
    id text NOT NULL,
    user_id text NOT NULL,
    status public."DataExportStatus" DEFAULT 'PENDING'::public."DataExportStatus" NOT NULL,
    file_url text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    completed_at timestamp(3) without time zone,
    expires_at timestamp(3) without time zone,
    file_size_bytes integer,
    sha256 text
);

ALTER TABLE ONLY public.data_export_request FORCE ROW LEVEL SECURITY;


--
-- Name: deletion_audit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deletion_audit (
    id text NOT NULL,
    user_id text NOT NULL,
    event text NOT NULL,
    actor_id text,
    actor_role text,
    metadata jsonb,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public.deletion_audit FORCE ROW LEVEL SECURITY;


--
-- Name: recent_auth_nonce; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recent_auth_nonce (
    id text NOT NULL,
    hmac_suffix text NOT NULL,
    user_id text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY public.recent_auth_nonce FORCE ROW LEVEL SECURITY;


--
-- Name: secret_rotation_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.secret_rotation_log (
    id text NOT NULL,
    secret_name text NOT NULL,
    rotated_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    rotated_by_user_id text,
    notes text
);

ALTER TABLE ONLY public.secret_rotation_log FORCE ROW LEVEL SECURITY;


--
-- Name: water_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.water_logs (
    id text NOT NULL,
    user_id text NOT NULL,
    amount_ml integer NOT NULL,
    logged_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE ONLY public.water_logs FORCE ROW LEVEL SECURITY;


--
-- Name: community_messages_2026_12; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_messages ATTACH PARTITION public.community_messages_2026_12 FOR VALUES FROM ('2026-12-01 00:00:00+00') TO ('2027-01-01 00:00:00+00');


--
-- Name: community_messages_2027_01; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_messages ATTACH PARTITION public.community_messages_2027_01 FOR VALUES FROM ('2027-01-01 00:00:00+00') TO ('2027-02-01 00:00:00+00');


--
-- Name: community_messages_2027_02; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_messages ATTACH PARTITION public.community_messages_2027_02 FOR VALUES FROM ('2027-02-01 00:00:00+00') TO ('2027-03-01 00:00:00+00');


--
-- Name: community_messages_2028_03; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_messages ATTACH PARTITION public.community_messages_2028_03 FOR VALUES FROM ('2028-03-01 00:00:00+00') TO ('2028-04-01 00:00:00+00');


--
-- Name: community_messages_default; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_messages ATTACH PARTITION public.community_messages_default DEFAULT;


--
-- Name: AICallLog AICallLog_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AICallLog"
    ADD CONSTRAINT "AICallLog_pkey" PRIMARY KEY (id);


--
-- Name: AIDraft AIDraft_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AIDraft"
    ADD CONSTRAINT "AIDraft_pkey" PRIMARY KEY (id);


--
-- Name: ActivityEvent ActivityEvent_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ActivityEvent"
    ADD CONSTRAINT "ActivityEvent_pkey" PRIMARY KEY (id);


--
-- Name: AiActionDraft AiActionDraft_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AiActionDraft"
    ADD CONSTRAINT "AiActionDraft_pkey" PRIMARY KEY (id);


--
-- Name: AiRequestAudit AiRequestAudit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AiRequestAudit"
    ADD CONSTRAINT "AiRequestAudit_pkey" PRIMARY KEY (id);


--
-- Name: AiRoadmap AiRoadmap_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AiRoadmap"
    ADD CONSTRAINT "AiRoadmap_pkey" PRIMARY KEY (id);


--
-- Name: Applicant Applicant_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Applicant"
    ADD CONSTRAINT "Applicant_pkey" PRIMARY KEY (id);


--
-- Name: Application Application_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Application"
    ADD CONSTRAINT "Application_pkey" PRIMARY KEY (id);


--
-- Name: AuditLog AuditLog_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AuditLog"
    ADD CONSTRAINT "AuditLog_pkey" PRIMARY KEY (id);


--
-- Name: BloodworkAttachment BloodworkAttachment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BloodworkAttachment"
    ADD CONSTRAINT "BloodworkAttachment_pkey" PRIMARY KEY (id);


--
-- Name: BloodworkPanel BloodworkPanel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BloodworkPanel"
    ADD CONSTRAINT "BloodworkPanel_pkey" PRIMARY KEY (id);


--
-- Name: BloodworkResult BloodworkResult_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BloodworkResult"
    ADD CONSTRAINT "BloodworkResult_pkey" PRIMARY KEY (id);


--
-- Name: BuildWeekDayCompletion BuildWeekDayCompletion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BuildWeekDayCompletion"
    ADD CONSTRAINT "BuildWeekDayCompletion_pkey" PRIMARY KEY (id);


--
-- Name: BuildWeekDay BuildWeekDay_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BuildWeekDay"
    ADD CONSTRAINT "BuildWeekDay_pkey" PRIMARY KEY (id);


--
-- Name: BuildWeekEnrollment BuildWeekEnrollment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BuildWeekEnrollment"
    ADD CONSTRAINT "BuildWeekEnrollment_pkey" PRIMARY KEY (id);


--
-- Name: CalendarConnection CalendarConnection_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CalendarConnection"
    ADD CONSTRAINT "CalendarConnection_pkey" PRIMARY KEY (id);


--
-- Name: ChargeDispute ChargeDispute_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChargeDispute"
    ADD CONSTRAINT "ChargeDispute_pkey" PRIMARY KEY (id);


--
-- Name: ChargeRefund ChargeRefund_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChargeRefund"
    ADD CONSTRAINT "ChargeRefund_pkey" PRIMARY KEY (id);


--
-- Name: CheckIn CheckIn_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CheckIn"
    ADD CONSTRAINT "CheckIn_pkey" PRIMARY KEY (id);


--
-- Name: ChurnIntervention ChurnIntervention_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChurnIntervention"
    ADD CONSTRAINT "ChurnIntervention_pkey" PRIMARY KEY (id);


--
-- Name: ClientAssetGrant ClientAssetGrant_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ClientAssetGrant"
    ADD CONSTRAINT "ClientAssetGrant_pkey" PRIMARY KEY (id);


--
-- Name: ClientCoachConsent ClientCoachConsent_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ClientCoachConsent"
    ADD CONSTRAINT "ClientCoachConsent_pkey" PRIMARY KEY (id);


--
-- Name: ClientOutcome ClientOutcome_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ClientOutcome"
    ADD CONSTRAINT "ClientOutcome_pkey" PRIMARY KEY (id);


--
-- Name: ClientPurchase ClientPurchase_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ClientPurchase"
    ADD CONSTRAINT "ClientPurchase_pkey" PRIMARY KEY (id);


--
-- Name: ClientSignal ClientSignal_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ClientSignal"
    ADD CONSTRAINT "ClientSignal_pkey" PRIMARY KEY (id);


--
-- Name: ClientWorkoutAssignmentSnapshot ClientWorkoutAssignmentSnapshot_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ClientWorkoutAssignmentSnapshot"
    ADD CONSTRAINT "ClientWorkoutAssignmentSnapshot_pkey" PRIMARY KEY (id);


--
-- Name: ClientWorkoutAssignment ClientWorkoutAssignment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ClientWorkoutAssignment"
    ADD CONSTRAINT "ClientWorkoutAssignment_pkey" PRIMARY KEY (id);


--
-- Name: CoachAIBudget CoachAIBudget_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachAIBudget"
    ADD CONSTRAINT "CoachAIBudget_pkey" PRIMARY KEY (id);


--
-- Name: CoachAlert CoachAlert_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachAlert"
    ADD CONSTRAINT "CoachAlert_pkey" PRIMARY KEY (id);


--
-- Name: CoachAvailabilityOverride CoachAvailabilityOverride_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachAvailabilityOverride"
    ADD CONSTRAINT "CoachAvailabilityOverride_pkey" PRIMARY KEY (id);


--
-- Name: CoachAvailability CoachAvailability_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachAvailability"
    ADD CONSTRAINT "CoachAvailability_pkey" PRIMARY KEY (id);


--
-- Name: CoachBriefPreferences CoachBriefPreferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachBriefPreferences"
    ADD CONSTRAINT "CoachBriefPreferences_pkey" PRIMARY KEY (id);


--
-- Name: CoachBriefPushLedger CoachBriefPushLedger_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachBriefPushLedger"
    ADD CONSTRAINT "CoachBriefPushLedger_pkey" PRIMARY KEY (id);


--
-- Name: CoachBrief CoachBrief_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachBrief"
    ADD CONSTRAINT "CoachBrief_pkey" PRIMARY KEY (id);


--
-- Name: CoachCreditPackPurchase CoachCreditPackPurchase_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachCreditPackPurchase"
    ADD CONSTRAINT "CoachCreditPackPurchase_pkey" PRIMARY KEY (id);


--
-- Name: CoachCrmIntegration CoachCrmIntegration_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachCrmIntegration"
    ADD CONSTRAINT "CoachCrmIntegration_pkey" PRIMARY KEY (id);


--
-- Name: CoachDailyLog CoachDailyLog_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachDailyLog"
    ADD CONSTRAINT "CoachDailyLog_pkey" PRIMARY KEY (id);


--
-- Name: CoachEffectivenessScore CoachEffectivenessScore_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachEffectivenessScore"
    ADD CONSTRAINT "CoachEffectivenessScore_pkey" PRIMARY KEY (id);


--
-- Name: CoachGuideline CoachGuideline_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachGuideline"
    ADD CONSTRAINT "CoachGuideline_pkey" PRIMARY KEY (id);


--
-- Name: CoachLandingLead CoachLandingLead_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachLandingLead"
    ADD CONSTRAINT "CoachLandingLead_pkey" PRIMARY KEY (id);


--
-- Name: CoachLandingPageSection CoachLandingPageSection_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachLandingPageSection"
    ADD CONSTRAINT "CoachLandingPageSection_pkey" PRIMARY KEY (id);


--
-- Name: CoachLandingPageView CoachLandingPageView_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachLandingPageView"
    ADD CONSTRAINT "CoachLandingPageView_pkey" PRIMARY KEY (id);


--
-- Name: CoachLandingPage CoachLandingPage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachLandingPage"
    ADD CONSTRAINT "CoachLandingPage_pkey" PRIMARY KEY (id);


--
-- Name: CoachMediaAsset CoachMediaAsset_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachMediaAsset"
    ADD CONSTRAINT "CoachMediaAsset_pkey" PRIMARY KEY (id);


--
-- Name: CoachMessage CoachMessage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachMessage"
    ADD CONSTRAINT "CoachMessage_pkey" PRIMARY KEY (id);


--
-- Name: CoachNudge CoachNudge_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachNudge"
    ADD CONSTRAINT "CoachNudge_pkey" PRIMARY KEY (id);


--
-- Name: CoachOffer CoachOffer_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachOffer"
    ADD CONSTRAINT "CoachOffer_pkey" PRIMARY KEY (id);


--
-- Name: CoachOnboardingProgress CoachOnboardingProgress_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachOnboardingProgress"
    ADD CONSTRAINT "CoachOnboardingProgress_pkey" PRIMARY KEY (id);


--
-- Name: CoachPackageContent CoachPackageContent_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachPackageContent"
    ADD CONSTRAINT "CoachPackageContent_pkey" PRIMARY KEY (id);


--
-- Name: CoachPackage CoachPackage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachPackage"
    ADD CONSTRAINT "CoachPackage_pkey" PRIMARY KEY (id);


--
-- Name: CoachProfile CoachProfile_invite_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachProfile"
    ADD CONSTRAINT "CoachProfile_invite_code_key" UNIQUE (invite_code);


--
-- Name: CoachProfile CoachProfile_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachProfile"
    ADD CONSTRAINT "CoachProfile_pkey" PRIMARY KEY (id);


--
-- Name: CoachProfile CoachProfile_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachProfile"
    ADD CONSTRAINT "CoachProfile_user_id_key" UNIQUE (user_id);


--
-- Name: CoachSubscription CoachSubscription_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachSubscription"
    ADD CONSTRAINT "CoachSubscription_pkey" PRIMARY KEY (id);


--
-- Name: CoachingSession CoachingSession_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachingSession"
    ADD CONSTRAINT "CoachingSession_pkey" PRIMARY KEY (id);


--
-- Name: CommunityWin CommunityWin_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CommunityWin"
    ADD CONSTRAINT "CommunityWin_pkey" PRIMARY KEY (id);


--
-- Name: ConnectAccount ConnectAccount_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ConnectAccount"
    ADD CONSTRAINT "ConnectAccount_pkey" PRIMARY KEY (id);


--
-- Name: ConnectCustomer ConnectCustomer_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ConnectCustomer"
    ADD CONSTRAINT "ConnectCustomer_pkey" PRIMARY KEY (id);


--
-- Name: ConnectTransfer ConnectTransfer_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ConnectTransfer"
    ADD CONSTRAINT "ConnectTransfer_pkey" PRIMARY KEY (id);


--
-- Name: ContractAuditEvent ContractAuditEvent_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ContractAuditEvent"
    ADD CONSTRAINT "ContractAuditEvent_pkey" PRIMARY KEY (id);


--
-- Name: ContractEnvelope ContractEnvelope_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ContractEnvelope"
    ADD CONSTRAINT "ContractEnvelope_pkey" PRIMARY KEY (id);


--
-- Name: ContractTemplate ContractTemplate_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ContractTemplate"
    ADD CONSTRAINT "ContractTemplate_pkey" PRIMARY KEY (id);


--
-- Name: ConversationReview ConversationReview_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ConversationReview"
    ADD CONSTRAINT "ConversationReview_pkey" PRIMARY KEY (id);


--
-- Name: DailyMealPlanAssignment DailyMealPlanAssignment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DailyMealPlanAssignment"
    ADD CONSTRAINT "DailyMealPlanAssignment_pkey" PRIMARY KEY (id);


--
-- Name: DailyMealPlanSlot DailyMealPlanSlot_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DailyMealPlanSlot"
    ADD CONSTRAINT "DailyMealPlanSlot_pkey" PRIMARY KEY (id);


--
-- Name: DailyMealPlan DailyMealPlan_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DailyMealPlan"
    ADD CONSTRAINT "DailyMealPlan_pkey" PRIMARY KEY (id);


--
-- Name: DataExportRequest DataExportRequest_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DataExportRequest"
    ADD CONSTRAINT "DataExportRequest_pkey" PRIMARY KEY (id);


--
-- Name: DiagnosticSubmission DiagnosticSubmission_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DiagnosticSubmission"
    ADD CONSTRAINT "DiagnosticSubmission_pkey" PRIMARY KEY (id);


--
-- Name: DripResolverMarker DripResolverMarker_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DripResolverMarker"
    ADD CONSTRAINT "DripResolverMarker_pkey" PRIMARY KEY (id);


--
-- Name: DunningAttempt DunningAttempt_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DunningAttempt"
    ADD CONSTRAINT "DunningAttempt_pkey" PRIMARY KEY (id);


--
-- Name: DunningState DunningState_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DunningState"
    ADD CONSTRAINT "DunningState_pkey" PRIMARY KEY (id);


--
-- Name: EmailSendLog EmailSendLog_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."EmailSendLog"
    ADD CONSTRAINT "EmailSendLog_pkey" PRIMARY KEY (id);


--
-- Name: ExerciseCatalogItem ExerciseCatalogItem_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ExerciseCatalogItem"
    ADD CONSTRAINT "ExerciseCatalogItem_pkey" PRIMARY KEY (id);


--
-- Name: ExerciseSet ExerciseSet_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ExerciseSet"
    ADD CONSTRAINT "ExerciseSet_pkey" PRIMARY KEY (id);


--
-- Name: ExtensionPairCode ExtensionPairCode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ExtensionPairCode"
    ADD CONSTRAINT "ExtensionPairCode_pkey" PRIMARY KEY (id);


--
-- Name: FastingWindow FastingWindow_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."FastingWindow"
    ADD CONSTRAINT "FastingWindow_pkey" PRIMARY KEY (id);


--
-- Name: FeePolicy FeePolicy_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."FeePolicy"
    ADD CONSTRAINT "FeePolicy_pkey" PRIMARY KEY (id);


--
-- Name: FoodItem FoodItem_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."FoodItem"
    ADD CONSTRAINT "FoodItem_pkey" PRIMARY KEY (id);


--
-- Name: GuestCheckout GuestCheckout_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."GuestCheckout"
    ADD CONSTRAINT "GuestCheckout_pkey" PRIMARY KEY (id);


--
-- Name: HabitLog HabitLog_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."HabitLog"
    ADD CONSTRAINT "HabitLog_pkey" PRIMARY KEY (id);


--
-- Name: Habit Habit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Habit"
    ADD CONSTRAINT "Habit_pkey" PRIMARY KEY (id);


--
-- Name: HolisticInsightCache HolisticInsightCache_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."HolisticInsightCache"
    ADD CONSTRAINT "HolisticInsightCache_pkey" PRIMARY KEY (id);


--
-- Name: InviteCode InviteCode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InviteCode"
    ADD CONSTRAINT "InviteCode_pkey" PRIMARY KEY (id);


--
-- Name: Invoice Invoice_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Invoice"
    ADD CONSTRAINT "Invoice_pkey" PRIMARY KEY (id);


--
-- Name: JobListing JobListing_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."JobListing"
    ADD CONSTRAINT "JobListing_pkey" PRIMARY KEY (id);


--
-- Name: LessonCompletion LessonCompletion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."LessonCompletion"
    ADD CONSTRAINT "LessonCompletion_pkey" PRIMARY KEY (id);


--
-- Name: Lesson Lesson_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Lesson"
    ADD CONSTRAINT "Lesson_pkey" PRIMARY KEY (id);


--
-- Name: LoggedFoodEntry LoggedFoodEntry_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."LoggedFoodEntry"
    ADD CONSTRAINT "LoggedFoodEntry_pkey" PRIMARY KEY (id);


--
-- Name: MacroTarget MacroTarget_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MacroTarget"
    ADD CONSTRAINT "MacroTarget_pkey" PRIMARY KEY (id);


--
-- Name: MarketplaceAbuseSignal MarketplaceAbuseSignal_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MarketplaceAbuseSignal"
    ADD CONSTRAINT "MarketplaceAbuseSignal_pkey" PRIMARY KEY (id);


--
-- Name: MarketplaceConnectEvent MarketplaceConnectEvent_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MarketplaceConnectEvent"
    ADD CONSTRAINT "MarketplaceConnectEvent_pkey" PRIMARY KEY (stripe_event_id);


--
-- Name: MarketplaceMutationIdempotency MarketplaceMutationIdempotency_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MarketplaceMutationIdempotency"
    ADD CONSTRAINT "MarketplaceMutationIdempotency_pkey" PRIMARY KEY (id);


--
-- Name: MealPlan MealPlan_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MealPlan"
    ADD CONSTRAINT "MealPlan_pkey" PRIMARY KEY (id);


--
-- Name: MealTemplate MealTemplate_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MealTemplate"
    ADD CONSTRAINT "MealTemplate_pkey" PRIMARY KEY (id);


--
-- Name: MessageDraft MessageDraft_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MessageDraft"
    ADD CONSTRAINT "MessageDraft_pkey" PRIMARY KEY (id);


--
-- Name: MessageReport MessageReport_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MessageReport"
    ADD CONSTRAINT "MessageReport_pkey" PRIMARY KEY (id);


--
-- Name: Message Message_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Message"
    ADD CONSTRAINT "Message_pkey" PRIMARY KEY (id);


--
-- Name: MuxProcessedEvent MuxProcessedEvent_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MuxProcessedEvent"
    ADD CONSTRAINT "MuxProcessedEvent_pkey" PRIMARY KEY (mux_event_id);


--
-- Name: NotificationDeliveryLog NotificationDeliveryLog_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NotificationDeliveryLog"
    ADD CONSTRAINT "NotificationDeliveryLog_pkey" PRIMARY KEY (id);


--
-- Name: NotificationDigestLog NotificationDigestLog_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NotificationDigestLog"
    ADD CONSTRAINT "NotificationDigestLog_pkey" PRIMARY KEY (id);


--
-- Name: NotificationDigestLog NotificationDigestLog_user_digest_window_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NotificationDigestLog"
    ADD CONSTRAINT "NotificationDigestLog_user_digest_window_key" UNIQUE (user_id, digest_kind, window_date);


--
-- Name: NotificationPreferences NotificationPreferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NotificationPreferences"
    ADD CONSTRAINT "NotificationPreferences_pkey" PRIMARY KEY (id);


--
-- Name: Notification Notification_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Notification"
    ADD CONSTRAINT "Notification_pkey" PRIMARY KEY (id);


--
-- Name: NudgeLog NudgeLog_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NudgeLog"
    ADD CONSTRAINT "NudgeLog_pkey" PRIMARY KEY (id);


--
-- Name: PartialRefundDecision PartialRefundDecision_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PartialRefundDecision"
    ADD CONSTRAINT "PartialRefundDecision_pkey" PRIMARY KEY (id);


--
-- Name: PaymentFailure PaymentFailure_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PaymentFailure"
    ADD CONSTRAINT "PaymentFailure_pkey" PRIMARY KEY (id);


--
-- Name: PaymentFailure PaymentFailure_stripe_event_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PaymentFailure"
    ADD CONSTRAINT "PaymentFailure_stripe_event_id_key" UNIQUE (stripe_event_id);


--
-- Name: PaymentRecoveryToken PaymentRecoveryToken_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PaymentRecoveryToken"
    ADD CONSTRAINT "PaymentRecoveryToken_pkey" PRIMARY KEY (id);


--
-- Name: PaymentReminder PaymentReminder_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PaymentReminder"
    ADD CONSTRAINT "PaymentReminder_pkey" PRIMARY KEY (id);


--
-- Name: PayoutMethod PayoutMethod_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PayoutMethod"
    ADD CONSTRAINT "PayoutMethod_pkey" PRIMARY KEY (id);


--
-- Name: PayoutSnapshot PayoutSnapshot_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PayoutSnapshot"
    ADD CONSTRAINT "PayoutSnapshot_pkey" PRIMARY KEY (id);


--
-- Name: Person Person_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Person"
    ADD CONSTRAINT "Person_pkey" PRIMARY KEY (id);


--
-- Name: PtmPrediction PtmPrediction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PtmPrediction"
    ADD CONSTRAINT "PtmPrediction_pkey" PRIMARY KEY (id);


--
-- Name: PurchaseFanout PurchaseFanout_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PurchaseFanout"
    ADD CONSTRAINT "PurchaseFanout_pkey" PRIMARY KEY (id);


--
-- Name: ReconciliationSnapshot ReconciliationSnapshot_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ReconciliationSnapshot"
    ADD CONSTRAINT "ReconciliationSnapshot_pkey" PRIMARY KEY (id);


--
-- Name: RomanMessage RomanMessage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RomanMessage"
    ADD CONSTRAINT "RomanMessage_pkey" PRIMARY KEY (id);


--
-- Name: RomanSession RomanSession_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RomanSession"
    ADD CONSTRAINT "RomanSession_pkey" PRIMARY KEY (id);


--
-- Name: RoutineExercise RoutineExercise_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RoutineExercise"
    ADD CONSTRAINT "RoutineExercise_pkey" PRIMARY KEY (id);


--
-- Name: ScheduledDrop ScheduledDrop_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ScheduledDrop"
    ADD CONSTRAINT "ScheduledDrop_pkey" PRIMARY KEY (id);


--
-- Name: ScoutImportCompletion ScoutImportCompletion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ScoutImportCompletion"
    ADD CONSTRAINT "ScoutImportCompletion_pkey" PRIMARY KEY (id);


--
-- Name: ScoutImport ScoutImport_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ScoutImport"
    ADD CONSTRAINT "ScoutImport_pkey" PRIMARY KEY (id);


--
-- Name: ScoutIngestEntity ScoutIngestEntity_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ScoutIngestEntity"
    ADD CONSTRAINT "ScoutIngestEntity_pkey" PRIMARY KEY (id);


--
-- Name: ScoutProgressSnapshot ScoutProgressSnapshot_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ScoutProgressSnapshot"
    ADD CONSTRAINT "ScoutProgressSnapshot_pkey" PRIMARY KEY (id);


--
-- Name: ScoutReconstructedEntity ScoutReconstructedEntity_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ScoutReconstructedEntity"
    ADD CONSTRAINT "ScoutReconstructedEntity_pkey" PRIMARY KEY (id);


--
-- Name: ScoutReconstructionLedger ScoutReconstructionLedger_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ScoutReconstructionLedger"
    ADD CONSTRAINT "ScoutReconstructionLedger_pkey" PRIMARY KEY (id);


--
-- Name: SessionParticipant SessionParticipant_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SessionParticipant"
    ADD CONSTRAINT "SessionParticipant_pkey" PRIMARY KEY (id);


--
-- Name: SessionType SessionType_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SessionType"
    ADD CONSTRAINT "SessionType_pkey" PRIMARY KEY (id);


--
-- Name: SplitLedgerEntry SplitLedgerEntry_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SplitLedgerEntry"
    ADD CONSTRAINT "SplitLedgerEntry_pkey" PRIMARY KEY (id);


--
-- Name: StripeProcessedEvent StripeProcessedEvent_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."StripeProcessedEvent"
    ADD CONSTRAINT "StripeProcessedEvent_pkey" PRIMARY KEY (stripe_event_id);


--
-- Name: SubCoachAssignment SubCoachAssignment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SubCoachAssignment"
    ADD CONSTRAINT "SubCoachAssignment_pkey" PRIMARY KEY (id);


--
-- Name: SubCoachInvite SubCoachInvite_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SubCoachInvite"
    ADD CONSTRAINT "SubCoachInvite_pkey" PRIMARY KEY (id);


--
-- Name: SubCoachMutationIdempotency SubCoachMutationIdempotency_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SubCoachMutationIdempotency"
    ADD CONSTRAINT "SubCoachMutationIdempotency_pkey" PRIMARY KEY (id);


--
-- Name: TeamAuditEvent TeamAuditEvent_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TeamAuditEvent"
    ADD CONSTRAINT "TeamAuditEvent_pkey" PRIMARY KEY (id);


--
-- Name: TeamProfile TeamProfile_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TeamProfile"
    ADD CONSTRAINT "TeamProfile_pkey" PRIMARY KEY (id);


--
-- Name: TeamSubCoachAssignment TeamSubCoachAssignment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TeamSubCoachAssignment"
    ADD CONSTRAINT "TeamSubCoachAssignment_pkey" PRIMARY KEY (id);


--
-- Name: UserAIQuota UserAIQuota_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserAIQuota"
    ADD CONSTRAINT "UserAIQuota_pkey" PRIMARY KEY (id);


--
-- Name: UserBlock UserBlock_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserBlock"
    ADD CONSTRAINT "UserBlock_pkey" PRIMARY KEY (id);


--
-- Name: UserProfile UserProfile_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserProfile"
    ADD CONSTRAINT "UserProfile_pkey" PRIMARY KEY (id);


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: WearableConnection WearableConnection_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WearableConnection"
    ADD CONSTRAINT "WearableConnection_pkey" PRIMARY KEY (id);


--
-- Name: WearableInsightCache WearableInsightCache_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WearableInsightCache"
    ADD CONSTRAINT "WearableInsightCache_pkey" PRIMARY KEY (id);


--
-- Name: WearableMetricDef WearableMetricDef_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WearableMetricDef"
    ADD CONSTRAINT "WearableMetricDef_pkey" PRIMARY KEY (metric);


--
-- Name: WearableProcessedEvent WearableProcessedEvent_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WearableProcessedEvent"
    ADD CONSTRAINT "WearableProcessedEvent_pkey" PRIMARY KEY (provider, provider_event_id);


--
-- Name: WearableSample WearableSample_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WearableSample"
    ADD CONSTRAINT "WearableSample_pkey" PRIMARY KEY (id);


--
-- Name: WearableUserMetricPreference WearableUserMetricPreference_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WearableUserMetricPreference"
    ADD CONSTRAINT "WearableUserMetricPreference_pkey" PRIMARY KEY (id);


--
-- Name: WeightLog WeightLog_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WeightLog"
    ADD CONSTRAINT "WeightLog_pkey" PRIMARY KEY (id);


--
-- Name: WorkoutBuilderIdempotencyKey WorkoutBuilderIdempotencyKey_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkoutBuilderIdempotencyKey"
    ADD CONSTRAINT "WorkoutBuilderIdempotencyKey_pkey" PRIMARY KEY (id);


--
-- Name: WorkoutPlanExercise WorkoutPlanExercise_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkoutPlanExercise"
    ADD CONSTRAINT "WorkoutPlanExercise_pkey" PRIMARY KEY (id);


--
-- Name: WorkoutPlanRevision WorkoutPlanRevision_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkoutPlanRevision"
    ADD CONSTRAINT "WorkoutPlanRevision_pkey" PRIMARY KEY (id);


--
-- Name: WorkoutPlan WorkoutPlan_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkoutPlan"
    ADD CONSTRAINT "WorkoutPlan_pkey" PRIMARY KEY (id);


--
-- Name: WorkoutProgramRevision WorkoutProgramRevision_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkoutProgramRevision"
    ADD CONSTRAINT "WorkoutProgramRevision_pkey" PRIMARY KEY (id);


--
-- Name: WorkoutProgram WorkoutProgram_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkoutProgram"
    ADD CONSTRAINT "WorkoutProgram_pkey" PRIMARY KEY (id);


--
-- Name: WorkoutRoutine WorkoutRoutine_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkoutRoutine"
    ADD CONSTRAINT "WorkoutRoutine_pkey" PRIMARY KEY (id);


--
-- Name: WorkoutSession WorkoutSession_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkoutSession"
    ADD CONSTRAINT "WorkoutSession_pkey" PRIMARY KEY (id);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: coach_first_payment_notification coach_first_payment_notification_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coach_first_payment_notification
    ADD CONSTRAINT coach_first_payment_notification_pkey PRIMARY KEY (id);


--
-- Name: coach_ltv_peak coach_ltv_peak_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coach_ltv_peak
    ADD CONSTRAINT coach_ltv_peak_pkey PRIMARY KEY (id);


--
-- Name: community_challenge_participations community_challenge_participations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_challenge_participations
    ADD CONSTRAINT community_challenge_participations_pkey PRIMARY KEY (id);


--
-- Name: community_challenges community_challenges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_challenges
    ADD CONSTRAINT community_challenges_pkey PRIMARY KEY (id);


--
-- Name: community_classroom_media_assets community_classroom_media_assets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_classroom_media_assets
    ADD CONSTRAINT community_classroom_media_assets_pkey PRIMARY KEY (id);


--
-- Name: community_classroom_posts community_classroom_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_classroom_posts
    ADD CONSTRAINT community_classroom_posts_pkey PRIMARY KEY (id);


--
-- Name: community_cohorts community_cohorts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_cohorts
    ADD CONSTRAINT community_cohorts_pkey PRIMARY KEY (id);


--
-- Name: community_event_rsvps community_event_rsvps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_event_rsvps
    ADD CONSTRAINT community_event_rsvps_pkey PRIMARY KEY (id);


--
-- Name: community_events community_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_events
    ADD CONSTRAINT community_events_pkey PRIMARY KEY (id);


--
-- Name: community_memberships community_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_memberships
    ADD CONSTRAINT community_memberships_pkey PRIMARY KEY (id);


--
-- Name: community_messages community_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_messages
    ADD CONSTRAINT community_messages_pkey PRIMARY KEY (id, created_at);


--
-- Name: community_messages_2026_12 community_messages_2026_12_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_messages_2026_12
    ADD CONSTRAINT community_messages_2026_12_pkey PRIMARY KEY (id, created_at);


--
-- Name: community_messages_2027_01 community_messages_2027_01_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_messages_2027_01
    ADD CONSTRAINT community_messages_2027_01_pkey PRIMARY KEY (id, created_at);


--
-- Name: community_messages_2027_02 community_messages_2027_02_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_messages_2027_02
    ADD CONSTRAINT community_messages_2027_02_pkey PRIMARY KEY (id, created_at);


--
-- Name: community_messages_2028_03 community_messages_2028_03_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_messages_2028_03
    ADD CONSTRAINT community_messages_2028_03_pkey PRIMARY KEY (id, created_at);


--
-- Name: community_messages_default community_messages_default_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_messages_default
    ADD CONSTRAINT community_messages_default_pkey PRIMARY KEY (id, created_at);


--
-- Name: community_moderation_actions community_moderation_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_moderation_actions
    ADD CONSTRAINT community_moderation_actions_pkey PRIMARY KEY (id);


--
-- Name: community_posts community_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_posts
    ADD CONSTRAINT community_posts_pkey PRIMARY KEY (id);


--
-- Name: community_responses community_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_responses
    ADD CONSTRAINT community_responses_pkey PRIMARY KEY (id);


--
-- Name: community_search_entries community_search_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_search_entries
    ADD CONSTRAINT community_search_entries_pkey PRIMARY KEY (id);


--
-- Name: community_voice_notes community_voice_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_voice_notes
    ADD CONSTRAINT community_voice_notes_pkey PRIMARY KEY (id);


--
-- Name: community_wearable_prompt_sources community_wearable_prompt_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_wearable_prompt_sources
    ADD CONSTRAINT community_wearable_prompt_sources_pkey PRIMARY KEY (id);


--
-- Name: community_wearable_prompts community_wearable_prompts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_wearable_prompts
    ADD CONSTRAINT community_wearable_prompts_pkey PRIMARY KEY (id);


--
-- Name: community_workspaces community_workspaces_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_workspaces
    ADD CONSTRAINT community_workspaces_pkey PRIMARY KEY (id);


--
-- Name: data_export_request data_export_request_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_export_request
    ADD CONSTRAINT data_export_request_pkey PRIMARY KEY (id);


--
-- Name: deletion_audit deletion_audit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deletion_audit
    ADD CONSTRAINT deletion_audit_pkey PRIMARY KEY (id);


--
-- Name: recent_auth_nonce recent_auth_nonce_hmac_suffix_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recent_auth_nonce
    ADD CONSTRAINT recent_auth_nonce_hmac_suffix_key UNIQUE (hmac_suffix);


--
-- Name: recent_auth_nonce recent_auth_nonce_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recent_auth_nonce
    ADD CONSTRAINT recent_auth_nonce_pkey PRIMARY KEY (id);


--
-- Name: secret_rotation_log secret_rotation_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.secret_rotation_log
    ADD CONSTRAINT secret_rotation_log_pkey PRIMARY KEY (id);


--
-- Name: water_logs water_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.water_logs
    ADD CONSTRAINT water_logs_pkey PRIMARY KEY (id);


--
-- Name: AICallLog_capability_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "AICallLog_capability_createdAt_idx" ON public."AICallLog" USING btree (capability, "createdAt");


--
-- Name: AICallLog_coachId_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "AICallLog_coachId_createdAt_idx" ON public."AICallLog" USING btree ("coachId", "createdAt");


--
-- Name: AIDraft_coachId_clientId_type_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "AIDraft_coachId_clientId_type_status_idx" ON public."AIDraft" USING btree ("coachId", "clientId", type, status);


--
-- Name: ActivityEvent_client_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ActivityEvent_client_id_created_at_idx" ON public."ActivityEvent" USING btree (client_id, created_at);


--
-- Name: ActivityEvent_coach_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ActivityEvent_coach_id_created_at_idx" ON public."ActivityEvent" USING btree (coach_id, created_at);


--
-- Name: ActivityEvent_type_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ActivityEvent_type_created_at_idx" ON public."ActivityEvent" USING btree (type, created_at);


--
-- Name: AiActionDraft_capability_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "AiActionDraft_capability_status_idx" ON public."AiActionDraft" USING btree (capability, status);


--
-- Name: AiActionDraft_requester_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "AiActionDraft_requester_id_created_at_idx" ON public."AiActionDraft" USING btree (requester_id, created_at);


--
-- Name: AiActionDraft_status_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "AiActionDraft_status_created_at_idx" ON public."AiActionDraft" USING btree (status, created_at);


--
-- Name: AiActionDraft_subject_user_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "AiActionDraft_subject_user_id_created_at_idx" ON public."AiActionDraft" USING btree (subject_user_id, created_at);


--
-- Name: AiActionDraft_tenant_coach_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "AiActionDraft_tenant_coach_id_created_at_idx" ON public."AiActionDraft" USING btree (tenant_coach_id, created_at);


--
-- Name: AiRequestAudit_approval_draft_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "AiRequestAudit_approval_draft_id_key" ON public."AiRequestAudit" USING btree (approval_draft_id);


--
-- Name: AiRequestAudit_approval_status_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "AiRequestAudit_approval_status_created_at_idx" ON public."AiRequestAudit" USING btree (approval_status, created_at);


--
-- Name: AiRequestAudit_capability_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "AiRequestAudit_capability_created_at_idx" ON public."AiRequestAudit" USING btree (capability, created_at);


--
-- Name: AiRequestAudit_request_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "AiRequestAudit_request_id_key" ON public."AiRequestAudit" USING btree (request_id);


--
-- Name: AiRequestAudit_requester_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "AiRequestAudit_requester_id_created_at_idx" ON public."AiRequestAudit" USING btree (requester_id, created_at);


--
-- Name: AiRequestAudit_subject_user_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "AiRequestAudit_subject_user_id_created_at_idx" ON public."AiRequestAudit" USING btree (subject_user_id, created_at);


--
-- Name: AiRequestAudit_tenant_coach_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "AiRequestAudit_tenant_coach_id_created_at_idx" ON public."AiRequestAudit" USING btree (tenant_coach_id, created_at);


--
-- Name: AiRoadmap_submission_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "AiRoadmap_submission_id_idx" ON public."AiRoadmap" USING btree (submission_id);


--
-- Name: AiRoadmap_submission_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "AiRoadmap_submission_id_key" ON public."AiRoadmap" USING btree (submission_id);


--
-- Name: Applicant_email_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Applicant_email_idx" ON public."Applicant" USING btree (email);


--
-- Name: Applicant_user_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Applicant_user_id_key" ON public."Applicant" USING btree (user_id);


--
-- Name: Application_applicant_user_id_created_at_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Application_applicant_user_id_created_at_id_idx" ON public."Application" USING btree (applicant_user_id, created_at, id);


--
-- Name: Application_applicant_user_id_listing_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Application_applicant_user_id_listing_id_key" ON public."Application" USING btree (applicant_user_id, listing_id);


--
-- Name: Application_hirer_id_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Application_hirer_id_status_idx" ON public."Application" USING btree (hirer_id, status);


--
-- Name: Application_idempotency_key_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Application_idempotency_key_key" ON public."Application" USING btree (idempotency_key);


--
-- Name: Application_listing_id_status_created_at_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Application_listing_id_status_created_at_id_idx" ON public."Application" USING btree (listing_id, status, created_at, id);


--
-- Name: AuditLog_action_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "AuditLog_action_created_at_idx" ON public."AuditLog" USING btree (action, created_at);


--
-- Name: AuditLog_actor_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "AuditLog_actor_id_created_at_idx" ON public."AuditLog" USING btree (actor_id, created_at);


--
-- Name: AuditLog_target_user_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "AuditLog_target_user_id_created_at_idx" ON public."AuditLog" USING btree (target_user_id, created_at);


--
-- Name: AuditLog_tenant_coach_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "AuditLog_tenant_coach_id_created_at_idx" ON public."AuditLog" USING btree (tenant_coach_id, created_at);


--
-- Name: BloodworkAttachment_panel_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BloodworkAttachment_panel_id_idx" ON public."BloodworkAttachment" USING btree (panel_id);


--
-- Name: BloodworkAttachment_scan_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BloodworkAttachment_scan_status_idx" ON public."BloodworkAttachment" USING btree (scan_status);


--
-- Name: BloodworkPanel_client_id_collection_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BloodworkPanel_client_id_collection_date_idx" ON public."BloodworkPanel" USING btree (client_id, collection_date);


--
-- Name: BloodworkPanel_coach_id_review_state_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BloodworkPanel_coach_id_review_state_idx" ON public."BloodworkPanel" USING btree (coach_id, review_state);


--
-- Name: BloodworkPanel_is_stale_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BloodworkPanel_is_stale_idx" ON public."BloodworkPanel" USING btree (is_stale);


--
-- Name: BloodworkPanel_review_state_submitted_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BloodworkPanel_review_state_submitted_at_idx" ON public."BloodworkPanel" USING btree (review_state, submitted_at);


--
-- Name: BloodworkResult_marker_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BloodworkResult_marker_name_idx" ON public."BloodworkResult" USING btree (marker_name);


--
-- Name: BloodworkResult_panel_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BloodworkResult_panel_id_idx" ON public."BloodworkResult" USING btree (panel_id);


--
-- Name: BuildWeekDayCompletion_day_number_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BuildWeekDayCompletion_day_number_idx" ON public."BuildWeekDayCompletion" USING btree (day_number);


--
-- Name: BuildWeekDayCompletion_enrollment_day_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "BuildWeekDayCompletion_enrollment_day_key" ON public."BuildWeekDayCompletion" USING btree (enrollment_id, day_number);


--
-- Name: BuildWeekDay_day_number_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BuildWeekDay_day_number_idx" ON public."BuildWeekDay" USING btree (day_number);


--
-- Name: BuildWeekDay_day_number_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "BuildWeekDay_day_number_key" ON public."BuildWeekDay" USING btree (day_number);


--
-- Name: BuildWeekEnrollment_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BuildWeekEnrollment_status_idx" ON public."BuildWeekEnrollment" USING btree (status);


--
-- Name: BuildWeekEnrollment_user_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "BuildWeekEnrollment_user_id_key" ON public."BuildWeekEnrollment" USING btree (user_id);


--
-- Name: CalendarConnection_channel_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CalendarConnection_channel_id_key" ON public."CalendarConnection" USING btree (channel_id);


--
-- Name: CalendarConnection_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CalendarConnection_user_id_idx" ON public."CalendarConnection" USING btree (user_id);


--
-- Name: CalendarConnection_user_id_provider_external_account_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CalendarConnection_user_id_provider_external_account_id_key" ON public."CalendarConnection" USING btree (user_id, provider, external_account_id);


--
-- Name: ChargeDispute_purchase_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ChargeDispute_purchase_id_idx" ON public."ChargeDispute" USING btree (purchase_id);


--
-- Name: ChargeDispute_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ChargeDispute_status_idx" ON public."ChargeDispute" USING btree (status);


--
-- Name: ChargeDispute_stripe_charge_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ChargeDispute_stripe_charge_id_idx" ON public."ChargeDispute" USING btree (stripe_charge_id);


--
-- Name: ChargeDispute_stripe_dispute_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ChargeDispute_stripe_dispute_id_key" ON public."ChargeDispute" USING btree (stripe_dispute_id);


--
-- Name: ChargeRefund_purchase_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ChargeRefund_purchase_id_idx" ON public."ChargeRefund" USING btree (purchase_id);


--
-- Name: ChargeRefund_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ChargeRefund_status_idx" ON public."ChargeRefund" USING btree (status);


--
-- Name: ChargeRefund_stripe_charge_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ChargeRefund_stripe_charge_id_idx" ON public."ChargeRefund" USING btree (stripe_charge_id);


--
-- Name: ChargeRefund_stripe_refund_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ChargeRefund_stripe_refund_id_key" ON public."ChargeRefund" USING btree (stripe_refund_id);


--
-- Name: CheckIn_coach_id_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CheckIn_coach_id_date_idx" ON public."CheckIn" USING btree (coach_id, date);


--
-- Name: CheckIn_user_id_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CheckIn_user_id_date_idx" ON public."CheckIn" USING btree (user_id, date);


--
-- Name: CheckIn_user_id_date_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CheckIn_user_id_date_key" ON public."CheckIn" USING btree (user_id, date);


--
-- Name: ChurnIntervention_client_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ChurnIntervention_client_id_created_at_idx" ON public."ChurnIntervention" USING btree (client_id, created_at DESC);


--
-- Name: ChurnIntervention_coach_id_client_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ChurnIntervention_coach_id_client_id_idx" ON public."ChurnIntervention" USING btree (coach_id, client_id);


--
-- Name: ChurnIntervention_coach_id_status_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ChurnIntervention_coach_id_status_created_at_idx" ON public."ChurnIntervention" USING btree (coach_id, status, created_at DESC);


--
-- Name: ChurnIntervention_idempotency_key_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ChurnIntervention_idempotency_key_key" ON public."ChurnIntervention" USING btree (idempotency_key);


--
-- Name: ChurnIntervention_send_idempotency_key_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ChurnIntervention_send_idempotency_key_key" ON public."ChurnIntervention" USING btree (send_idempotency_key);


--
-- Name: ClientAssetGrant_client_id_media_asset_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ClientAssetGrant_client_id_media_asset_id_key" ON public."ClientAssetGrant" USING btree (client_id, media_asset_id);


--
-- Name: ClientAssetGrant_client_id_revoked_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ClientAssetGrant_client_id_revoked_at_idx" ON public."ClientAssetGrant" USING btree (client_id, revoked_at);


--
-- Name: ClientCoachConsent_client_coach_scope_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ClientCoachConsent_client_coach_scope_key" ON public."ClientCoachConsent" USING btree (client_id, coach_id, scope);


--
-- Name: ClientCoachConsent_client_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ClientCoachConsent_client_id_idx" ON public."ClientCoachConsent" USING btree (client_id);


--
-- Name: ClientCoachConsent_coach_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ClientCoachConsent_coach_id_idx" ON public."ClientCoachConsent" USING btree (coach_id);


--
-- Name: ClientOutcome_labelled_by_id_labelled_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ClientOutcome_labelled_by_id_labelled_at_idx" ON public."ClientOutcome" USING btree (labelled_by_id, labelled_at);


--
-- Name: ClientOutcome_outcome_type_labelled_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ClientOutcome_outcome_type_labelled_at_idx" ON public."ClientOutcome" USING btree (outcome_type, labelled_at);


--
-- Name: ClientOutcome_user_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ClientOutcome_user_id_key" ON public."ClientOutcome" USING btree (user_id);


--
-- Name: ClientPurchase_client_user_id_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ClientPurchase_client_user_id_status_idx" ON public."ClientPurchase" USING btree (client_user_id, status);


--
-- Name: ClientPurchase_coach_user_id_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ClientPurchase_coach_user_id_status_idx" ON public."ClientPurchase" USING btree (coach_user_id, status);


--
-- Name: ClientPurchase_contract_envelope_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ClientPurchase_contract_envelope_id_idx" ON public."ClientPurchase" USING btree (contract_envelope_id);


--
-- Name: ClientPurchase_contract_envelope_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ClientPurchase_contract_envelope_id_key" ON public."ClientPurchase" USING btree (contract_envelope_id);


--
-- Name: ClientPurchase_entitlement_active_access_expires_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ClientPurchase_entitlement_active_access_expires_at_idx" ON public."ClientPurchase" USING btree (entitlement_active, access_expires_at);


--
-- Name: ClientPurchase_idempotency_key_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ClientPurchase_idempotency_key_key" ON public."ClientPurchase" USING btree (idempotency_key);


--
-- Name: ClientPurchase_landing_page_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ClientPurchase_landing_page_id_idx" ON public."ClientPurchase" USING btree (landing_page_id);


--
-- Name: ClientPurchase_package_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ClientPurchase_package_id_idx" ON public."ClientPurchase" USING btree (package_id);


--
-- Name: ClientPurchase_stripe_checkout_session_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ClientPurchase_stripe_checkout_session_id_key" ON public."ClientPurchase" USING btree (stripe_checkout_session_id);


--
-- Name: ClientPurchase_stripe_subscription_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ClientPurchase_stripe_subscription_id_idx" ON public."ClientPurchase" USING btree (stripe_subscription_id);


--
-- Name: ClientPurchase_stripe_subscription_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ClientPurchase_stripe_subscription_id_key" ON public."ClientPurchase" USING btree (stripe_subscription_id);


--
-- Name: ClientSignal_signal_type_recorded_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ClientSignal_signal_type_recorded_at_idx" ON public."ClientSignal" USING btree (signal_type, recorded_at);


--
-- Name: ClientSignal_user_id_signal_type_recorded_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ClientSignal_user_id_signal_type_recorded_at_idx" ON public."ClientSignal" USING btree (user_id, signal_type, recorded_at);


--
-- Name: ClientWorkoutAssignmentSnapshot_assignment_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ClientWorkoutAssignmentSnapshot_assignment_id_key" ON public."ClientWorkoutAssignmentSnapshot" USING btree (assignment_id);


--
-- Name: ClientWorkoutAssignment_ai_draft_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ClientWorkoutAssignment_ai_draft_id_key" ON public."ClientWorkoutAssignment" USING btree (ai_draft_id);


--
-- Name: ClientWorkoutAssignment_assigned_by_coach_id_approved_by_co_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ClientWorkoutAssignment_assigned_by_coach_id_approved_by_co_idx" ON public."ClientWorkoutAssignment" USING btree (assigned_by_coach_id, approved_by_coach_at);


--
-- Name: ClientWorkoutAssignment_assigned_by_coach_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ClientWorkoutAssignment_assigned_by_coach_id_idx" ON public."ClientWorkoutAssignment" USING btree (assigned_by_coach_id);


--
-- Name: ClientWorkoutAssignment_client_id_scheduled_for_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ClientWorkoutAssignment_client_id_scheduled_for_idx" ON public."ClientWorkoutAssignment" USING btree (client_id, scheduled_for);


--
-- Name: ClientWorkoutAssignment_idempotency_key_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ClientWorkoutAssignment_idempotency_key_key" ON public."ClientWorkoutAssignment" USING btree (idempotency_key);


--
-- Name: ClientWorkoutAssignment_workout_plan_id_scheduled_for_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ClientWorkoutAssignment_workout_plan_id_scheduled_for_idx" ON public."ClientWorkoutAssignment" USING btree (workout_plan_id, scheduled_for);


--
-- Name: CoachAIBudget_coach_user_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CoachAIBudget_coach_user_id_key" ON public."CoachAIBudget" USING btree (coach_user_id);


--
-- Name: CoachAIBudget_period_end_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachAIBudget_period_end_idx" ON public."CoachAIBudget" USING btree (period_end);


--
-- Name: CoachAlert_client_id_alert_type_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachAlert_client_id_alert_type_created_at_idx" ON public."CoachAlert" USING btree (client_id, alert_type, created_at);


--
-- Name: CoachAlert_coach_id_acknowledged_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachAlert_coach_id_acknowledged_at_idx" ON public."CoachAlert" USING btree (coach_id, acknowledged_at);


--
-- Name: CoachAlert_coach_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachAlert_coach_id_created_at_idx" ON public."CoachAlert" USING btree (coach_id, created_at);


--
-- Name: CoachAvailabilityOverride_coach_date_start_kind_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CoachAvailabilityOverride_coach_date_start_kind_key" ON public."CoachAvailabilityOverride" USING btree (coach_id, date, start_minute, kind);


--
-- Name: CoachAvailabilityOverride_coach_id_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachAvailabilityOverride_coach_id_date_idx" ON public."CoachAvailabilityOverride" USING btree (coach_id, date);


--
-- Name: CoachAvailability_coach_id_day_of_week_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachAvailability_coach_id_day_of_week_idx" ON public."CoachAvailability" USING btree (coach_id, day_of_week);


--
-- Name: CoachBriefPreferences_coach_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CoachBriefPreferences_coach_id_key" ON public."CoachBriefPreferences" USING btree (coach_id);


--
-- Name: CoachBriefPreferences_enabled_notification_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachBriefPreferences_enabled_notification_time_idx" ON public."CoachBriefPreferences" USING btree (enabled, notification_time);


--
-- Name: CoachBriefPushLedger_coach_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CoachBriefPushLedger_coach_id_key" ON public."CoachBriefPushLedger" USING btree (coach_id);


--
-- Name: CoachBrief_coach_date_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CoachBrief_coach_date_key" ON public."CoachBrief" USING btree (coach_id, brief_date);


--
-- Name: CoachBrief_coach_id_brief_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachBrief_coach_id_brief_date_idx" ON public."CoachBrief" USING btree (coach_id, brief_date);


--
-- Name: CoachBrief_coach_id_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachBrief_coach_id_status_idx" ON public."CoachBrief" USING btree (coach_id, status);


--
-- Name: CoachBrief_coach_unread_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachBrief_coach_unread_idx" ON public."CoachBrief" USING btree (coach_id, brief_date DESC) WHERE (read_at IS NULL);


--
-- Name: CoachBrief_generating_lease_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachBrief_generating_lease_idx" ON public."CoachBrief" USING btree (generation_started_at) WHERE (status = 'generating'::text);


--
-- Name: CoachCreditPackPurchase_coach_user_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachCreditPackPurchase_coach_user_id_created_at_idx" ON public."CoachCreditPackPurchase" USING btree (coach_user_id, created_at);


--
-- Name: CoachCreditPackPurchase_free_grants_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachCreditPackPurchase_free_grants_idx" ON public."CoachCreditPackPurchase" USING btree (created_at DESC) WHERE (is_free_grant = true);


--
-- Name: CoachCreditPackPurchase_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachCreditPackPurchase_status_idx" ON public."CoachCreditPackPurchase" USING btree (status);


--
-- Name: CoachCreditPackPurchase_stripe_checkout_session_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CoachCreditPackPurchase_stripe_checkout_session_id_key" ON public."CoachCreditPackPurchase" USING btree (stripe_checkout_session_id);


--
-- Name: CoachCreditPackPurchase_stripe_invoice_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CoachCreditPackPurchase_stripe_invoice_id_key" ON public."CoachCreditPackPurchase" USING btree (stripe_invoice_id);


--
-- Name: CoachCrmIntegration_coach_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachCrmIntegration_coach_id_idx" ON public."CoachCrmIntegration" USING btree (coach_id);


--
-- Name: CoachCrmIntegration_coach_id_provider_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CoachCrmIntegration_coach_id_provider_key" ON public."CoachCrmIntegration" USING btree (coach_id, provider);


--
-- Name: CoachDailyLog_coach_id_log_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachDailyLog_coach_id_log_date_idx" ON public."CoachDailyLog" USING btree (coach_id, log_date);


--
-- Name: CoachDailyLog_coach_log_date_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CoachDailyLog_coach_log_date_key" ON public."CoachDailyLog" USING btree (coach_id, log_date);


--
-- Name: CoachEffectivenessScore_coach_id_computed_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachEffectivenessScore_coach_id_computed_at_idx" ON public."CoachEffectivenessScore" USING btree (coach_id, computed_at);


--
-- Name: CoachEffectivenessScore_computed_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachEffectivenessScore_computed_at_idx" ON public."CoachEffectivenessScore" USING btree (computed_at);


--
-- Name: CoachGuideline_client_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachGuideline_client_id_idx" ON public."CoachGuideline" USING btree (client_id);


--
-- Name: CoachGuideline_coach_id_client_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CoachGuideline_coach_id_client_id_key" ON public."CoachGuideline" USING btree (coach_id, client_id);


--
-- Name: CoachLandingLead_coach_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachLandingLead_coach_id_created_at_idx" ON public."CoachLandingLead" USING btree (coach_id, created_at DESC);


--
-- Name: CoachLandingLead_crm_sync_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachLandingLead_crm_sync_status_idx" ON public."CoachLandingLead" USING btree (crm_sync_status);


--
-- Name: CoachLandingLead_crm_sync_status_next_eligible_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachLandingLead_crm_sync_status_next_eligible_at_idx" ON public."CoachLandingLead" USING btree (crm_sync_status, next_eligible_at);


--
-- Name: CoachLandingLead_page_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachLandingLead_page_id_created_at_idx" ON public."CoachLandingLead" USING btree (page_id, created_at DESC);


--
-- Name: CoachLandingPageSection_page_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachLandingPageSection_page_id_idx" ON public."CoachLandingPageSection" USING btree (page_id);


--
-- Name: CoachLandingPageSection_page_id_order_index_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CoachLandingPageSection_page_id_order_index_key" ON public."CoachLandingPageSection" USING btree (page_id, order_index);


--
-- Name: CoachLandingPageView_page_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachLandingPageView_page_id_created_at_idx" ON public."CoachLandingPageView" USING btree (page_id, created_at DESC);


--
-- Name: CoachLandingPage_coach_id_slug_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CoachLandingPage_coach_id_slug_key" ON public."CoachLandingPage" USING btree (coach_id, slug);


--
-- Name: CoachLandingPage_coach_id_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachLandingPage_coach_id_status_idx" ON public."CoachLandingPage" USING btree (coach_id, status);


--
-- Name: CoachLandingPage_custom_domain_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CoachLandingPage_custom_domain_key" ON public."CoachLandingPage" USING btree (custom_domain);


--
-- Name: CoachLandingPage_status_published_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachLandingPage_status_published_at_idx" ON public."CoachLandingPage" USING btree (status, published_at);


--
-- Name: CoachMediaAsset_coach_id_archived_at_kind_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachMediaAsset_coach_id_archived_at_kind_idx" ON public."CoachMediaAsset" USING btree (coach_id, archived_at, kind);


--
-- Name: CoachMediaAsset_coach_id_archived_at_kind_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachMediaAsset_coach_id_archived_at_kind_status_idx" ON public."CoachMediaAsset" USING btree (coach_id, archived_at, kind, status);


--
-- Name: CoachMediaAsset_mux_upload_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CoachMediaAsset_mux_upload_id_key" ON public."CoachMediaAsset" USING btree (mux_upload_id);


--
-- Name: CoachMessage_ai_draft_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CoachMessage_ai_draft_id_key" ON public."CoachMessage" USING btree (ai_draft_id);


--
-- Name: CoachMessage_client_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachMessage_client_id_idx" ON public."CoachMessage" USING btree (client_id);


--
-- Name: CoachMessage_coach_id_client_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachMessage_coach_id_client_id_created_at_idx" ON public."CoachMessage" USING btree (coach_id, client_id, created_at);


--
-- Name: CoachMessage_coach_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachMessage_coach_id_idx" ON public."CoachMessage" USING btree (coach_id);


--
-- Name: CoachMessage_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachMessage_created_at_idx" ON public."CoachMessage" USING btree (created_at);


--
-- Name: CoachNudge_client_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachNudge_client_id_created_at_idx" ON public."CoachNudge" USING btree (client_id, created_at);


--
-- Name: CoachNudge_client_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachNudge_client_id_idx" ON public."CoachNudge" USING btree (client_id);


--
-- Name: CoachNudge_client_id_read_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachNudge_client_id_read_at_idx" ON public."CoachNudge" USING btree (client_id, read_at);


--
-- Name: CoachNudge_coach_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachNudge_coach_id_idx" ON public."CoachNudge" USING btree (coach_id);


--
-- Name: CoachNudge_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachNudge_created_at_idx" ON public."CoachNudge" USING btree (created_at);


--
-- Name: CoachOffer_application_id_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachOffer_application_id_status_idx" ON public."CoachOffer" USING btree (application_id, status);


--
-- Name: CoachOffer_head_coach_id_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachOffer_head_coach_id_status_idx" ON public."CoachOffer" USING btree (head_coach_id, status);


--
-- Name: CoachOffer_idempotency_key_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CoachOffer_idempotency_key_key" ON public."CoachOffer" USING btree (idempotency_key);


--
-- Name: CoachOffer_one_accepted_per_application_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CoachOffer_one_accepted_per_application_idx" ON public."CoachOffer" USING btree (application_id) WHERE (status = 'accepted'::public."CoachOfferStatus");


--
-- Name: CoachOffer_one_pending_per_head_coach_application_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CoachOffer_one_pending_per_head_coach_application_idx" ON public."CoachOffer" USING btree (head_coach_id, application_id) WHERE (status = 'pending'::public."CoachOfferStatus");


--
-- Name: CoachOnboardingProgress_coach_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CoachOnboardingProgress_coach_id_key" ON public."CoachOnboardingProgress" USING btree (coach_id);


--
-- Name: CoachOnboardingProgress_completed_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachOnboardingProgress_completed_at_idx" ON public."CoachOnboardingProgress" USING btree (completed_at);


--
-- Name: CoachPackageContent_asset_type_asset_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachPackageContent_asset_type_asset_id_idx" ON public."CoachPackageContent" USING btree (asset_type, asset_id);


--
-- Name: CoachPackageContent_package_id_removed_at_display_order_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachPackageContent_package_id_removed_at_display_order_idx" ON public."CoachPackageContent" USING btree (package_id, removed_at, display_order);


--
-- Name: CoachPackage_coach_id_archived_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachPackage_coach_id_archived_at_idx" ON public."CoachPackage" USING btree (coach_id, archived_at);


--
-- Name: CoachPackage_coach_id_is_active_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachPackage_coach_id_is_active_idx" ON public."CoachPackage" USING btree (coach_id, is_active);


--
-- Name: CoachPackage_coach_id_published_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachPackage_coach_id_published_at_idx" ON public."CoachPackage" USING btree (coach_id, published_at);


--
-- Name: CoachPackage_contract_template_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachPackage_contract_template_id_idx" ON public."CoachPackage" USING btree (contract_template_id);


--
-- Name: CoachPackage_share_token_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CoachPackage_share_token_key" ON public."CoachPackage" USING btree (share_token) WHERE (share_token IS NOT NULL);


--
-- Name: CoachPackage_stripe_price_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachPackage_stripe_price_id_idx" ON public."CoachPackage" USING btree (stripe_price_id);


--
-- Name: CoachProfile_created_by_owner_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachProfile_created_by_owner_id_idx" ON public."CoachProfile" USING btree (created_by_owner_id);


--
-- Name: CoachProfile_invite_code_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachProfile_invite_code_idx" ON public."CoachProfile" USING btree (invite_code);


--
-- Name: CoachProfile_subscription_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachProfile_subscription_status_idx" ON public."CoachProfile" USING btree (subscription_status);


--
-- Name: CoachSubscription_coach_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CoachSubscription_coach_id_key" ON public."CoachSubscription" USING btree (coach_id);


--
-- Name: CoachSubscription_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachSubscription_status_idx" ON public."CoachSubscription" USING btree (status);


--
-- Name: CoachSubscription_stripe_subscription_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CoachSubscription_stripe_subscription_id_key" ON public."CoachSubscription" USING btree (stripe_subscription_id);


--
-- Name: CoachSubscription_tier_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachSubscription_tier_idx" ON public."CoachSubscription" USING btree (tier);


--
-- Name: CoachingSession_client_id_start_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachingSession_client_id_start_at_idx" ON public."CoachingSession" USING btree (client_id, start_at);


--
-- Name: CoachingSession_coach_id_start_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachingSession_coach_id_start_at_idx" ON public."CoachingSession" USING btree (coach_id, start_at);


--
-- Name: CoachingSession_status_start_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CoachingSession_status_start_at_idx" ON public."CoachingSession" USING btree (status, start_at);


--
-- Name: CommunityWin_coach_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CommunityWin_coach_id_created_at_idx" ON public."CommunityWin" USING btree (coach_id, created_at);


--
-- Name: CommunityWin_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CommunityWin_user_id_idx" ON public."CommunityWin" USING btree (user_id);


--
-- Name: ConnectAccount_coach_user_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ConnectAccount_coach_user_id_key" ON public."ConnectAccount" USING btree (coach_user_id);


--
-- Name: ConnectAccount_stripe_account_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ConnectAccount_stripe_account_id_idx" ON public."ConnectAccount" USING btree (stripe_account_id);


--
-- Name: ConnectAccount_stripe_account_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ConnectAccount_stripe_account_id_key" ON public."ConnectAccount" USING btree (stripe_account_id);


--
-- Name: ConnectCustomer_client_user_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ConnectCustomer_client_user_id_key" ON public."ConnectCustomer" USING btree (client_user_id);


--
-- Name: ConnectCustomer_stripe_customer_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ConnectCustomer_stripe_customer_id_idx" ON public."ConnectCustomer" USING btree (stripe_customer_id);


--
-- Name: ConnectCustomer_stripe_customer_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ConnectCustomer_stripe_customer_id_key" ON public."ConnectCustomer" USING btree (stripe_customer_id);


--
-- Name: ConnectTransfer_destination_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ConnectTransfer_destination_user_id_idx" ON public."ConnectTransfer" USING btree (destination_user_id);


--
-- Name: ConnectTransfer_idempotency_key_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ConnectTransfer_idempotency_key_key" ON public."ConnectTransfer" USING btree (idempotency_key);


--
-- Name: ConnectTransfer_ledger_entry_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ConnectTransfer_ledger_entry_id_key" ON public."ConnectTransfer" USING btree (ledger_entry_id);


--
-- Name: ConnectTransfer_purchase_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ConnectTransfer_purchase_id_idx" ON public."ConnectTransfer" USING btree (purchase_id);


--
-- Name: ConnectTransfer_status_next_attempt_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ConnectTransfer_status_next_attempt_at_idx" ON public."ConnectTransfer" USING btree (status, next_attempt_at);


--
-- Name: ContractAuditEvent_envelope_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ContractAuditEvent_envelope_id_idx" ON public."ContractAuditEvent" USING btree (envelope_id);


--
-- Name: ContractEnvelope_client_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ContractEnvelope_client_id_idx" ON public."ContractEnvelope" USING btree (client_id);


--
-- Name: ContractEnvelope_client_id_template_id_template_version_sta_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ContractEnvelope_client_id_template_id_template_version_sta_idx" ON public."ContractEnvelope" USING btree (client_id, template_id, template_version, status);


--
-- Name: ContractEnvelope_coach_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ContractEnvelope_coach_id_idx" ON public."ContractEnvelope" USING btree (coach_id);


--
-- Name: ContractEnvelope_hellosign_request_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ContractEnvelope_hellosign_request_id_idx" ON public."ContractEnvelope" USING btree (hellosign_request_id);


--
-- Name: ContractEnvelope_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ContractEnvelope_status_idx" ON public."ContractEnvelope" USING btree (status);


--
-- Name: ContractTemplate_coach_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ContractTemplate_coach_id_idx" ON public."ContractTemplate" USING btree (coach_id);


--
-- Name: ContractTemplate_is_platform_version_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ContractTemplate_is_platform_version_idx" ON public."ContractTemplate" USING btree (is_platform, version);


--
-- Name: ConversationReview_client_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ConversationReview_client_id_idx" ON public."ConversationReview" USING btree (client_id);


--
-- Name: ConversationReview_coach_id_client_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ConversationReview_coach_id_client_id_key" ON public."ConversationReview" USING btree (coach_id, client_id);


--
-- Name: ConversationReview_coach_id_coach_reviewed_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ConversationReview_coach_id_coach_reviewed_at_idx" ON public."ConversationReview" USING btree (coach_id, coach_reviewed_at);


--
-- Name: ConversationReview_coach_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ConversationReview_coach_id_idx" ON public."ConversationReview" USING btree (coach_id);


--
-- Name: DailyMealPlanAssignment_ai_draft_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "DailyMealPlanAssignment_ai_draft_id_key" ON public."DailyMealPlanAssignment" USING btree (ai_draft_id);


--
-- Name: DailyMealPlanAssignment_assigned_by_coach_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DailyMealPlanAssignment_assigned_by_coach_id_idx" ON public."DailyMealPlanAssignment" USING btree (assigned_by_coach_id);


--
-- Name: DailyMealPlanAssignment_client_id_starts_on_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DailyMealPlanAssignment_client_id_starts_on_idx" ON public."DailyMealPlanAssignment" USING btree (client_id, starts_on);


--
-- Name: DailyMealPlanAssignment_daily_meal_plan_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DailyMealPlanAssignment_daily_meal_plan_id_idx" ON public."DailyMealPlanAssignment" USING btree (daily_meal_plan_id);


--
-- Name: DailyMealPlanAssignment_drip_drop_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "DailyMealPlanAssignment_drip_drop_id_key" ON public."DailyMealPlanAssignment" USING btree (drip_drop_id);


--
-- Name: DailyMealPlanSlot_daily_meal_plan_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DailyMealPlanSlot_daily_meal_plan_id_idx" ON public."DailyMealPlanSlot" USING btree (daily_meal_plan_id);


--
-- Name: DailyMealPlanSlot_daily_meal_plan_id_slot_label_order_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "DailyMealPlanSlot_daily_meal_plan_id_slot_label_order_key" ON public."DailyMealPlanSlot" USING btree (daily_meal_plan_id, slot_label, "order");


--
-- Name: DailyMealPlanSlot_meal_template_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DailyMealPlanSlot_meal_template_id_idx" ON public."DailyMealPlanSlot" USING btree (meal_template_id);


--
-- Name: DailyMealPlan_coach_id_archived_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DailyMealPlan_coach_id_archived_at_idx" ON public."DailyMealPlan" USING btree (coach_id, archived_at);


--
-- Name: DataExportRequest_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DataExportRequest_status_idx" ON public."DataExportRequest" USING btree (status);


--
-- Name: DataExportRequest_user_id_requested_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DataExportRequest_user_id_requested_at_idx" ON public."DataExportRequest" USING btree (user_id, requested_at);


--
-- Name: DiagnosticSubmission_email_submitted_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DiagnosticSubmission_email_submitted_at_idx" ON public."DiagnosticSubmission" USING btree (email, submitted_at);


--
-- Name: DiagnosticSubmission_submitted_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DiagnosticSubmission_submitted_at_idx" ON public."DiagnosticSubmission" USING btree (submitted_at);


--
-- Name: DiagnosticSubmission_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DiagnosticSubmission_user_id_idx" ON public."DiagnosticSubmission" USING btree (user_id);


--
-- Name: DripResolverMarker_purchase_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DripResolverMarker_purchase_id_idx" ON public."DripResolverMarker" USING btree (purchase_id);


--
-- Name: DripResolverMarker_purpose_purchase_id_content_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "DripResolverMarker_purpose_purchase_id_content_id_key" ON public."DripResolverMarker" USING btree (purpose, purchase_id, content_id);


--
-- Name: DunningAttempt_dunning_state_id_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DunningAttempt_dunning_state_id_status_idx" ON public."DunningAttempt" USING btree (dunning_state_id, status);


--
-- Name: DunningAttempt_dunning_state_id_step_index_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "DunningAttempt_dunning_state_id_step_index_key" ON public."DunningAttempt" USING btree (dunning_state_id, step_index);


--
-- Name: DunningAttempt_email_idempotency_key_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "DunningAttempt_email_idempotency_key_key" ON public."DunningAttempt" USING btree (email_idempotency_key);


--
-- Name: DunningAttempt_status_next_retry_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DunningAttempt_status_next_retry_at_idx" ON public."DunningAttempt" USING btree (status, next_retry_at);


--
-- Name: DunningAttempt_status_scheduled_for_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DunningAttempt_status_scheduled_for_idx" ON public."DunningAttempt" USING btree (status, scheduled_for);


--
-- Name: DunningState_purchase_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "DunningState_purchase_id_key" ON public."DunningState" USING btree (purchase_id);


--
-- Name: DunningState_status_cancel_scheduled_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DunningState_status_cancel_scheduled_at_idx" ON public."DunningState" USING btree (status, cancel_scheduled_at);


--
-- Name: DunningState_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DunningState_status_idx" ON public."DunningState" USING btree (status);


--
-- Name: DunningState_status_next_attempt_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DunningState_status_next_attempt_at_idx" ON public."DunningState" USING btree (status, next_attempt_at);


--
-- Name: EmailSendLog_idempotency_key_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "EmailSendLog_idempotency_key_key" ON public."EmailSendLog" USING btree (idempotency_key);


--
-- Name: EmailSendLog_recipient_email_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "EmailSendLog_recipient_email_created_at_idx" ON public."EmailSendLog" USING btree (recipient_email, created_at);


--
-- Name: EmailSendLog_status_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "EmailSendLog_status_created_at_idx" ON public."EmailSendLog" USING btree (status, created_at);


--
-- Name: EmailSendLog_template_key_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "EmailSendLog_template_key_created_at_idx" ON public."EmailSendLog" USING btree (template_key, created_at);


--
-- Name: ExerciseCatalogItem_category_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ExerciseCatalogItem_category_idx" ON public."ExerciseCatalogItem" USING btree (category);


--
-- Name: ExerciseCatalogItem_mux_asset_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ExerciseCatalogItem_mux_asset_id_idx" ON public."ExerciseCatalogItem" USING btree (mux_asset_id);


--
-- Name: ExerciseCatalogItem_mux_upload_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ExerciseCatalogItem_mux_upload_id_key" ON public."ExerciseCatalogItem" USING btree (mux_upload_id);


--
-- Name: ExerciseCatalogItem_primary_muscle_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ExerciseCatalogItem_primary_muscle_idx" ON public."ExerciseCatalogItem" USING btree (primary_muscle);


--
-- Name: ExerciseCatalogItem_slug_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ExerciseCatalogItem_slug_key" ON public."ExerciseCatalogItem" USING btree (slug);


--
-- Name: ExerciseCatalogItem_video_provider_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ExerciseCatalogItem_video_provider_idx" ON public."ExerciseCatalogItem" USING btree (video_provider);


--
-- Name: ExtensionPairCode_coach_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ExtensionPairCode_coach_id_idx" ON public."ExtensionPairCode" USING btree (coach_id);


--
-- Name: ExtensionPairCode_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ExtensionPairCode_code_key" ON public."ExtensionPairCode" USING btree (code);


--
-- Name: ExtensionPairCode_expires_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ExtensionPairCode_expires_at_idx" ON public."ExtensionPairCode" USING btree (expires_at);


--
-- Name: ExtensionPairCode_used_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ExtensionPairCode_used_at_idx" ON public."ExtensionPairCode" USING btree (used_at);


--
-- Name: FastingWindow_one_active_per_user; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "FastingWindow_one_active_per_user" ON public."FastingWindow" USING btree (user_id) WHERE (end_time IS NULL);


--
-- Name: FeePolicy_coach_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "FeePolicy_coach_id_key" ON public."FeePolicy" USING btree (coach_id);


--
-- Name: FoodItem_barcode_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "FoodItem_barcode_key" ON public."FoodItem" USING btree (barcode);


--
-- Name: GuestCheckout_data_retention_at_scrubbed_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "GuestCheckout_data_retention_at_scrubbed_at_idx" ON public."GuestCheckout" USING btree (data_retention_at, scrubbed_at);


--
-- Name: GuestCheckout_idempotency_key_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "GuestCheckout_idempotency_key_key" ON public."GuestCheckout" USING btree (idempotency_key);


--
-- Name: GuestCheckout_landing_page_id_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "GuestCheckout_landing_page_id_status_idx" ON public."GuestCheckout" USING btree (landing_page_id, status);


--
-- Name: GuestCheckout_package_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "GuestCheckout_package_id_idx" ON public."GuestCheckout" USING btree (package_id);


--
-- Name: GuestCheckout_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "GuestCheckout_status_idx" ON public."GuestCheckout" USING btree (status);


--
-- Name: GuestCheckout_status_last_reconciled_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "GuestCheckout_status_last_reconciled_at_idx" ON public."GuestCheckout" USING btree (status, last_reconciled_at);


--
-- Name: GuestCheckout_status_last_retry_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "GuestCheckout_status_last_retry_at_idx" ON public."GuestCheckout" USING btree (status, last_retry_at);


--
-- Name: GuestCheckout_stripe_payment_intent_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "GuestCheckout_stripe_payment_intent_id_idx" ON public."GuestCheckout" USING btree (stripe_payment_intent_id);


--
-- Name: GuestCheckout_stripe_payment_intent_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "GuestCheckout_stripe_payment_intent_id_key" ON public."GuestCheckout" USING btree (stripe_payment_intent_id);


--
-- Name: GuestCheckout_stripe_subscription_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "GuestCheckout_stripe_subscription_id_key" ON public."GuestCheckout" USING btree (stripe_subscription_id);


--
-- Name: HabitLog_habit_id_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "HabitLog_habit_id_date_idx" ON public."HabitLog" USING btree (habit_id, date);


--
-- Name: HolisticInsightCache_expires_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "HolisticInsightCache_expires_at_idx" ON public."HolisticInsightCache" USING btree (expires_at);


--
-- Name: HolisticInsightCache_user_id_window_days_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "HolisticInsightCache_user_id_window_days_key" ON public."HolisticInsightCache" USING btree (user_id, window_days);


--
-- Name: InviteCode_coach_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "InviteCode_coach_id_idx" ON public."InviteCode" USING btree (coach_id);


--
-- Name: InviteCode_code_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "InviteCode_code_idx" ON public."InviteCode" USING btree (code);


--
-- Name: InviteCode_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "InviteCode_code_key" ON public."InviteCode" USING btree (code);


--
-- Name: InviteCode_intended_email_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "InviteCode_intended_email_idx" ON public."InviteCode" USING btree (lower(intended_email));


--
-- Name: InviteCode_invited_by_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "InviteCode_invited_by_user_id_idx" ON public."InviteCode" USING btree (invited_by_user_id);


--
-- Name: Invoice_coach_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Invoice_coach_id_created_at_idx" ON public."Invoice" USING btree (coach_id, created_at);


--
-- Name: Invoice_stripe_invoice_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Invoice_stripe_invoice_id_key" ON public."Invoice" USING btree (stripe_invoice_id);


--
-- Name: JobListing_hirer_id_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "JobListing_hirer_id_status_idx" ON public."JobListing" USING btree (hirer_id, status);


--
-- Name: JobListing_idempotency_key_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "JobListing_idempotency_key_key" ON public."JobListing" USING btree (idempotency_key);


--
-- Name: JobListing_specialty_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "JobListing_specialty_status_idx" ON public."JobListing" USING btree (specialty, status);


--
-- Name: JobListing_status_created_at_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "JobListing_status_created_at_id_idx" ON public."JobListing" USING btree (status, created_at, id);


--
-- Name: Lesson_coach_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Lesson_coach_id_idx" ON public."Lesson" USING btree (coach_id);


--
-- Name: LoggedFoodEntry_client_uuid_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "LoggedFoodEntry_client_uuid_key" ON public."LoggedFoodEntry" USING btree (client_uuid);


--
-- Name: LoggedFoodEntry_user_id_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "LoggedFoodEntry_user_id_date_idx" ON public."LoggedFoodEntry" USING btree (user_id, date);


--
-- Name: MacroTarget_client_id_effective_from_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "MacroTarget_client_id_effective_from_idx" ON public."MacroTarget" USING btree (client_id, effective_from);


--
-- Name: MacroTarget_coach_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "MacroTarget_coach_id_created_at_idx" ON public."MacroTarget" USING btree (coach_id, created_at);


--
-- Name: MarketplaceAbuseSignal_device_hash_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "MarketplaceAbuseSignal_device_hash_created_at_idx" ON public."MarketplaceAbuseSignal" USING btree (device_hash, created_at);


--
-- Name: MarketplaceAbuseSignal_identity_hash_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "MarketplaceAbuseSignal_identity_hash_created_at_idx" ON public."MarketplaceAbuseSignal" USING btree (identity_hash, created_at);


--
-- Name: MarketplaceAbuseSignal_surface_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "MarketplaceAbuseSignal_surface_created_at_idx" ON public."MarketplaceAbuseSignal" USING btree (surface, created_at);


--
-- Name: MarketplaceConnectEvent_coach_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "MarketplaceConnectEvent_coach_user_id_idx" ON public."MarketplaceConnectEvent" USING btree (coach_user_id);


--
-- Name: MarketplaceConnectEvent_stripe_account_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "MarketplaceConnectEvent_stripe_account_id_idx" ON public."MarketplaceConnectEvent" USING btree (stripe_account_id);


--
-- Name: MarketplaceMutationIdempotency_user_id_route_key_idempotenc_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "MarketplaceMutationIdempotency_user_id_route_key_idempotenc_key" ON public."MarketplaceMutationIdempotency" USING btree (user_id, route_key, idempotency_key);


--
-- Name: MarketplaceMutationIdempotency_user_id_route_key_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "MarketplaceMutationIdempotency_user_id_route_key_idx" ON public."MarketplaceMutationIdempotency" USING btree (user_id, route_key);


--
-- Name: MealPlan_client_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "MealPlan_client_id_idx" ON public."MealPlan" USING btree (client_id);


--
-- Name: MealPlan_coach_id_client_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "MealPlan_coach_id_client_id_created_at_idx" ON public."MealPlan" USING btree (coach_id, client_id, created_at);


--
-- Name: MealPlan_coach_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "MealPlan_coach_id_idx" ON public."MealPlan" USING btree (coach_id);


--
-- Name: MealTemplate_coach_id_archived_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "MealTemplate_coach_id_archived_at_idx" ON public."MealTemplate" USING btree (coach_id, archived_at);


--
-- Name: MessageDraft_coach_id_client_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "MessageDraft_coach_id_client_id_key" ON public."MessageDraft" USING btree (coach_id, client_id);


--
-- Name: MessageDraft_coach_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "MessageDraft_coach_id_idx" ON public."MessageDraft" USING btree (coach_id);


--
-- Name: MessageReport_message_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "MessageReport_message_id_idx" ON public."MessageReport" USING btree (message_id);


--
-- Name: MessageReport_reporter_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "MessageReport_reporter_id_created_at_idx" ON public."MessageReport" USING btree (reporter_id, created_at DESC);


--
-- Name: MessageReport_reporter_message_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "MessageReport_reporter_message_key" ON public."MessageReport" USING btree (reporter_id, message_id);


--
-- Name: MessageReport_status_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "MessageReport_status_created_at_idx" ON public."MessageReport" USING btree (status, created_at DESC);


--
-- Name: Message_recipient_id_read_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Message_recipient_id_read_idx" ON public."Message" USING btree (recipient_id, read);


--
-- Name: Message_recipient_id_sender_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Message_recipient_id_sender_id_created_at_idx" ON public."Message" USING btree (recipient_id, sender_id, created_at);


--
-- Name: Message_sender_id_recipient_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Message_sender_id_recipient_id_created_at_idx" ON public."Message" USING btree (sender_id, recipient_id, created_at);


--
-- Name: MuxProcessedEvent_handler_completed_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "MuxProcessedEvent_handler_completed_at_idx" ON public."MuxProcessedEvent" USING btree (handler_completed_at);


--
-- Name: MuxProcessedEvent_processed_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "MuxProcessedEvent_processed_at_idx" ON public."MuxProcessedEvent" USING btree (processed_at);


--
-- Name: NotificationDeliveryLog_session_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "NotificationDeliveryLog_session_id_idx" ON public."NotificationDeliveryLog" USING btree (session_id);


--
-- Name: NotificationDeliveryLog_session_user_kind_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "NotificationDeliveryLog_session_user_kind_key" ON public."NotificationDeliveryLog" USING btree (session_id, user_id, kind);


--
-- Name: NotificationDeliveryLog_user_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "NotificationDeliveryLog_user_id_created_at_idx" ON public."NotificationDeliveryLog" USING btree (user_id, created_at);


--
-- Name: NotificationDigestLog_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "NotificationDigestLog_status_idx" ON public."NotificationDigestLog" USING btree (status, created_at DESC);


--
-- Name: NotificationDigestLog_user_id_digest_kind_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "NotificationDigestLog_user_id_digest_kind_idx" ON public."NotificationDigestLog" USING btree (user_id, digest_kind, window_date);


--
-- Name: NotificationPreferences_user_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "NotificationPreferences_user_id_key" ON public."NotificationPreferences" USING btree (user_id);


--
-- Name: Notification_ai_draft_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Notification_ai_draft_id_key" ON public."Notification" USING btree (ai_draft_id);


--
-- Name: Notification_kind_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Notification_kind_created_at_idx" ON public."Notification" USING btree (kind, created_at DESC);


--
-- Name: Notification_user_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Notification_user_id_created_at_idx" ON public."Notification" USING btree (user_id, created_at DESC);


--
-- Name: Notification_user_id_read_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Notification_user_id_read_at_idx" ON public."Notification" USING btree (user_id, read_at);


--
-- Name: NudgeLog_status_attempted_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "NudgeLog_status_attempted_at_idx" ON public."NudgeLog" USING btree (status, attempted_at);


--
-- Name: NudgeLog_status_deferred_until_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "NudgeLog_status_deferred_until_idx" ON public."NudgeLog" USING btree (status, deferred_until);


--
-- Name: NudgeLog_user_id_cap_bucket_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "NudgeLog_user_id_cap_bucket_key" ON public."NudgeLog" USING btree (user_id, cap_bucket);


--
-- Name: NudgeLog_user_id_sent_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "NudgeLog_user_id_sent_at_idx" ON public."NudgeLog" USING btree (user_id, sent_at);


--
-- Name: NudgeLog_user_id_trigger_type_signal_key_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "NudgeLog_user_id_trigger_type_signal_key_key" ON public."NudgeLog" USING btree (user_id, trigger_type, signal_key);


--
-- Name: PartialRefundDecision_client_purchase_id_decision_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "PartialRefundDecision_client_purchase_id_decision_idx" ON public."PartialRefundDecision" USING btree (client_purchase_id, decision);


--
-- Name: PartialRefundDecision_stripe_refund_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "PartialRefundDecision_stripe_refund_id_key" ON public."PartialRefundDecision" USING btree (stripe_refund_id);


--
-- Name: PaymentFailure_coach_id_occurred_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "PaymentFailure_coach_id_occurred_at_idx" ON public."PaymentFailure" USING btree (coach_id, occurred_at);


--
-- Name: PaymentRecoveryToken_dunning_attempt_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "PaymentRecoveryToken_dunning_attempt_id_key" ON public."PaymentRecoveryToken" USING btree (dunning_attempt_id);


--
-- Name: PaymentRecoveryToken_expires_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "PaymentRecoveryToken_expires_at_idx" ON public."PaymentRecoveryToken" USING btree (expires_at);


--
-- Name: PaymentRecoveryToken_jwt_jti_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "PaymentRecoveryToken_jwt_jti_idx" ON public."PaymentRecoveryToken" USING btree (jwt_jti);


--
-- Name: PaymentRecoveryToken_jwt_jti_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "PaymentRecoveryToken_jwt_jti_key" ON public."PaymentRecoveryToken" USING btree (jwt_jti);


--
-- Name: PaymentReminder_purchase_id_kind_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "PaymentReminder_purchase_id_kind_idx" ON public."PaymentReminder" USING btree (purchase_id, kind);


--
-- Name: PaymentReminder_purchase_kind_channel_window_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "PaymentReminder_purchase_kind_channel_window_idx" ON public."PaymentReminder" USING btree (purchase_id, kind, channel, window_key);


--
-- Name: PaymentReminder_recipient_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "PaymentReminder_recipient_user_id_idx" ON public."PaymentReminder" USING btree (recipient_user_id);


--
-- Name: PaymentReminder_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "PaymentReminder_status_idx" ON public."PaymentReminder" USING btree (status);


--
-- Name: PayoutMethod_coach_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "PayoutMethod_coach_id_idx" ON public."PayoutMethod" USING btree (coach_id);


--
-- Name: PayoutMethod_coach_id_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "PayoutMethod_coach_id_status_idx" ON public."PayoutMethod" USING btree (coach_id, status);


--
-- Name: PayoutSnapshot_coach_user_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "PayoutSnapshot_coach_user_id_key" ON public."PayoutSnapshot" USING btree (coach_user_id);


--
-- Name: PayoutSnapshot_readiness_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "PayoutSnapshot_readiness_status_idx" ON public."PayoutSnapshot" USING btree (readiness_status);


--
-- Name: PayoutSnapshot_stripe_account_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "PayoutSnapshot_stripe_account_id_idx" ON public."PayoutSnapshot" USING btree (stripe_account_id);


--
-- Name: Person_coach_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Person_coach_id_idx" ON public."Person" USING btree (coach_id);


--
-- Name: Person_coach_id_source_platform_source_person_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Person_coach_id_source_platform_source_person_id_key" ON public."Person" USING btree (coach_id, source_platform, source_person_id);


--
-- Name: PtmPrediction_prediction_basis_computed_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "PtmPrediction_prediction_basis_computed_at_idx" ON public."PtmPrediction" USING btree (prediction_basis, computed_at);


--
-- Name: PtmPrediction_user_id_computed_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "PtmPrediction_user_id_computed_at_idx" ON public."PtmPrediction" USING btree (user_id, computed_at);


--
-- Name: PurchaseFanout_purchase_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "PurchaseFanout_purchase_id_key" ON public."PurchaseFanout" USING btree (purchase_id);


--
-- Name: ReconciliationSnapshot_purchase_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ReconciliationSnapshot_purchase_id_key" ON public."ReconciliationSnapshot" USING btree (purchase_id);


--
-- Name: ReconciliationSnapshot_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ReconciliationSnapshot_status_idx" ON public."ReconciliationSnapshot" USING btree (status);


--
-- Name: RomanMessage_parent_message_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "RomanMessage_parent_message_id_idx" ON public."RomanMessage" USING btree (parent_message_id);


--
-- Name: RomanMessage_session_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "RomanMessage_session_id_created_at_idx" ON public."RomanMessage" USING btree (session_id, created_at);


--
-- Name: RomanMessage_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "RomanMessage_user_id_idx" ON public."RomanMessage" USING btree (user_id);


--
-- Name: RomanSession_user_id_surface_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "RomanSession_user_id_surface_created_at_idx" ON public."RomanSession" USING btree (user_id, surface, created_at DESC);


--
-- Name: RomanSession_user_id_surface_day_key_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "RomanSession_user_id_surface_day_key_key" ON public."RomanSession" USING btree (user_id, surface, day_key);


--
-- Name: ScheduledDrop_client_purchase_id_content_id_push_seq_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ScheduledDrop_client_purchase_id_content_id_push_seq_key" ON public."ScheduledDrop" USING btree (client_purchase_id, content_id, push_seq);


--
-- Name: ScheduledDrop_client_purchase_id_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ScheduledDrop_client_purchase_id_status_idx" ON public."ScheduledDrop" USING btree (client_purchase_id, status);


--
-- Name: ScheduledDrop_status_fire_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ScheduledDrop_status_fire_at_idx" ON public."ScheduledDrop" USING btree (status, fire_at);


--
-- Name: ScheduledDrop_status_next_retry_at_fire_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ScheduledDrop_status_next_retry_at_fire_at_idx" ON public."ScheduledDrop" USING btree (status, next_retry_at, fire_at);


--
-- Name: ScoutImportCompletion_coach_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ScoutImportCompletion_coach_id_idx" ON public."ScoutImportCompletion" USING btree (coach_id);


--
-- Name: ScoutImportCompletion_coach_id_intent_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ScoutImportCompletion_coach_id_intent_id_key" ON public."ScoutImportCompletion" USING btree (coach_id, intent_id);


--
-- Name: ScoutImport_coach_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ScoutImport_coach_id_idx" ON public."ScoutImport" USING btree (coach_id);


--
-- Name: ScoutImport_coach_id_intent_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ScoutImport_coach_id_intent_id_key" ON public."ScoutImport" USING btree (coach_id, intent_id);


--
-- Name: ScoutIngestEntity_coach_id_entity_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ScoutIngestEntity_coach_id_entity_type_idx" ON public."ScoutIngestEntity" USING btree (coach_id, entity_type);


--
-- Name: ScoutIngestEntity_coach_id_intent_id_source_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ScoutIngestEntity_coach_id_intent_id_source_id_key" ON public."ScoutIngestEntity" USING btree (coach_id, intent_id, source_id);


--
-- Name: ScoutProgressSnapshot_coach_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ScoutProgressSnapshot_coach_id_idx" ON public."ScoutProgressSnapshot" USING btree (coach_id);


--
-- Name: ScoutProgressSnapshot_coach_id_intent_id_device_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ScoutProgressSnapshot_coach_id_intent_id_device_id_key" ON public."ScoutProgressSnapshot" USING btree (coach_id, intent_id, device_id);


--
-- Name: ScoutReconstructedEntity_coach_id_entity_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ScoutReconstructedEntity_coach_id_entity_type_idx" ON public."ScoutReconstructedEntity" USING btree (coach_id, entity_type);


--
-- Name: ScoutReconstructedEntity_coach_id_source_platform_entity_type_s; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ScoutReconstructedEntity_coach_id_source_platform_entity_type_s" ON public."ScoutReconstructedEntity" USING btree (coach_id, source_platform, entity_type, source_id);


--
-- Name: ScoutReconstructionLedger_coach_id_intent_id_entity_type_source; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ScoutReconstructionLedger_coach_id_intent_id_entity_type_source" ON public."ScoutReconstructionLedger" USING btree (coach_id, intent_id, entity_type, source_id);


--
-- Name: ScoutReconstructionLedger_coach_id_intent_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ScoutReconstructionLedger_coach_id_intent_id_idx" ON public."ScoutReconstructionLedger" USING btree (coach_id, intent_id);


--
-- Name: SessionParticipant_session_id_user_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "SessionParticipant_session_id_user_id_key" ON public."SessionParticipant" USING btree (session_id, user_id);


--
-- Name: SessionParticipant_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SessionParticipant_user_id_idx" ON public."SessionParticipant" USING btree (user_id);


--
-- Name: SessionType_coach_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SessionType_coach_id_idx" ON public."SessionType" USING btree (coach_id);


--
-- Name: SplitLedgerEntry_idempotency_key_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "SplitLedgerEntry_idempotency_key_key" ON public."SplitLedgerEntry" USING btree (idempotency_key);


--
-- Name: SplitLedgerEntry_kind_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SplitLedgerEntry_kind_status_idx" ON public."SplitLedgerEntry" USING btree (kind, status);


--
-- Name: SplitLedgerEntry_payee_user_id_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SplitLedgerEntry_payee_user_id_status_idx" ON public."SplitLedgerEntry" USING btree (payee_user_id, status);


--
-- Name: SplitLedgerEntry_purchase_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SplitLedgerEntry_purchase_id_idx" ON public."SplitLedgerEntry" USING btree (purchase_id);


--
-- Name: SplitLedgerEntry_purchase_kind_payee_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "SplitLedgerEntry_purchase_kind_payee_idx" ON public."SplitLedgerEntry" USING btree (purchase_id, kind, payee_user_id);


--
-- Name: SplitLedgerEntry_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SplitLedgerEntry_status_idx" ON public."SplitLedgerEntry" USING btree (status);


--
-- Name: StripeProcessedEvent_handler_completed_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "StripeProcessedEvent_handler_completed_at_idx" ON public."StripeProcessedEvent" USING btree (handler_completed_at);


--
-- Name: StripeProcessedEvent_processed_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "StripeProcessedEvent_processed_at_idx" ON public."StripeProcessedEvent" USING btree (processed_at);


--
-- Name: SubCoachAssignment_client_id_unassigned_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SubCoachAssignment_client_id_unassigned_at_idx" ON public."SubCoachAssignment" USING btree (client_id, unassigned_at);


--
-- Name: SubCoachAssignment_head_coach_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SubCoachAssignment_head_coach_id_idx" ON public."SubCoachAssignment" USING btree (head_coach_id);


--
-- Name: SubCoachAssignment_one_open_per_client; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "SubCoachAssignment_one_open_per_client" ON public."SubCoachAssignment" USING btree (client_id) WHERE (unassigned_at IS NULL);


--
-- Name: SubCoachAssignment_sub_coach_id_unassigned_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SubCoachAssignment_sub_coach_id_unassigned_at_idx" ON public."SubCoachAssignment" USING btree (sub_coach_id, unassigned_at);


--
-- Name: SubCoachInvite_email_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SubCoachInvite_email_idx" ON public."SubCoachInvite" USING btree (email);


--
-- Name: SubCoachInvite_head_coach_id_accepted_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SubCoachInvite_head_coach_id_accepted_at_idx" ON public."SubCoachInvite" USING btree (head_coach_id, accepted_at);


--
-- Name: SubCoachInvite_token_hash_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "SubCoachInvite_token_hash_key" ON public."SubCoachInvite" USING btree (token_hash) WHERE (token_hash IS NOT NULL);


--
-- Name: SubCoachInvite_token_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "SubCoachInvite_token_key" ON public."SubCoachInvite" USING btree (token);


--
-- Name: SubCoachMutationIdempotency_actor_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "SubCoachMutationIdempotency_actor_key" ON public."SubCoachMutationIdempotency" USING btree (actor_id, idempotency_key);


--
-- Name: SubCoachMutationIdempotency_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SubCoachMutationIdempotency_created_at_idx" ON public."SubCoachMutationIdempotency" USING btree (created_at);


--
-- Name: TeamAuditEvent_head_coach_id_event_kind_occurred_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "TeamAuditEvent_head_coach_id_event_kind_occurred_at_idx" ON public."TeamAuditEvent" USING btree (head_coach_id, event_kind, occurred_at);


--
-- Name: TeamAuditEvent_head_coach_id_occurred_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "TeamAuditEvent_head_coach_id_occurred_at_idx" ON public."TeamAuditEvent" USING btree (head_coach_id, occurred_at);


--
-- Name: TeamAuditEvent_target_client_id_occurred_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "TeamAuditEvent_target_client_id_occurred_at_idx" ON public."TeamAuditEvent" USING btree (target_client_id, occurred_at);


--
-- Name: TeamProfile_head_coach_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "TeamProfile_head_coach_id_key" ON public."TeamProfile" USING btree (head_coach_id);


--
-- Name: TeamProfile_team_code_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "TeamProfile_team_code_idx" ON public."TeamProfile" USING btree (team_code);


--
-- Name: TeamProfile_team_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "TeamProfile_team_code_key" ON public."TeamProfile" USING btree (team_code);


--
-- Name: TeamSubCoachAssignment_head_coach_id_archived_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "TeamSubCoachAssignment_head_coach_id_archived_at_idx" ON public."TeamSubCoachAssignment" USING btree (head_coach_id, archived_at);


--
-- Name: TeamSubCoachAssignment_head_coach_id_sub_coach_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "TeamSubCoachAssignment_head_coach_id_sub_coach_id_key" ON public."TeamSubCoachAssignment" USING btree (head_coach_id, sub_coach_id);


--
-- Name: TeamSubCoachAssignment_sub_coach_id_archived_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "TeamSubCoachAssignment_sub_coach_id_archived_at_idx" ON public."TeamSubCoachAssignment" USING btree (sub_coach_id, archived_at);


--
-- Name: UserAIQuota_quota_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "UserAIQuota_quota_date_idx" ON public."UserAIQuota" USING btree (quota_date);


--
-- Name: UserAIQuota_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "UserAIQuota_user_id_idx" ON public."UserAIQuota" USING btree (user_id);


--
-- Name: UserAIQuota_user_id_quota_date_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UserAIQuota_user_id_quota_date_key" ON public."UserAIQuota" USING btree (user_id, quota_date);


--
-- Name: UserBlock_blocked_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "UserBlock_blocked_id_idx" ON public."UserBlock" USING btree (blocked_id);


--
-- Name: UserBlock_blocker_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "UserBlock_blocker_id_created_at_idx" ON public."UserBlock" USING btree (blocker_id, created_at DESC);


--
-- Name: UserBlock_pair_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UserBlock_pair_key" ON public."UserBlock" USING btree (blocker_id, blocked_id);


--
-- Name: UserProfile_user_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UserProfile_user_id_key" ON public."UserProfile" USING btree (user_id);


--
-- Name: User_coach_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "User_coach_id_idx" ON public."User" USING btree (coach_id);


--
-- Name: User_deletion_confirmed_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "User_deletion_confirmed_at_idx" ON public."User" USING btree (deletion_confirmed_at) WHERE ((deletion_confirmed_at IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: User_deletion_scheduled_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "User_deletion_scheduled_at_idx" ON public."User" USING btree (deletion_scheduled_at);


--
-- Name: User_email_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "User_email_key" ON public."User" USING btree (email);


--
-- Name: User_first_win_completed_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "User_first_win_completed_at_idx" ON public."User" USING btree (first_win_completed_at);


--
-- Name: User_supabase_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "User_supabase_id_key" ON public."User" USING btree (supabase_id);


--
-- Name: WearableConnection_channel_expires_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WearableConnection_channel_expires_at_idx" ON public."WearableConnection" USING btree (channel_expires_at);


--
-- Name: WearableConnection_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WearableConnection_status_idx" ON public."WearableConnection" USING btree (status);


--
-- Name: WearableConnection_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WearableConnection_user_id_idx" ON public."WearableConnection" USING btree (user_id);


--
-- Name: WearableConnection_user_id_provider_external_account_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "WearableConnection_user_id_provider_external_account_id_key" ON public."WearableConnection" USING btree (user_id, provider, external_account_id);


--
-- Name: WearableInsightCache_expires_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WearableInsightCache_expires_at_idx" ON public."WearableInsightCache" USING btree (expires_at);


--
-- Name: WearableInsightCache_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WearableInsightCache_user_id_idx" ON public."WearableInsightCache" USING btree (user_id);


--
-- Name: WearableInsightCache_user_id_side_bucket_window_days_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "WearableInsightCache_user_id_side_bucket_window_days_key" ON public."WearableInsightCache" USING btree (user_id, side, bucket, window_days);


--
-- Name: WearableProcessedEvent_handler_completed_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WearableProcessedEvent_handler_completed_at_idx" ON public."WearableProcessedEvent" USING btree (handler_completed_at);


--
-- Name: WearableProcessedEvent_processed_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WearableProcessedEvent_processed_at_idx" ON public."WearableProcessedEvent" USING btree (processed_at);


--
-- Name: WearableSample_connection_id_start_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WearableSample_connection_id_start_at_idx" ON public."WearableSample" USING btree (connection_id, start_at);


--
-- Name: WearableSample_dedup_key_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "WearableSample_dedup_key_key" ON public."WearableSample" USING btree (dedup_key);


--
-- Name: WearableSample_provider_source_record_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WearableSample_provider_source_record_id_idx" ON public."WearableSample" USING btree (provider, source_record_id);


--
-- Name: WearableSample_user_id_bucket_start_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WearableSample_user_id_bucket_start_at_idx" ON public."WearableSample" USING btree (user_id, bucket, start_at);


--
-- Name: WearableSample_user_id_metric_start_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WearableSample_user_id_metric_start_at_idx" ON public."WearableSample" USING btree (user_id, metric, start_at);


--
-- Name: WearableUserMetricPreference_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WearableUserMetricPreference_user_id_idx" ON public."WearableUserMetricPreference" USING btree (user_id);


--
-- Name: WearableUserMetricPreference_user_id_metric_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "WearableUserMetricPreference_user_id_metric_key" ON public."WearableUserMetricPreference" USING btree (user_id, metric);


--
-- Name: WeightLog_user_id_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WeightLog_user_id_date_idx" ON public."WeightLog" USING btree (user_id, date);


--
-- Name: WorkoutBuilderIdempotencyKey_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WorkoutBuilderIdempotencyKey_created_at_idx" ON public."WorkoutBuilderIdempotencyKey" USING btree (created_at);


--
-- Name: WorkoutBuilderIdempotencyKey_status_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WorkoutBuilderIdempotencyKey_status_created_at_idx" ON public."WorkoutBuilderIdempotencyKey" USING btree (status, created_at);


--
-- Name: WorkoutBuilderIdempotencyKey_user_route_key_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "WorkoutBuilderIdempotencyKey_user_route_key_key" ON public."WorkoutBuilderIdempotencyKey" USING btree (user_id, route_key, idempotency_key);


--
-- Name: WorkoutPlanExercise_exercise_external_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WorkoutPlanExercise_exercise_external_id_idx" ON public."WorkoutPlanExercise" USING btree (exercise_external_id);


--
-- Name: WorkoutPlanExercise_plan_order_active_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "WorkoutPlanExercise_plan_order_active_key" ON public."WorkoutPlanExercise" USING btree (workout_plan_id, "order") WHERE (archived_at IS NULL);


--
-- Name: WorkoutPlanExercise_workout_plan_id_archived_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WorkoutPlanExercise_workout_plan_id_archived_at_idx" ON public."WorkoutPlanExercise" USING btree (workout_plan_id, archived_at);


--
-- Name: WorkoutPlanExercise_workout_plan_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WorkoutPlanExercise_workout_plan_id_idx" ON public."WorkoutPlanExercise" USING btree (workout_plan_id);


--
-- Name: WorkoutPlanRevision_workout_plan_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WorkoutPlanRevision_workout_plan_id_created_at_idx" ON public."WorkoutPlanRevision" USING btree (workout_plan_id, created_at DESC);


--
-- Name: WorkoutPlanRevision_workout_plan_id_revision_index_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "WorkoutPlanRevision_workout_plan_id_revision_index_key" ON public."WorkoutPlanRevision" USING btree (workout_plan_id, revision_index);


--
-- Name: WorkoutPlan_coach_id_archived_at_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WorkoutPlan_coach_id_archived_at_created_at_idx" ON public."WorkoutPlan" USING btree (coach_id, archived_at, created_at DESC);


--
-- Name: WorkoutPlan_coach_id_is_template_archived_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WorkoutPlan_coach_id_is_template_archived_at_idx" ON public."WorkoutPlan" USING btree (coach_id, is_template, archived_at);


--
-- Name: WorkoutPlan_program_id_week_index_day_index_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WorkoutPlan_program_id_week_index_day_index_idx" ON public."WorkoutPlan" USING btree (program_id, week_index, day_index);


--
-- Name: WorkoutProgramRevision_program_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WorkoutProgramRevision_program_id_created_at_idx" ON public."WorkoutProgramRevision" USING btree (program_id, created_at DESC);


--
-- Name: WorkoutProgramRevision_program_id_revision_index_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "WorkoutProgramRevision_program_id_revision_index_key" ON public."WorkoutProgramRevision" USING btree (program_id, revision_index);


--
-- Name: WorkoutProgram_coach_id_cloned_from_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WorkoutProgram_coach_id_cloned_from_id_idx" ON public."WorkoutProgram" USING btree (coach_id, cloned_from_id);


--
-- Name: WorkoutProgram_coach_id_is_regime_archived_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WorkoutProgram_coach_id_is_regime_archived_at_idx" ON public."WorkoutProgram" USING btree (coach_id, is_regime, archived_at);


--
-- Name: WorkoutProgram_coach_id_visibility_is_template_archived_at__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WorkoutProgram_coach_id_visibility_is_template_archived_at__idx" ON public."WorkoutProgram" USING btree (coach_id, visibility, is_template, archived_at, updated_at DESC);


--
-- Name: WorkoutProgram_owner_user_id_archived_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WorkoutProgram_owner_user_id_archived_at_idx" ON public."WorkoutProgram" USING btree (owner_user_id, archived_at);


--
-- Name: WorkoutRoutine_creator_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WorkoutRoutine_creator_id_idx" ON public."WorkoutRoutine" USING btree (creator_id);


--
-- Name: WorkoutSession_user_id_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "WorkoutSession_user_id_date_idx" ON public."WorkoutSession" USING btree (user_id, date);


--
-- Name: coach_first_payment_notification_coachId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "coach_first_payment_notification_coachId_key" ON public.coach_first_payment_notification USING btree ("coachId");


--
-- Name: coach_ltv_peak_coach_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX coach_ltv_peak_coach_id_key ON public.coach_ltv_peak USING btree (coach_id);


--
-- Name: community_challenge_participations_challenge_id_progress_va_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_challenge_participations_challenge_id_progress_va_idx ON public.community_challenge_participations USING btree (challenge_id, progress_value);


--
-- Name: community_challenge_participations_challenge_id_user_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX community_challenge_participations_challenge_id_user_id_key ON public.community_challenge_participations USING btree (challenge_id, user_id);


--
-- Name: community_challenge_participations_workspace_id_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_challenge_participations_workspace_id_user_id_idx ON public.community_challenge_participations USING btree (workspace_id, user_id);


--
-- Name: community_challenges_cohort_id_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_challenges_cohort_id_status_idx ON public.community_challenges USING btree (cohort_id, status);


--
-- Name: community_challenges_workspace_id_status_starts_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_challenges_workspace_id_status_starts_at_idx ON public.community_challenges USING btree (workspace_id, status, starts_at);


--
-- Name: community_classroom_media_assets_storage_key_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_classroom_media_assets_storage_key_idx ON public.community_classroom_media_assets USING btree (storage_key);


--
-- Name: community_classroom_media_assets_workspace_id_post_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_classroom_media_assets_workspace_id_post_id_idx ON public.community_classroom_media_assets USING btree (workspace_id, post_id);


--
-- Name: community_classroom_posts_workspace_id_cohort_id_pinned_pinn_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_classroom_posts_workspace_id_cohort_id_pinned_pinn_id ON public.community_classroom_posts USING btree (workspace_id, cohort_id, pinned, pinned_order);


--
-- Name: community_classroom_posts_workspace_id_cohort_id_status_rele_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_classroom_posts_workspace_id_cohort_id_status_rele_id ON public.community_classroom_posts USING btree (workspace_id, cohort_id, status, release_at);


--
-- Name: community_cohorts_workspace_id_archived_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_cohorts_workspace_id_archived_at_idx ON public.community_cohorts USING btree (workspace_id, archived_at);


--
-- Name: community_cohorts_workspace_id_name_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX community_cohorts_workspace_id_name_key ON public.community_cohorts USING btree (workspace_id, name);


--
-- Name: community_cohorts_workspace_id_status_sort_order_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_cohorts_workspace_id_status_sort_order_idx ON public.community_cohorts USING btree (workspace_id, status, sort_order);


--
-- Name: community_event_rsvps_event_id_user_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX community_event_rsvps_event_id_user_id_key ON public.community_event_rsvps USING btree (event_id, user_id);


--
-- Name: community_event_rsvps_workspace_id_status_reminded_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_event_rsvps_workspace_id_status_reminded_at_idx ON public.community_event_rsvps USING btree (workspace_id, status, reminded_at);


--
-- Name: community_event_rsvps_workspace_id_user_id_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_event_rsvps_workspace_id_user_id_status_idx ON public.community_event_rsvps USING btree (workspace_id, user_id, status);


--
-- Name: community_events_cohort_id_starts_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_events_cohort_id_starts_at_idx ON public.community_events USING btree (cohort_id, starts_at);


--
-- Name: community_events_starts_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_events_starts_at_idx ON public.community_events USING btree (starts_at);


--
-- Name: community_events_workspace_id_state_starts_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_events_workspace_id_state_starts_at_idx ON public.community_events USING btree (workspace_id, state, starts_at);


--
-- Name: community_memberships_cohort_id_status_role_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_memberships_cohort_id_status_role_idx ON public.community_memberships USING btree (cohort_id, status, role);


--
-- Name: community_memberships_cohort_id_user_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX community_memberships_cohort_id_user_id_key ON public.community_memberships USING btree (cohort_id, user_id);


--
-- Name: community_memberships_user_id_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_memberships_user_id_status_idx ON public.community_memberships USING btree (user_id, status);


--
-- Name: community_memberships_workspace_id_user_id_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_memberships_workspace_id_user_id_status_idx ON public.community_memberships USING btree (workspace_id, user_id, status);


--
-- Name: community_messages_cohort_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_cohort_id_created_at_idx ON ONLY public.community_messages USING btree (cohort_id, created_at);


--
-- Name: community_messages_2026_12_cohort_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_2026_12_cohort_id_created_at_idx ON public.community_messages_2026_12 USING btree (cohort_id, created_at);


--
-- Name: community_messages_dm_key_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_dm_key_created_at_idx ON ONLY public.community_messages USING btree (dm_key, created_at);


--
-- Name: community_messages_2026_12_dm_key_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_2026_12_dm_key_created_at_idx ON public.community_messages_2026_12 USING btree (dm_key, created_at);


--
-- Name: community_messages_recipient_user_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_recipient_user_id_created_at_idx ON ONLY public.community_messages USING btree (recipient_user_id, created_at);


--
-- Name: community_messages_2026_12_recipient_user_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_2026_12_recipient_user_id_created_at_idx ON public.community_messages_2026_12 USING btree (recipient_user_id, created_at);


--
-- Name: community_messages_sender_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_sender_id_created_at_idx ON ONLY public.community_messages USING btree (sender_id, created_at);


--
-- Name: community_messages_2026_12_sender_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_2026_12_sender_id_created_at_idx ON public.community_messages_2026_12 USING btree (sender_id, created_at);


--
-- Name: community_messages_workspace_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_workspace_id_created_at_idx ON ONLY public.community_messages USING btree (workspace_id, created_at);


--
-- Name: community_messages_2026_12_workspace_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_2026_12_workspace_id_created_at_idx ON public.community_messages_2026_12 USING btree (workspace_id, created_at);


--
-- Name: community_messages_workspace_id_plan_context_type_plan_cont_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_workspace_id_plan_context_type_plan_cont_idx ON ONLY public.community_messages USING btree (workspace_id, plan_context_type, plan_context_id);


--
-- Name: community_messages_2026_12_workspace_id_plan_context_type_p_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_2026_12_workspace_id_plan_context_type_p_idx ON public.community_messages_2026_12 USING btree (workspace_id, plan_context_type, plan_context_id);


--
-- Name: community_messages_workspace_id_visibility_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_workspace_id_visibility_created_at_idx ON ONLY public.community_messages USING btree (workspace_id, visibility, created_at);


--
-- Name: community_messages_2026_12_workspace_id_visibility_created__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_2026_12_workspace_id_visibility_created__idx ON public.community_messages_2026_12 USING btree (workspace_id, visibility, created_at);


--
-- Name: community_messages_2027_01_cohort_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_2027_01_cohort_id_created_at_idx ON public.community_messages_2027_01 USING btree (cohort_id, created_at);


--
-- Name: community_messages_2027_01_dm_key_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_2027_01_dm_key_created_at_idx ON public.community_messages_2027_01 USING btree (dm_key, created_at);


--
-- Name: community_messages_2027_01_recipient_user_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_2027_01_recipient_user_id_created_at_idx ON public.community_messages_2027_01 USING btree (recipient_user_id, created_at);


--
-- Name: community_messages_2027_01_sender_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_2027_01_sender_id_created_at_idx ON public.community_messages_2027_01 USING btree (sender_id, created_at);


--
-- Name: community_messages_2027_01_workspace_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_2027_01_workspace_id_created_at_idx ON public.community_messages_2027_01 USING btree (workspace_id, created_at);


--
-- Name: community_messages_2027_01_workspace_id_plan_context_type_p_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_2027_01_workspace_id_plan_context_type_p_idx ON public.community_messages_2027_01 USING btree (workspace_id, plan_context_type, plan_context_id);


--
-- Name: community_messages_2027_01_workspace_id_visibility_created__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_2027_01_workspace_id_visibility_created__idx ON public.community_messages_2027_01 USING btree (workspace_id, visibility, created_at);


--
-- Name: community_messages_2027_02_cohort_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_2027_02_cohort_id_created_at_idx ON public.community_messages_2027_02 USING btree (cohort_id, created_at);


--
-- Name: community_messages_2027_02_dm_key_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_2027_02_dm_key_created_at_idx ON public.community_messages_2027_02 USING btree (dm_key, created_at);


--
-- Name: community_messages_2027_02_recipient_user_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_2027_02_recipient_user_id_created_at_idx ON public.community_messages_2027_02 USING btree (recipient_user_id, created_at);


--
-- Name: community_messages_2027_02_sender_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_2027_02_sender_id_created_at_idx ON public.community_messages_2027_02 USING btree (sender_id, created_at);


--
-- Name: community_messages_2027_02_workspace_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_2027_02_workspace_id_created_at_idx ON public.community_messages_2027_02 USING btree (workspace_id, created_at);


--
-- Name: community_messages_2027_02_workspace_id_plan_context_type_p_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_2027_02_workspace_id_plan_context_type_p_idx ON public.community_messages_2027_02 USING btree (workspace_id, plan_context_type, plan_context_id);


--
-- Name: community_messages_2027_02_workspace_id_visibility_created__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_2027_02_workspace_id_visibility_created__idx ON public.community_messages_2027_02 USING btree (workspace_id, visibility, created_at);


--
-- Name: community_messages_2028_03_cohort_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_2028_03_cohort_id_created_at_idx ON public.community_messages_2028_03 USING btree (cohort_id, created_at);


--
-- Name: community_messages_2028_03_dm_key_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_2028_03_dm_key_created_at_idx ON public.community_messages_2028_03 USING btree (dm_key, created_at);


--
-- Name: community_messages_2028_03_recipient_user_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_2028_03_recipient_user_id_created_at_idx ON public.community_messages_2028_03 USING btree (recipient_user_id, created_at);


--
-- Name: community_messages_2028_03_sender_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_2028_03_sender_id_created_at_idx ON public.community_messages_2028_03 USING btree (sender_id, created_at);


--
-- Name: community_messages_2028_03_workspace_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_2028_03_workspace_id_created_at_idx ON public.community_messages_2028_03 USING btree (workspace_id, created_at);


--
-- Name: community_messages_2028_03_workspace_id_plan_context_type_p_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_2028_03_workspace_id_plan_context_type_p_idx ON public.community_messages_2028_03 USING btree (workspace_id, plan_context_type, plan_context_id);


--
-- Name: community_messages_2028_03_workspace_id_visibility_created__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_2028_03_workspace_id_visibility_created__idx ON public.community_messages_2028_03 USING btree (workspace_id, visibility, created_at);


--
-- Name: community_messages_default_cohort_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_default_cohort_id_created_at_idx ON public.community_messages_default USING btree (cohort_id, created_at);


--
-- Name: community_messages_default_dm_key_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_default_dm_key_created_at_idx ON public.community_messages_default USING btree (dm_key, created_at);


--
-- Name: community_messages_default_recipient_user_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_default_recipient_user_id_created_at_idx ON public.community_messages_default USING btree (recipient_user_id, created_at);


--
-- Name: community_messages_default_sender_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_default_sender_id_created_at_idx ON public.community_messages_default USING btree (sender_id, created_at);


--
-- Name: community_messages_default_workspace_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_default_workspace_id_created_at_idx ON public.community_messages_default USING btree (workspace_id, created_at);


--
-- Name: community_messages_default_workspace_id_plan_context_type_p_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_default_workspace_id_plan_context_type_p_idx ON public.community_messages_default USING btree (workspace_id, plan_context_type, plan_context_id);


--
-- Name: community_messages_default_workspace_id_visibility_created__idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_messages_default_workspace_id_visibility_created__idx ON public.community_messages_default USING btree (workspace_id, visibility, created_at);


--
-- Name: community_moderation_actions_reported_by_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_moderation_actions_reported_by_id_created_at_idx ON public.community_moderation_actions USING btree (reported_by_id, created_at);


--
-- Name: community_moderation_actions_target_type_target_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_moderation_actions_target_type_target_id_idx ON public.community_moderation_actions USING btree (target_type, target_id);


--
-- Name: community_moderation_actions_workspace_id_status_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_moderation_actions_workspace_id_status_created_at_idx ON public.community_moderation_actions USING btree (workspace_id, status, created_at);


--
-- Name: community_posts_cohort_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_posts_cohort_id_created_at_idx ON public.community_posts USING btree (cohort_id, created_at);


--
-- Name: community_posts_workspace_id_release_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_posts_workspace_id_release_at_idx ON public.community_posts USING btree (workspace_id, release_at);


--
-- Name: community_posts_workspace_id_scope_pinned_at_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_posts_workspace_id_scope_pinned_at_created_at_idx ON public.community_posts USING btree (workspace_id, scope, pinned_at, created_at);


--
-- Name: community_posts_workspace_id_visibility_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_posts_workspace_id_visibility_created_at_idx ON public.community_posts USING btree (workspace_id, visibility, created_at);


--
-- Name: community_responses_target_type_target_id_user_id_response_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX community_responses_target_type_target_id_user_id_response_kind ON public.community_responses USING btree (target_type, target_id, user_id, response_kind);


--
-- Name: community_responses_user_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_responses_user_id_created_at_idx ON public.community_responses USING btree (user_id, created_at);


--
-- Name: community_responses_workspace_id_target_type_target_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_responses_workspace_id_target_type_target_id_idx ON public.community_responses USING btree (workspace_id, target_type, target_id);


--
-- Name: community_search_entries_search_tsv_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_search_entries_search_tsv_gin ON public.community_search_entries USING gin (search_tsv);


--
-- Name: community_search_entries_workspaceId_cohortId_kind_createdAt_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "community_search_entries_workspaceId_cohortId_kind_createdAt_id" ON public.community_search_entries USING btree ("workspaceId", "cohortId", kind, "createdAt");


--
-- Name: community_search_entries_workspaceId_kind_targetId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "community_search_entries_workspaceId_kind_targetId_key" ON public.community_search_entries USING btree ("workspaceId", kind, "targetId");


--
-- Name: community_voice_notes_author_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_voice_notes_author_id_created_at_idx ON public.community_voice_notes USING btree (author_id, created_at);


--
-- Name: community_voice_notes_workspace_id_cohort_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_voice_notes_workspace_id_cohort_id_created_at_idx ON public.community_voice_notes USING btree (workspace_id, cohort_id, created_at);


--
-- Name: community_voice_notes_workspace_id_conversation_id_created_a_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_voice_notes_workspace_id_conversation_id_created_a_id ON public.community_voice_notes USING btree (workspace_id, conversation_id, created_at);


--
-- Name: community_wearable_prompt_sources_promptId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "community_wearable_prompt_sources_promptId_idx" ON public.community_wearable_prompt_sources USING btree ("promptId");


--
-- Name: community_wearable_prompt_sources_sampleId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "community_wearable_prompt_sources_sampleId_idx" ON public.community_wearable_prompt_sources USING btree ("sampleId");


--
-- Name: community_wearable_prompts_active_cooldown_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX community_wearable_prompts_active_cooldown_key ON public.community_wearable_prompts USING btree ("coachId", "clientId", "metricKey") WHERE ("dismissedAt" IS NULL);


--
-- Name: community_wearable_prompts_workspaceId_coachId_dismissedAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "community_wearable_prompts_workspaceId_coachId_dismissedAt_idx" ON public.community_wearable_prompts USING btree ("workspaceId", "coachId", "dismissedAt");


--
-- Name: community_wearable_prompts_workspaceId_coachId_generatedAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "community_wearable_prompts_workspaceId_coachId_generatedAt_idx" ON public.community_wearable_prompts USING btree ("workspaceId", "coachId", "generatedAt");


--
-- Name: community_workspaces_coach_id_archived_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_workspaces_coach_id_archived_at_idx ON public.community_workspaces USING btree (coach_id, archived_at);


--
-- Name: community_workspaces_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_workspaces_created_at_idx ON public.community_workspaces USING btree (created_at);


--
-- Name: community_workspaces_slug_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX community_workspaces_slug_key ON public.community_workspaces USING btree (slug);


--
-- Name: data_export_request_one_active_per_user; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX data_export_request_one_active_per_user ON public.data_export_request USING btree (user_id) WHERE (status = ANY (ARRAY['PENDING'::public."DataExportStatus", 'RUNNING'::public."DataExportStatus", 'READY'::public."DataExportStatus"]));


--
-- Name: data_export_request_status_expires_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX data_export_request_status_expires_at_idx ON public.data_export_request USING btree (status, expires_at);


--
-- Name: data_export_request_user_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX data_export_request_user_id_created_at_idx ON public.data_export_request USING btree (user_id, created_at);


--
-- Name: deletion_audit_event_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX deletion_audit_event_created_at_idx ON public.deletion_audit USING btree (event, created_at);


--
-- Name: deletion_audit_user_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX deletion_audit_user_id_created_at_idx ON public.deletion_audit USING btree (user_id, created_at);


--
-- Name: recent_auth_nonce_expires_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX recent_auth_nonce_expires_at_idx ON public.recent_auth_nonce USING btree (expires_at);


--
-- Name: secret_rotation_log_rotated_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX secret_rotation_log_rotated_at_idx ON public.secret_rotation_log USING btree (rotated_at);


--
-- Name: secret_rotation_log_rotated_by_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX secret_rotation_log_rotated_by_user_id_idx ON public.secret_rotation_log USING btree (rotated_by_user_id);


--
-- Name: secret_rotation_log_secret_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX secret_rotation_log_secret_name_idx ON public.secret_rotation_log USING btree (secret_name);


--
-- Name: water_logs_user_id_logged_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX water_logs_user_id_logged_at_idx ON public.water_logs USING btree (user_id, logged_at);


--
-- Name: community_messages_2026_12_cohort_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_cohort_id_created_at_idx ATTACH PARTITION public.community_messages_2026_12_cohort_id_created_at_idx;


--
-- Name: community_messages_2026_12_dm_key_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_dm_key_created_at_idx ATTACH PARTITION public.community_messages_2026_12_dm_key_created_at_idx;


--
-- Name: community_messages_2026_12_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_pkey ATTACH PARTITION public.community_messages_2026_12_pkey;


--
-- Name: community_messages_2026_12_recipient_user_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_recipient_user_id_created_at_idx ATTACH PARTITION public.community_messages_2026_12_recipient_user_id_created_at_idx;


--
-- Name: community_messages_2026_12_sender_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_sender_id_created_at_idx ATTACH PARTITION public.community_messages_2026_12_sender_id_created_at_idx;


--
-- Name: community_messages_2026_12_workspace_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_workspace_id_created_at_idx ATTACH PARTITION public.community_messages_2026_12_workspace_id_created_at_idx;


--
-- Name: community_messages_2026_12_workspace_id_plan_context_type_p_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_workspace_id_plan_context_type_plan_cont_idx ATTACH PARTITION public.community_messages_2026_12_workspace_id_plan_context_type_p_idx;


--
-- Name: community_messages_2026_12_workspace_id_visibility_created__idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_workspace_id_visibility_created_at_idx ATTACH PARTITION public.community_messages_2026_12_workspace_id_visibility_created__idx;


--
-- Name: community_messages_2027_01_cohort_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_cohort_id_created_at_idx ATTACH PARTITION public.community_messages_2027_01_cohort_id_created_at_idx;


--
-- Name: community_messages_2027_01_dm_key_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_dm_key_created_at_idx ATTACH PARTITION public.community_messages_2027_01_dm_key_created_at_idx;


--
-- Name: community_messages_2027_01_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_pkey ATTACH PARTITION public.community_messages_2027_01_pkey;


--
-- Name: community_messages_2027_01_recipient_user_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_recipient_user_id_created_at_idx ATTACH PARTITION public.community_messages_2027_01_recipient_user_id_created_at_idx;


--
-- Name: community_messages_2027_01_sender_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_sender_id_created_at_idx ATTACH PARTITION public.community_messages_2027_01_sender_id_created_at_idx;


--
-- Name: community_messages_2027_01_workspace_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_workspace_id_created_at_idx ATTACH PARTITION public.community_messages_2027_01_workspace_id_created_at_idx;


--
-- Name: community_messages_2027_01_workspace_id_plan_context_type_p_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_workspace_id_plan_context_type_plan_cont_idx ATTACH PARTITION public.community_messages_2027_01_workspace_id_plan_context_type_p_idx;


--
-- Name: community_messages_2027_01_workspace_id_visibility_created__idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_workspace_id_visibility_created_at_idx ATTACH PARTITION public.community_messages_2027_01_workspace_id_visibility_created__idx;


--
-- Name: community_messages_2027_02_cohort_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_cohort_id_created_at_idx ATTACH PARTITION public.community_messages_2027_02_cohort_id_created_at_idx;


--
-- Name: community_messages_2027_02_dm_key_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_dm_key_created_at_idx ATTACH PARTITION public.community_messages_2027_02_dm_key_created_at_idx;


--
-- Name: community_messages_2027_02_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_pkey ATTACH PARTITION public.community_messages_2027_02_pkey;


--
-- Name: community_messages_2027_02_recipient_user_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_recipient_user_id_created_at_idx ATTACH PARTITION public.community_messages_2027_02_recipient_user_id_created_at_idx;


--
-- Name: community_messages_2027_02_sender_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_sender_id_created_at_idx ATTACH PARTITION public.community_messages_2027_02_sender_id_created_at_idx;


--
-- Name: community_messages_2027_02_workspace_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_workspace_id_created_at_idx ATTACH PARTITION public.community_messages_2027_02_workspace_id_created_at_idx;


--
-- Name: community_messages_2027_02_workspace_id_plan_context_type_p_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_workspace_id_plan_context_type_plan_cont_idx ATTACH PARTITION public.community_messages_2027_02_workspace_id_plan_context_type_p_idx;


--
-- Name: community_messages_2027_02_workspace_id_visibility_created__idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_workspace_id_visibility_created_at_idx ATTACH PARTITION public.community_messages_2027_02_workspace_id_visibility_created__idx;


--
-- Name: community_messages_2028_03_cohort_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_cohort_id_created_at_idx ATTACH PARTITION public.community_messages_2028_03_cohort_id_created_at_idx;


--
-- Name: community_messages_2028_03_dm_key_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_dm_key_created_at_idx ATTACH PARTITION public.community_messages_2028_03_dm_key_created_at_idx;


--
-- Name: community_messages_2028_03_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_pkey ATTACH PARTITION public.community_messages_2028_03_pkey;


--
-- Name: community_messages_2028_03_recipient_user_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_recipient_user_id_created_at_idx ATTACH PARTITION public.community_messages_2028_03_recipient_user_id_created_at_idx;


--
-- Name: community_messages_2028_03_sender_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_sender_id_created_at_idx ATTACH PARTITION public.community_messages_2028_03_sender_id_created_at_idx;


--
-- Name: community_messages_2028_03_workspace_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_workspace_id_created_at_idx ATTACH PARTITION public.community_messages_2028_03_workspace_id_created_at_idx;


--
-- Name: community_messages_2028_03_workspace_id_plan_context_type_p_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_workspace_id_plan_context_type_plan_cont_idx ATTACH PARTITION public.community_messages_2028_03_workspace_id_plan_context_type_p_idx;


--
-- Name: community_messages_2028_03_workspace_id_visibility_created__idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_workspace_id_visibility_created_at_idx ATTACH PARTITION public.community_messages_2028_03_workspace_id_visibility_created__idx;


--
-- Name: community_messages_default_cohort_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_cohort_id_created_at_idx ATTACH PARTITION public.community_messages_default_cohort_id_created_at_idx;


--
-- Name: community_messages_default_dm_key_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_dm_key_created_at_idx ATTACH PARTITION public.community_messages_default_dm_key_created_at_idx;


--
-- Name: community_messages_default_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_pkey ATTACH PARTITION public.community_messages_default_pkey;


--
-- Name: community_messages_default_recipient_user_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_recipient_user_id_created_at_idx ATTACH PARTITION public.community_messages_default_recipient_user_id_created_at_idx;


--
-- Name: community_messages_default_sender_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_sender_id_created_at_idx ATTACH PARTITION public.community_messages_default_sender_id_created_at_idx;


--
-- Name: community_messages_default_workspace_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_workspace_id_created_at_idx ATTACH PARTITION public.community_messages_default_workspace_id_created_at_idx;


--
-- Name: community_messages_default_workspace_id_plan_context_type_p_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_workspace_id_plan_context_type_plan_cont_idx ATTACH PARTITION public.community_messages_default_workspace_id_plan_context_type_p_idx;


--
-- Name: community_messages_default_workspace_id_visibility_created__idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.community_messages_workspace_id_visibility_created_at_idx ATTACH PARTITION public.community_messages_default_workspace_id_visibility_created__idx;


--
-- Name: TeamSubCoachAssignment trg_enforce_subcoach_head_cap; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_enforce_subcoach_head_cap BEFORE INSERT OR UPDATE ON public."TeamSubCoachAssignment" FOR EACH ROW EXECUTE FUNCTION public.enforce_subcoach_head_cap();


--
-- Name: AICallLog AICallLog_clientId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AICallLog"
    ADD CONSTRAINT "AICallLog_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: AICallLog AICallLog_coachId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AICallLog"
    ADD CONSTRAINT "AICallLog_coachId_fkey" FOREIGN KEY ("coachId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: AIDraft AIDraft_clientId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AIDraft"
    ADD CONSTRAINT "AIDraft_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: AIDraft AIDraft_coachId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AIDraft"
    ADD CONSTRAINT "AIDraft_coachId_fkey" FOREIGN KEY ("coachId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ActivityEvent ActivityEvent_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ActivityEvent"
    ADD CONSTRAINT "ActivityEvent_actor_id_fkey" FOREIGN KEY (actor_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ActivityEvent ActivityEvent_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ActivityEvent"
    ADD CONSTRAINT "ActivityEvent_client_id_fkey" FOREIGN KEY (client_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ActivityEvent ActivityEvent_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ActivityEvent"
    ADD CONSTRAINT "ActivityEvent_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: AiActionDraft AiActionDraft_decided_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AiActionDraft"
    ADD CONSTRAINT "AiActionDraft_decided_by_id_fkey" FOREIGN KEY (decided_by_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: AiActionDraft AiActionDraft_requester_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AiActionDraft"
    ADD CONSTRAINT "AiActionDraft_requester_id_fkey" FOREIGN KEY (requester_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: AiRequestAudit AiRequestAudit_approval_draft_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AiRequestAudit"
    ADD CONSTRAINT "AiRequestAudit_approval_draft_id_fkey" FOREIGN KEY (approval_draft_id) REFERENCES public."AiActionDraft"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: AiRequestAudit AiRequestAudit_requester_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AiRequestAudit"
    ADD CONSTRAINT "AiRequestAudit_requester_id_fkey" FOREIGN KEY (requester_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: AiRequestAudit AiRequestAudit_subject_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AiRequestAudit"
    ADD CONSTRAINT "AiRequestAudit_subject_user_id_fkey" FOREIGN KEY (subject_user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: AiRoadmap AiRoadmap_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AiRoadmap"
    ADD CONSTRAINT "AiRoadmap_submission_id_fkey" FOREIGN KEY (submission_id) REFERENCES public."DiagnosticSubmission"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Applicant Applicant_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Applicant"
    ADD CONSTRAINT "Applicant_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Application Application_applicant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Application"
    ADD CONSTRAINT "Application_applicant_id_fkey" FOREIGN KEY (applicant_id) REFERENCES public."Applicant"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Application Application_applicant_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Application"
    ADD CONSTRAINT "Application_applicant_user_id_fkey" FOREIGN KEY (applicant_user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Application Application_hirer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Application"
    ADD CONSTRAINT "Application_hirer_id_fkey" FOREIGN KEY (hirer_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Application Application_listing_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Application"
    ADD CONSTRAINT "Application_listing_id_fkey" FOREIGN KEY (listing_id) REFERENCES public."JobListing"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: AuditLog AuditLog_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AuditLog"
    ADD CONSTRAINT "AuditLog_actor_id_fkey" FOREIGN KEY (actor_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: AuditLog AuditLog_target_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AuditLog"
    ADD CONSTRAINT "AuditLog_target_user_id_fkey" FOREIGN KEY (target_user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: BloodworkAttachment BloodworkAttachment_panel_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BloodworkAttachment"
    ADD CONSTRAINT "BloodworkAttachment_panel_id_fkey" FOREIGN KEY (panel_id) REFERENCES public."BloodworkPanel"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: BloodworkPanel BloodworkPanel_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BloodworkPanel"
    ADD CONSTRAINT "BloodworkPanel_client_id_fkey" FOREIGN KEY (client_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: BloodworkPanel BloodworkPanel_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BloodworkPanel"
    ADD CONSTRAINT "BloodworkPanel_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: BloodworkPanel BloodworkPanel_reviewed_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BloodworkPanel"
    ADD CONSTRAINT "BloodworkPanel_reviewed_by_id_fkey" FOREIGN KEY (reviewed_by_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: BloodworkResult BloodworkResult_panel_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BloodworkResult"
    ADD CONSTRAINT "BloodworkResult_panel_id_fkey" FOREIGN KEY (panel_id) REFERENCES public."BloodworkPanel"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: BuildWeekDayCompletion BuildWeekDayCompletion_enrollment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BuildWeekDayCompletion"
    ADD CONSTRAINT "BuildWeekDayCompletion_enrollment_id_fkey" FOREIGN KEY (enrollment_id) REFERENCES public."BuildWeekEnrollment"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CalendarConnection CalendarConnection_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CalendarConnection"
    ADD CONSTRAINT "CalendarConnection_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ChargeDispute ChargeDispute_purchase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChargeDispute"
    ADD CONSTRAINT "ChargeDispute_purchase_id_fkey" FOREIGN KEY (purchase_id) REFERENCES public."ClientPurchase"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ChargeRefund ChargeRefund_purchase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChargeRefund"
    ADD CONSTRAINT "ChargeRefund_purchase_id_fkey" FOREIGN KEY (purchase_id) REFERENCES public."ClientPurchase"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CheckIn CheckIn_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CheckIn"
    ADD CONSTRAINT "CheckIn_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CheckIn CheckIn_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CheckIn"
    ADD CONSTRAINT "CheckIn_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ChurnIntervention ChurnIntervention_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChurnIntervention"
    ADD CONSTRAINT "ChurnIntervention_client_id_fkey" FOREIGN KEY (client_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ChurnIntervention ChurnIntervention_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChurnIntervention"
    ADD CONSTRAINT "ChurnIntervention_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ClientCoachConsent ClientCoachConsent_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ClientCoachConsent"
    ADD CONSTRAINT "ClientCoachConsent_client_id_fkey" FOREIGN KEY (client_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ClientCoachConsent ClientCoachConsent_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ClientCoachConsent"
    ADD CONSTRAINT "ClientCoachConsent_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ClientOutcome ClientOutcome_labelled_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ClientOutcome"
    ADD CONSTRAINT "ClientOutcome_labelled_by_id_fkey" FOREIGN KEY (labelled_by_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ClientOutcome ClientOutcome_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ClientOutcome"
    ADD CONSTRAINT "ClientOutcome_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ClientPurchase ClientPurchase_client_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ClientPurchase"
    ADD CONSTRAINT "ClientPurchase_client_user_id_fkey" FOREIGN KEY (client_user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ClientPurchase ClientPurchase_coach_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ClientPurchase"
    ADD CONSTRAINT "ClientPurchase_coach_user_id_fkey" FOREIGN KEY (coach_user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ClientPurchase ClientPurchase_contract_envelope_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ClientPurchase"
    ADD CONSTRAINT "ClientPurchase_contract_envelope_id_fkey" FOREIGN KEY (contract_envelope_id) REFERENCES public."ContractEnvelope"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ClientPurchase ClientPurchase_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ClientPurchase"
    ADD CONSTRAINT "ClientPurchase_package_id_fkey" FOREIGN KEY (package_id) REFERENCES public."CoachPackage"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ClientSignal ClientSignal_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ClientSignal"
    ADD CONSTRAINT "ClientSignal_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ClientWorkoutAssignmentSnapshot ClientWorkoutAssignmentSnapshot_assignment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ClientWorkoutAssignmentSnapshot"
    ADD CONSTRAINT "ClientWorkoutAssignmentSnapshot_assignment_id_fkey" FOREIGN KEY (assignment_id) REFERENCES public."ClientWorkoutAssignment"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ClientWorkoutAssignment ClientWorkoutAssignment_assigned_by_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ClientWorkoutAssignment"
    ADD CONSTRAINT "ClientWorkoutAssignment_assigned_by_coach_id_fkey" FOREIGN KEY (assigned_by_coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ClientWorkoutAssignment ClientWorkoutAssignment_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ClientWorkoutAssignment"
    ADD CONSTRAINT "ClientWorkoutAssignment_client_id_fkey" FOREIGN KEY (client_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ClientWorkoutAssignment ClientWorkoutAssignment_workout_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ClientWorkoutAssignment"
    ADD CONSTRAINT "ClientWorkoutAssignment_workout_plan_id_fkey" FOREIGN KEY (workout_plan_id) REFERENCES public."WorkoutPlan"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CoachAIBudget CoachAIBudget_coach_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachAIBudget"
    ADD CONSTRAINT "CoachAIBudget_coach_user_id_fkey" FOREIGN KEY (coach_user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CoachAlert CoachAlert_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachAlert"
    ADD CONSTRAINT "CoachAlert_client_id_fkey" FOREIGN KEY (client_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CoachAlert CoachAlert_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachAlert"
    ADD CONSTRAINT "CoachAlert_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CoachAvailabilityOverride CoachAvailabilityOverride_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachAvailabilityOverride"
    ADD CONSTRAINT "CoachAvailabilityOverride_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CoachAvailability CoachAvailability_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachAvailability"
    ADD CONSTRAINT "CoachAvailability_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CoachBriefPreferences CoachBriefPreferences_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachBriefPreferences"
    ADD CONSTRAINT "CoachBriefPreferences_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CoachBriefPushLedger CoachBriefPushLedger_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachBriefPushLedger"
    ADD CONSTRAINT "CoachBriefPushLedger_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CoachBrief CoachBrief_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachBrief"
    ADD CONSTRAINT "CoachBrief_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CoachCreditPackPurchase CoachCreditPackPurchase_budget_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachCreditPackPurchase"
    ADD CONSTRAINT "CoachCreditPackPurchase_budget_id_fkey" FOREIGN KEY (budget_id) REFERENCES public."CoachAIBudget"(id) ON UPDATE CASCADE;


--
-- Name: CoachCreditPackPurchase CoachCreditPackPurchase_coach_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachCreditPackPurchase"
    ADD CONSTRAINT "CoachCreditPackPurchase_coach_user_id_fkey" FOREIGN KEY (coach_user_id) REFERENCES public."User"(id) ON UPDATE CASCADE;


--
-- Name: CoachCrmIntegration CoachCrmIntegration_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachCrmIntegration"
    ADD CONSTRAINT "CoachCrmIntegration_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CoachDailyLog CoachDailyLog_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachDailyLog"
    ADD CONSTRAINT "CoachDailyLog_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CoachEffectivenessScore CoachEffectivenessScore_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachEffectivenessScore"
    ADD CONSTRAINT "CoachEffectivenessScore_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CoachGuideline CoachGuideline_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachGuideline"
    ADD CONSTRAINT "CoachGuideline_client_id_fkey" FOREIGN KEY (client_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CoachGuideline CoachGuideline_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachGuideline"
    ADD CONSTRAINT "CoachGuideline_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CoachLandingLead CoachLandingLead_page_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachLandingLead"
    ADD CONSTRAINT "CoachLandingLead_page_id_fkey" FOREIGN KEY (page_id) REFERENCES public."CoachLandingPage"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CoachLandingPageSection CoachLandingPageSection_page_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachLandingPageSection"
    ADD CONSTRAINT "CoachLandingPageSection_page_id_fkey" FOREIGN KEY (page_id) REFERENCES public."CoachLandingPage"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CoachLandingPageView CoachLandingPageView_page_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachLandingPageView"
    ADD CONSTRAINT "CoachLandingPageView_page_id_fkey" FOREIGN KEY (page_id) REFERENCES public."CoachLandingPage"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CoachLandingPage CoachLandingPage_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachLandingPage"
    ADD CONSTRAINT "CoachLandingPage_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CoachLandingPage CoachLandingPage_crm_integration_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachLandingPage"
    ADD CONSTRAINT "CoachLandingPage_crm_integration_id_fkey" FOREIGN KEY (crm_integration_id) REFERENCES public."CoachCrmIntegration"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CoachMediaAsset CoachMediaAsset_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachMediaAsset"
    ADD CONSTRAINT "CoachMediaAsset_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CoachMessage CoachMessage_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachMessage"
    ADD CONSTRAINT "CoachMessage_client_id_fkey" FOREIGN KEY (client_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CoachMessage CoachMessage_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachMessage"
    ADD CONSTRAINT "CoachMessage_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CoachMessage CoachMessage_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachMessage"
    ADD CONSTRAINT "CoachMessage_sender_id_fkey" FOREIGN KEY (sender_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CoachNudge CoachNudge_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachNudge"
    ADD CONSTRAINT "CoachNudge_client_id_fkey" FOREIGN KEY (client_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CoachNudge CoachNudge_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachNudge"
    ADD CONSTRAINT "CoachNudge_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CoachOffer CoachOffer_applicant_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachOffer"
    ADD CONSTRAINT "CoachOffer_applicant_user_id_fkey" FOREIGN KEY (applicant_user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CoachOffer CoachOffer_application_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachOffer"
    ADD CONSTRAINT "CoachOffer_application_id_fkey" FOREIGN KEY (application_id) REFERENCES public."Application"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CoachOffer CoachOffer_head_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachOffer"
    ADD CONSTRAINT "CoachOffer_head_coach_id_fkey" FOREIGN KEY (head_coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CoachOnboardingProgress CoachOnboardingProgress_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachOnboardingProgress"
    ADD CONSTRAINT "CoachOnboardingProgress_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CoachPackageContent CoachPackageContent_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachPackageContent"
    ADD CONSTRAINT "CoachPackageContent_package_id_fkey" FOREIGN KEY (package_id) REFERENCES public."CoachPackage"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CoachPackage CoachPackage_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachPackage"
    ADD CONSTRAINT "CoachPackage_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CoachPackage CoachPackage_contract_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachPackage"
    ADD CONSTRAINT "CoachPackage_contract_template_id_fkey" FOREIGN KEY (contract_template_id) REFERENCES public."ContractTemplate"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CoachProfile CoachProfile_created_by_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachProfile"
    ADD CONSTRAINT "CoachProfile_created_by_owner_id_fkey" FOREIGN KEY (created_by_owner_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CoachProfile CoachProfile_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachProfile"
    ADD CONSTRAINT "CoachProfile_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CoachSubscription CoachSubscription_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachSubscription"
    ADD CONSTRAINT "CoachSubscription_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CoachingSession CoachingSession_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachingSession"
    ADD CONSTRAINT "CoachingSession_client_id_fkey" FOREIGN KEY (client_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CoachingSession CoachingSession_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachingSession"
    ADD CONSTRAINT "CoachingSession_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CoachingSession CoachingSession_session_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CoachingSession"
    ADD CONSTRAINT "CoachingSession_session_type_id_fkey" FOREIGN KEY (session_type_id) REFERENCES public."SessionType"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CommunityWin CommunityWin_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CommunityWin"
    ADD CONSTRAINT "CommunityWin_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CommunityWin CommunityWin_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CommunityWin"
    ADD CONSTRAINT "CommunityWin_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ConnectAccount ConnectAccount_coach_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ConnectAccount"
    ADD CONSTRAINT "ConnectAccount_coach_user_id_fkey" FOREIGN KEY (coach_user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ConnectCustomer ConnectCustomer_client_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ConnectCustomer"
    ADD CONSTRAINT "ConnectCustomer_client_user_id_fkey" FOREIGN KEY (client_user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ConnectTransfer ConnectTransfer_destination_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ConnectTransfer"
    ADD CONSTRAINT "ConnectTransfer_destination_user_id_fkey" FOREIGN KEY (destination_user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ConnectTransfer ConnectTransfer_purchase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ConnectTransfer"
    ADD CONSTRAINT "ConnectTransfer_purchase_id_fkey" FOREIGN KEY (purchase_id) REFERENCES public."ClientPurchase"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ContractAuditEvent ContractAuditEvent_envelope_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ContractAuditEvent"
    ADD CONSTRAINT "ContractAuditEvent_envelope_id_fkey" FOREIGN KEY (envelope_id) REFERENCES public."ContractEnvelope"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ContractEnvelope ContractEnvelope_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ContractEnvelope"
    ADD CONSTRAINT "ContractEnvelope_client_id_fkey" FOREIGN KEY (client_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ContractEnvelope ContractEnvelope_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ContractEnvelope"
    ADD CONSTRAINT "ContractEnvelope_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ContractEnvelope ContractEnvelope_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ContractEnvelope"
    ADD CONSTRAINT "ContractEnvelope_template_id_fkey" FOREIGN KEY (template_id) REFERENCES public."ContractTemplate"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ContractTemplate ContractTemplate_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ContractTemplate"
    ADD CONSTRAINT "ContractTemplate_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ConversationReview ConversationReview_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ConversationReview"
    ADD CONSTRAINT "ConversationReview_client_id_fkey" FOREIGN KEY (client_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ConversationReview ConversationReview_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ConversationReview"
    ADD CONSTRAINT "ConversationReview_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DailyMealPlanAssignment DailyMealPlanAssignment_assigned_by_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DailyMealPlanAssignment"
    ADD CONSTRAINT "DailyMealPlanAssignment_assigned_by_coach_id_fkey" FOREIGN KEY (assigned_by_coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DailyMealPlanAssignment DailyMealPlanAssignment_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DailyMealPlanAssignment"
    ADD CONSTRAINT "DailyMealPlanAssignment_client_id_fkey" FOREIGN KEY (client_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DailyMealPlanAssignment DailyMealPlanAssignment_daily_meal_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DailyMealPlanAssignment"
    ADD CONSTRAINT "DailyMealPlanAssignment_daily_meal_plan_id_fkey" FOREIGN KEY (daily_meal_plan_id) REFERENCES public."DailyMealPlan"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DailyMealPlanSlot DailyMealPlanSlot_daily_meal_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DailyMealPlanSlot"
    ADD CONSTRAINT "DailyMealPlanSlot_daily_meal_plan_id_fkey" FOREIGN KEY (daily_meal_plan_id) REFERENCES public."DailyMealPlan"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DailyMealPlanSlot DailyMealPlanSlot_meal_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DailyMealPlanSlot"
    ADD CONSTRAINT "DailyMealPlanSlot_meal_template_id_fkey" FOREIGN KEY (meal_template_id) REFERENCES public."MealTemplate"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: DailyMealPlan DailyMealPlan_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DailyMealPlan"
    ADD CONSTRAINT "DailyMealPlan_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DataExportRequest DataExportRequest_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DataExportRequest"
    ADD CONSTRAINT "DataExportRequest_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DunningAttempt DunningAttempt_dunning_state_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DunningAttempt"
    ADD CONSTRAINT "DunningAttempt_dunning_state_id_fkey" FOREIGN KEY (dunning_state_id) REFERENCES public."DunningState"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DunningState DunningState_purchase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DunningState"
    ADD CONSTRAINT "DunningState_purchase_id_fkey" FOREIGN KEY (purchase_id) REFERENCES public."ClientPurchase"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ExerciseSet ExerciseSet_workout_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ExerciseSet"
    ADD CONSTRAINT "ExerciseSet_workout_id_fkey" FOREIGN KEY (workout_id) REFERENCES public."WorkoutSession"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ExtensionPairCode ExtensionPairCode_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ExtensionPairCode"
    ADD CONSTRAINT "ExtensionPairCode_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: FastingWindow FastingWindow_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."FastingWindow"
    ADD CONSTRAINT "FastingWindow_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: FeePolicy FeePolicy_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."FeePolicy"
    ADD CONSTRAINT "FeePolicy_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: GuestCheckout GuestCheckout_created_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."GuestCheckout"
    ADD CONSTRAINT "GuestCheckout_created_user_id_fkey" FOREIGN KEY (created_user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: GuestCheckout GuestCheckout_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."GuestCheckout"
    ADD CONSTRAINT "GuestCheckout_package_id_fkey" FOREIGN KEY (package_id) REFERENCES public."CoachPackage"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: HabitLog HabitLog_habit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."HabitLog"
    ADD CONSTRAINT "HabitLog_habit_id_fkey" FOREIGN KEY (habit_id) REFERENCES public."Habit"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Habit Habit_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Habit"
    ADD CONSTRAINT "Habit_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: HolisticInsightCache HolisticInsightCache_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."HolisticInsightCache"
    ADD CONSTRAINT "HolisticInsightCache_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: InviteCode InviteCode_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InviteCode"
    ADD CONSTRAINT "InviteCode_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: InviteCode InviteCode_invited_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InviteCode"
    ADD CONSTRAINT "InviteCode_invited_by_user_id_fkey" FOREIGN KEY (invited_by_user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Invoice Invoice_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Invoice"
    ADD CONSTRAINT "Invoice_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: JobListing JobListing_hirer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."JobListing"
    ADD CONSTRAINT "JobListing_hirer_id_fkey" FOREIGN KEY (hirer_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: LessonCompletion LessonCompletion_lesson_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."LessonCompletion"
    ADD CONSTRAINT "LessonCompletion_lesson_id_fkey" FOREIGN KEY (lesson_id) REFERENCES public."Lesson"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: LessonCompletion LessonCompletion_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."LessonCompletion"
    ADD CONSTRAINT "LessonCompletion_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Lesson Lesson_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Lesson"
    ADD CONSTRAINT "Lesson_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: LoggedFoodEntry LoggedFoodEntry_food_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."LoggedFoodEntry"
    ADD CONSTRAINT "LoggedFoodEntry_food_item_id_fkey" FOREIGN KEY (food_item_id) REFERENCES public."FoodItem"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: LoggedFoodEntry LoggedFoodEntry_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."LoggedFoodEntry"
    ADD CONSTRAINT "LoggedFoodEntry_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: MacroTarget MacroTarget_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MacroTarget"
    ADD CONSTRAINT "MacroTarget_client_id_fkey" FOREIGN KEY (client_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: MacroTarget MacroTarget_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MacroTarget"
    ADD CONSTRAINT "MacroTarget_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: MealPlan MealPlan_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MealPlan"
    ADD CONSTRAINT "MealPlan_client_id_fkey" FOREIGN KEY (client_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: MealPlan MealPlan_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MealPlan"
    ADD CONSTRAINT "MealPlan_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: MealTemplate MealTemplate_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MealTemplate"
    ADD CONSTRAINT "MealTemplate_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: MessageDraft MessageDraft_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MessageDraft"
    ADD CONSTRAINT "MessageDraft_client_id_fkey" FOREIGN KEY (client_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: MessageDraft MessageDraft_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MessageDraft"
    ADD CONSTRAINT "MessageDraft_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: MessageReport MessageReport_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MessageReport"
    ADD CONSTRAINT "MessageReport_message_id_fkey" FOREIGN KEY (message_id) REFERENCES public."CoachMessage"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: MessageReport MessageReport_reporter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MessageReport"
    ADD CONSTRAINT "MessageReport_reporter_id_fkey" FOREIGN KEY (reporter_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: MessageReport MessageReport_reviewed_by_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MessageReport"
    ADD CONSTRAINT "MessageReport_reviewed_by_admin_id_fkey" FOREIGN KEY (reviewed_by_admin_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Message Message_recipient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Message"
    ADD CONSTRAINT "Message_recipient_id_fkey" FOREIGN KEY (recipient_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Message Message_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Message"
    ADD CONSTRAINT "Message_sender_id_fkey" FOREIGN KEY (sender_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: NotificationDeliveryLog NotificationDeliveryLog_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NotificationDeliveryLog"
    ADD CONSTRAINT "NotificationDeliveryLog_session_id_fkey" FOREIGN KEY (session_id) REFERENCES public."CoachingSession"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: NotificationDeliveryLog NotificationDeliveryLog_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NotificationDeliveryLog"
    ADD CONSTRAINT "NotificationDeliveryLog_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: NotificationDigestLog NotificationDigestLog_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NotificationDigestLog"
    ADD CONSTRAINT "NotificationDigestLog_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id) ON DELETE CASCADE;


--
-- Name: NotificationPreferences NotificationPreferences_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NotificationPreferences"
    ADD CONSTRAINT "NotificationPreferences_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Notification Notification_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Notification"
    ADD CONSTRAINT "Notification_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id) ON DELETE CASCADE;


--
-- Name: NudgeLog NudgeLog_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."NudgeLog"
    ADD CONSTRAINT "NudgeLog_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: PartialRefundDecision PartialRefundDecision_client_purchase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PartialRefundDecision"
    ADD CONSTRAINT "PartialRefundDecision_client_purchase_id_fkey" FOREIGN KEY (client_purchase_id) REFERENCES public."ClientPurchase"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: PaymentFailure PaymentFailure_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PaymentFailure"
    ADD CONSTRAINT "PaymentFailure_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: PaymentReminder PaymentReminder_purchase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PaymentReminder"
    ADD CONSTRAINT "PaymentReminder_purchase_id_fkey" FOREIGN KEY (purchase_id) REFERENCES public."ClientPurchase"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: PaymentReminder PaymentReminder_recipient_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PaymentReminder"
    ADD CONSTRAINT "PaymentReminder_recipient_user_id_fkey" FOREIGN KEY (recipient_user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: PayoutMethod PayoutMethod_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PayoutMethod"
    ADD CONSTRAINT "PayoutMethod_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: PayoutSnapshot PayoutSnapshot_coach_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PayoutSnapshot"
    ADD CONSTRAINT "PayoutSnapshot_coach_user_id_fkey" FOREIGN KEY (coach_user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: PtmPrediction PtmPrediction_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PtmPrediction"
    ADD CONSTRAINT "PtmPrediction_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: PurchaseFanout PurchaseFanout_purchase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PurchaseFanout"
    ADD CONSTRAINT "PurchaseFanout_purchase_id_fkey" FOREIGN KEY (purchase_id) REFERENCES public."ClientPurchase"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ReconciliationSnapshot ReconciliationSnapshot_purchase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ReconciliationSnapshot"
    ADD CONSTRAINT "ReconciliationSnapshot_purchase_id_fkey" FOREIGN KEY (purchase_id) REFERENCES public."ClientPurchase"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: RomanMessage RomanMessage_parent_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RomanMessage"
    ADD CONSTRAINT "RomanMessage_parent_message_id_fkey" FOREIGN KEY (parent_message_id) REFERENCES public."RomanMessage"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: RomanMessage RomanMessage_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RomanMessage"
    ADD CONSTRAINT "RomanMessage_session_id_fkey" FOREIGN KEY (session_id) REFERENCES public."RomanSession"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: RomanMessage RomanMessage_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RomanMessage"
    ADD CONSTRAINT "RomanMessage_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: RomanSession RomanSession_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RomanSession"
    ADD CONSTRAINT "RomanSession_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: RoutineExercise RoutineExercise_routine_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RoutineExercise"
    ADD CONSTRAINT "RoutineExercise_routine_id_fkey" FOREIGN KEY (routine_id) REFERENCES public."WorkoutRoutine"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ScheduledDrop ScheduledDrop_client_purchase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ScheduledDrop"
    ADD CONSTRAINT "ScheduledDrop_client_purchase_id_fkey" FOREIGN KEY (client_purchase_id) REFERENCES public."ClientPurchase"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SessionParticipant SessionParticipant_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SessionParticipant"
    ADD CONSTRAINT "SessionParticipant_session_id_fkey" FOREIGN KEY (session_id) REFERENCES public."CoachingSession"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SessionParticipant SessionParticipant_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SessionParticipant"
    ADD CONSTRAINT "SessionParticipant_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SessionType SessionType_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SessionType"
    ADD CONSTRAINT "SessionType_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SplitLedgerEntry SplitLedgerEntry_payee_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SplitLedgerEntry"
    ADD CONSTRAINT "SplitLedgerEntry_payee_user_id_fkey" FOREIGN KEY (payee_user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SplitLedgerEntry SplitLedgerEntry_purchase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SplitLedgerEntry"
    ADD CONSTRAINT "SplitLedgerEntry_purchase_id_fkey" FOREIGN KEY (purchase_id) REFERENCES public."ClientPurchase"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SubCoachAssignment SubCoachAssignment_assigned_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SubCoachAssignment"
    ADD CONSTRAINT "SubCoachAssignment_assigned_by_id_fkey" FOREIGN KEY (assigned_by_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SubCoachAssignment SubCoachAssignment_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SubCoachAssignment"
    ADD CONSTRAINT "SubCoachAssignment_client_id_fkey" FOREIGN KEY (client_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SubCoachAssignment SubCoachAssignment_head_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SubCoachAssignment"
    ADD CONSTRAINT "SubCoachAssignment_head_coach_id_fkey" FOREIGN KEY (head_coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SubCoachAssignment SubCoachAssignment_sub_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SubCoachAssignment"
    ADD CONSTRAINT "SubCoachAssignment_sub_coach_id_fkey" FOREIGN KEY (sub_coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SubCoachInvite SubCoachInvite_accepted_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SubCoachInvite"
    ADD CONSTRAINT "SubCoachInvite_accepted_by_user_id_fkey" FOREIGN KEY (accepted_by_user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SubCoachInvite SubCoachInvite_head_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SubCoachInvite"
    ADD CONSTRAINT "SubCoachInvite_head_coach_id_fkey" FOREIGN KEY (head_coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SubCoachMutationIdempotency SubCoachMutationIdempotency_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SubCoachMutationIdempotency"
    ADD CONSTRAINT "SubCoachMutationIdempotency_actor_id_fkey" FOREIGN KEY (actor_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: TeamAuditEvent TeamAuditEvent_head_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TeamAuditEvent"
    ADD CONSTRAINT "TeamAuditEvent_head_coach_id_fkey" FOREIGN KEY (head_coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: TeamAuditEvent TeamAuditEvent_target_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TeamAuditEvent"
    ADD CONSTRAINT "TeamAuditEvent_target_client_id_fkey" FOREIGN KEY (target_client_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: TeamProfile TeamProfile_head_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TeamProfile"
    ADD CONSTRAINT "TeamProfile_head_coach_id_fkey" FOREIGN KEY (head_coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: TeamSubCoachAssignment TeamSubCoachAssignment_head_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TeamSubCoachAssignment"
    ADD CONSTRAINT "TeamSubCoachAssignment_head_coach_id_fkey" FOREIGN KEY (head_coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: TeamSubCoachAssignment TeamSubCoachAssignment_sub_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TeamSubCoachAssignment"
    ADD CONSTRAINT "TeamSubCoachAssignment_sub_coach_id_fkey" FOREIGN KEY (sub_coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: UserAIQuota UserAIQuota_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserAIQuota"
    ADD CONSTRAINT "UserAIQuota_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: UserBlock UserBlock_blocked_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserBlock"
    ADD CONSTRAINT "UserBlock_blocked_id_fkey" FOREIGN KEY (blocked_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: UserBlock UserBlock_blocker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserBlock"
    ADD CONSTRAINT "UserBlock_blocker_id_fkey" FOREIGN KEY (blocker_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: UserProfile UserProfile_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserProfile"
    ADD CONSTRAINT "UserProfile_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: User User_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: User User_default_payout_method_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_default_payout_method_id_fkey" FOREIGN KEY (default_payout_method_id) REFERENCES public."PayoutMethod"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: WearableConnection WearableConnection_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WearableConnection"
    ADD CONSTRAINT "WearableConnection_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: WearableInsightCache WearableInsightCache_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WearableInsightCache"
    ADD CONSTRAINT "WearableInsightCache_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: WearableSample WearableSample_connection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WearableSample"
    ADD CONSTRAINT "WearableSample_connection_id_fkey" FOREIGN KEY (connection_id) REFERENCES public."WearableConnection"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: WearableSample WearableSample_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WearableSample"
    ADD CONSTRAINT "WearableSample_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: WearableUserMetricPreference WearableUserMetricPreference_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WearableUserMetricPreference"
    ADD CONSTRAINT "WearableUserMetricPreference_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: WeightLog WeightLog_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WeightLog"
    ADD CONSTRAINT "WeightLog_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: WorkoutBuilderIdempotencyKey WorkoutBuilderIdempotencyKey_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkoutBuilderIdempotencyKey"
    ADD CONSTRAINT "WorkoutBuilderIdempotencyKey_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: WorkoutPlanExercise WorkoutPlanExercise_workout_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkoutPlanExercise"
    ADD CONSTRAINT "WorkoutPlanExercise_workout_plan_id_fkey" FOREIGN KEY (workout_plan_id) REFERENCES public."WorkoutPlan"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: WorkoutPlanRevision WorkoutPlanRevision_workout_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkoutPlanRevision"
    ADD CONSTRAINT "WorkoutPlanRevision_workout_plan_id_fkey" FOREIGN KEY (workout_plan_id) REFERENCES public."WorkoutPlan"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: WorkoutPlan WorkoutPlan_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkoutPlan"
    ADD CONSTRAINT "WorkoutPlan_coach_id_fkey" FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: WorkoutPlan WorkoutPlan_program_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkoutPlan"
    ADD CONSTRAINT "WorkoutPlan_program_id_fkey" FOREIGN KEY (program_id) REFERENCES public."WorkoutProgram"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: WorkoutProgramRevision WorkoutProgramRevision_program_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkoutProgramRevision"
    ADD CONSTRAINT "WorkoutProgramRevision_program_id_fkey" FOREIGN KEY (program_id) REFERENCES public."WorkoutProgram"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: WorkoutRoutine WorkoutRoutine_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkoutRoutine"
    ADD CONSTRAINT "WorkoutRoutine_creator_id_fkey" FOREIGN KEY (creator_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: WorkoutSession WorkoutSession_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."WorkoutSession"
    ADD CONSTRAINT "WorkoutSession_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: coach_first_payment_notification coach_first_payment_notification_coachId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coach_first_payment_notification
    ADD CONSTRAINT "coach_first_payment_notification_coachId_fkey" FOREIGN KEY ("coachId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: coach_ltv_peak coach_ltv_peak_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coach_ltv_peak
    ADD CONSTRAINT coach_ltv_peak_coach_id_fkey FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_challenge_participations community_challenge_participations_challenge_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_challenge_participations
    ADD CONSTRAINT community_challenge_participations_challenge_id_fkey FOREIGN KEY (challenge_id) REFERENCES public.community_challenges(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_challenge_participations community_challenge_participations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_challenge_participations
    ADD CONSTRAINT community_challenge_participations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_challenge_participations community_challenge_participations_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_challenge_participations
    ADD CONSTRAINT community_challenge_participations_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.community_workspaces(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_challenges community_challenges_cohort_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_challenges
    ADD CONSTRAINT community_challenges_cohort_id_fkey FOREIGN KEY (cohort_id) REFERENCES public.community_cohorts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_challenges community_challenges_created_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_challenges
    ADD CONSTRAINT community_challenges_created_by_id_fkey FOREIGN KEY (created_by_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: community_challenges community_challenges_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_challenges
    ADD CONSTRAINT community_challenges_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.community_workspaces(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_classroom_media_assets community_classroom_media_assets_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_classroom_media_assets
    ADD CONSTRAINT community_classroom_media_assets_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.community_classroom_posts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_classroom_posts community_classroom_posts_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_classroom_posts
    ADD CONSTRAINT community_classroom_posts_coach_id_fkey FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: community_cohorts community_cohorts_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_cohorts
    ADD CONSTRAINT community_cohorts_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.community_workspaces(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_event_rsvps community_event_rsvps_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_event_rsvps
    ADD CONSTRAINT community_event_rsvps_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.community_events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_event_rsvps community_event_rsvps_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_event_rsvps
    ADD CONSTRAINT community_event_rsvps_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_event_rsvps community_event_rsvps_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_event_rsvps
    ADD CONSTRAINT community_event_rsvps_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.community_workspaces(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_events community_events_cohort_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_events
    ADD CONSTRAINT community_events_cohort_id_fkey FOREIGN KEY (cohort_id) REFERENCES public.community_cohorts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_events community_events_created_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_events
    ADD CONSTRAINT community_events_created_by_id_fkey FOREIGN KEY (created_by_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: community_events community_events_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_events
    ADD CONSTRAINT community_events_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.community_workspaces(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_memberships community_memberships_cohort_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_memberships
    ADD CONSTRAINT community_memberships_cohort_id_fkey FOREIGN KEY (cohort_id) REFERENCES public.community_cohorts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_memberships community_memberships_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_memberships
    ADD CONSTRAINT community_memberships_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_memberships community_memberships_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_memberships
    ADD CONSTRAINT community_memberships_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.community_workspaces(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_messages community_messages_cohort_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.community_messages
    ADD CONSTRAINT community_messages_cohort_id_fkey FOREIGN KEY (cohort_id) REFERENCES public.community_cohorts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_messages community_messages_recipient_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.community_messages
    ADD CONSTRAINT community_messages_recipient_user_id_fkey FOREIGN KEY (recipient_user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: community_messages community_messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.community_messages
    ADD CONSTRAINT community_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: community_messages community_messages_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.community_messages
    ADD CONSTRAINT community_messages_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.community_workspaces(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_moderation_actions community_moderation_actions_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_moderation_actions
    ADD CONSTRAINT community_moderation_actions_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: community_moderation_actions community_moderation_actions_reported_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_moderation_actions
    ADD CONSTRAINT community_moderation_actions_reported_by_id_fkey FOREIGN KEY (reported_by_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: community_moderation_actions community_moderation_actions_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_moderation_actions
    ADD CONSTRAINT community_moderation_actions_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.community_workspaces(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_posts community_posts_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_posts
    ADD CONSTRAINT community_posts_author_id_fkey FOREIGN KEY (author_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: community_posts community_posts_cohort_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_posts
    ADD CONSTRAINT community_posts_cohort_id_fkey FOREIGN KEY (cohort_id) REFERENCES public.community_cohorts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_posts community_posts_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_posts
    ADD CONSTRAINT community_posts_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.community_workspaces(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_responses community_responses_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_responses
    ADD CONSTRAINT community_responses_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_responses community_responses_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_responses
    ADD CONSTRAINT community_responses_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.community_workspaces(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_search_entries community_search_entries_cohortId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_search_entries
    ADD CONSTRAINT "community_search_entries_cohortId_fkey" FOREIGN KEY ("cohortId") REFERENCES public.community_cohorts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_search_entries community_search_entries_workspaceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_search_entries
    ADD CONSTRAINT "community_search_entries_workspaceId_fkey" FOREIGN KEY ("workspaceId") REFERENCES public.community_workspaces(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_voice_notes community_voice_notes_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_voice_notes
    ADD CONSTRAINT community_voice_notes_author_id_fkey FOREIGN KEY (author_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: community_voice_notes community_voice_notes_cohort_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_voice_notes
    ADD CONSTRAINT community_voice_notes_cohort_id_fkey FOREIGN KEY (cohort_id) REFERENCES public.community_cohorts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_voice_notes community_voice_notes_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_voice_notes
    ADD CONSTRAINT community_voice_notes_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.community_workspaces(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_wearable_prompt_sources community_wearable_prompt_sources_promptId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_wearable_prompt_sources
    ADD CONSTRAINT "community_wearable_prompt_sources_promptId_fkey" FOREIGN KEY ("promptId") REFERENCES public.community_wearable_prompts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_wearable_prompt_sources community_wearable_prompt_sources_sampleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_wearable_prompt_sources
    ADD CONSTRAINT "community_wearable_prompt_sources_sampleId_fkey" FOREIGN KEY ("sampleId") REFERENCES public."WearableSample"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: community_wearable_prompts community_wearable_prompts_clientId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_wearable_prompts
    ADD CONSTRAINT "community_wearable_prompts_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: community_wearable_prompts community_wearable_prompts_coachId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_wearable_prompts
    ADD CONSTRAINT "community_wearable_prompts_coachId_fkey" FOREIGN KEY ("coachId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: community_wearable_prompts community_wearable_prompts_workspaceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_wearable_prompts
    ADD CONSTRAINT "community_wearable_prompts_workspaceId_fkey" FOREIGN KEY ("workspaceId") REFERENCES public.community_workspaces(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_workspaces community_workspaces_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_workspaces
    ADD CONSTRAINT community_workspaces_coach_id_fkey FOREIGN KEY (coach_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: data_export_request data_export_request_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_export_request
    ADD CONSTRAINT data_export_request_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_logs water_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.water_logs
    ADD CONSTRAINT water_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: AICallLog; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."AICallLog" ENABLE ROW LEVEL SECURITY;

--
-- Name: AIDraft; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."AIDraft" ENABLE ROW LEVEL SECURITY;

--
-- Name: ActivityEvent; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."ActivityEvent" ENABLE ROW LEVEL SECURITY;

--
-- Name: AiActionDraft; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."AiActionDraft" ENABLE ROW LEVEL SECURITY;

--
-- Name: AiRequestAudit; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."AiRequestAudit" ENABLE ROW LEVEL SECURITY;

--
-- Name: AiRoadmap; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."AiRoadmap" ENABLE ROW LEVEL SECURITY;

--
-- Name: Applicant; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."Applicant" ENABLE ROW LEVEL SECURITY;

--
-- Name: Application; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."Application" ENABLE ROW LEVEL SECURITY;

--
-- Name: AuditLog; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."AuditLog" ENABLE ROW LEVEL SECURITY;

--
-- Name: BloodworkAttachment; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."BloodworkAttachment" ENABLE ROW LEVEL SECURITY;

--
-- Name: BloodworkPanel; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."BloodworkPanel" ENABLE ROW LEVEL SECURITY;

--
-- Name: BloodworkResult; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."BloodworkResult" ENABLE ROW LEVEL SECURITY;

--
-- Name: BuildWeekDay; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."BuildWeekDay" ENABLE ROW LEVEL SECURITY;

--
-- Name: BuildWeekDayCompletion; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."BuildWeekDayCompletion" ENABLE ROW LEVEL SECURITY;

--
-- Name: BuildWeekEnrollment; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."BuildWeekEnrollment" ENABLE ROW LEVEL SECURITY;

--
-- Name: CoachCreditPackPurchase CCPP_owner_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "CCPP_owner_all" ON public."CoachCreditPackPurchase" USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: CoachCreditPackPurchase CCPP_self_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "CCPP_self_select" ON public."CoachCreditPackPurchase" FOR SELECT USING (((app.current_user_id() IS NOT NULL) AND (coach_user_id = app.current_user_id())));


--
-- Name: CalendarConnection; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."CalendarConnection" ENABLE ROW LEVEL SECURITY;

--
-- Name: ChargeDispute; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."ChargeDispute" ENABLE ROW LEVEL SECURITY;

--
-- Name: ChargeRefund; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."ChargeRefund" ENABLE ROW LEVEL SECURITY;

--
-- Name: CheckIn; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."CheckIn" ENABLE ROW LEVEL SECURITY;

--
-- Name: ChurnIntervention; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."ChurnIntervention" ENABLE ROW LEVEL SECURITY;

--
-- Name: ChurnIntervention ChurnIntervention_server_only; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "ChurnIntervention_server_only" ON public."ChurnIntervention" USING (false) WITH CHECK (false);


--
-- Name: ClientAssetGrant; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."ClientAssetGrant" ENABLE ROW LEVEL SECURITY;

--
-- Name: ClientCoachConsent; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."ClientCoachConsent" ENABLE ROW LEVEL SECURITY;

--
-- Name: ClientOutcome; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."ClientOutcome" ENABLE ROW LEVEL SECURITY;

--
-- Name: ClientPurchase; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."ClientPurchase" ENABLE ROW LEVEL SECURITY;

--
-- Name: ClientPurchase ClientPurchase_server_only; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "ClientPurchase_server_only" ON public."ClientPurchase" USING (false);


--
-- Name: POLICY "ClientPurchase_server_only" ON "ClientPurchase"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "ClientPurchase_server_only" ON public."ClientPurchase" IS 'Server-only table: deny all direct client/anon access. NestJS backend (service_role) bypasses RLS and enforces ownership via createPaymentIntentForClient / listForClient / listForCoach. To allow direct client SELECT, replace with USING (client_user_id = auth.uid() OR coach_user_id = auth.uid()).';


--
-- Name: ClientSignal; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."ClientSignal" ENABLE ROW LEVEL SECURITY;

--
-- Name: ClientWorkoutAssignment; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."ClientWorkoutAssignment" ENABLE ROW LEVEL SECURITY;

--
-- Name: ClientWorkoutAssignmentSnapshot; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."ClientWorkoutAssignmentSnapshot" ENABLE ROW LEVEL SECURITY;

--
-- Name: CoachAIBudget; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."CoachAIBudget" ENABLE ROW LEVEL SECURITY;

--
-- Name: CoachAIBudget CoachAIBudget_owner_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "CoachAIBudget_owner_all" ON public."CoachAIBudget" USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: CoachAIBudget CoachAIBudget_self_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "CoachAIBudget_self_select" ON public."CoachAIBudget" FOR SELECT USING (((app.current_user_id() IS NOT NULL) AND (coach_user_id = app.current_user_id())));


--
-- Name: CoachAlert; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."CoachAlert" ENABLE ROW LEVEL SECURITY;

--
-- Name: CoachAvailability; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."CoachAvailability" ENABLE ROW LEVEL SECURITY;

--
-- Name: CoachAvailabilityOverride; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."CoachAvailabilityOverride" ENABLE ROW LEVEL SECURITY;

--
-- Name: CoachBrief; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."CoachBrief" ENABLE ROW LEVEL SECURITY;

--
-- Name: CoachBriefPreferences; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."CoachBriefPreferences" ENABLE ROW LEVEL SECURITY;

--
-- Name: CoachBriefPushLedger; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."CoachBriefPushLedger" ENABLE ROW LEVEL SECURITY;

--
-- Name: CoachCreditPackPurchase; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."CoachCreditPackPurchase" ENABLE ROW LEVEL SECURITY;

--
-- Name: CoachCrmIntegration; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."CoachCrmIntegration" ENABLE ROW LEVEL SECURITY;

--
-- Name: CoachDailyLog; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."CoachDailyLog" ENABLE ROW LEVEL SECURITY;

--
-- Name: CoachEffectivenessScore; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."CoachEffectivenessScore" ENABLE ROW LEVEL SECURITY;

--
-- Name: CoachGuideline; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."CoachGuideline" ENABLE ROW LEVEL SECURITY;

--
-- Name: CoachLandingLead; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."CoachLandingLead" ENABLE ROW LEVEL SECURITY;

--
-- Name: CoachLandingPage; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."CoachLandingPage" ENABLE ROW LEVEL SECURITY;

--
-- Name: CoachLandingPageSection; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."CoachLandingPageSection" ENABLE ROW LEVEL SECURITY;

--
-- Name: CoachLandingPageView; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."CoachLandingPageView" ENABLE ROW LEVEL SECURITY;

--
-- Name: CoachMediaAsset; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."CoachMediaAsset" ENABLE ROW LEVEL SECURITY;

--
-- Name: CoachMessage; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."CoachMessage" ENABLE ROW LEVEL SECURITY;

--
-- Name: CoachNudge; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."CoachNudge" ENABLE ROW LEVEL SECURITY;

--
-- Name: CoachOffer; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."CoachOffer" ENABLE ROW LEVEL SECURITY;

--
-- Name: CoachOnboardingProgress; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."CoachOnboardingProgress" ENABLE ROW LEVEL SECURITY;

--
-- Name: CoachPackage; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."CoachPackage" ENABLE ROW LEVEL SECURITY;

--
-- Name: CoachPackageContent; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."CoachPackageContent" ENABLE ROW LEVEL SECURITY;

--
-- Name: CoachPackage CoachPackage_server_only; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "CoachPackage_server_only" ON public."CoachPackage" USING (false);


--
-- Name: POLICY "CoachPackage_server_only" ON "CoachPackage"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "CoachPackage_server_only" ON public."CoachPackage" IS 'Server-only table: deny all direct client/anon access. Reads go through PackagesService. To allow direct client SELECT of active packages, replace with USING (is_active = true AND archived_at IS NULL).';


--
-- Name: CoachProfile; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."CoachProfile" ENABLE ROW LEVEL SECURITY;

--
-- Name: CoachSubscription; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."CoachSubscription" ENABLE ROW LEVEL SECURITY;

--
-- Name: CoachingSession; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."CoachingSession" ENABLE ROW LEVEL SECURITY;

--
-- Name: CommunityWin; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."CommunityWin" ENABLE ROW LEVEL SECURITY;

--
-- Name: ConnectAccount; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."ConnectAccount" ENABLE ROW LEVEL SECURITY;

--
-- Name: ConnectCustomer; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."ConnectCustomer" ENABLE ROW LEVEL SECURITY;

--
-- Name: ConnectCustomer ConnectCustomer_server_only; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "ConnectCustomer_server_only" ON public."ConnectCustomer" USING (false);


--
-- Name: POLICY "ConnectCustomer_server_only" ON "ConnectCustomer"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "ConnectCustomer_server_only" ON public."ConnectCustomer" IS 'Server-only table: deny all direct client/anon access. Stripe customer + default card metadata. NestJS backend (service_role) bypasses RLS. To allow direct client SELECT, replace with USING (client_user_id = auth.uid()).';


--
-- Name: ConnectTransfer; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."ConnectTransfer" ENABLE ROW LEVEL SECURITY;

--
-- Name: ConnectTransfer ConnectTransfer_server_only; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "ConnectTransfer_server_only" ON public."ConnectTransfer" USING (false);


--
-- Name: POLICY "ConnectTransfer_server_only" ON "ConnectTransfer"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "ConnectTransfer_server_only" ON public."ConnectTransfer" IS 'Server-only worker table: deny all direct client/anon access. Backend service_role only.';


--
-- Name: ContractAuditEvent; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."ContractAuditEvent" ENABLE ROW LEVEL SECURITY;

--
-- Name: ContractEnvelope; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."ContractEnvelope" ENABLE ROW LEVEL SECURITY;

--
-- Name: ContractTemplate; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."ContractTemplate" ENABLE ROW LEVEL SECURITY;

--
-- Name: ConversationReview; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."ConversationReview" ENABLE ROW LEVEL SECURITY;

--
-- Name: DailyMealPlan; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."DailyMealPlan" ENABLE ROW LEVEL SECURITY;

--
-- Name: DailyMealPlanAssignment; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."DailyMealPlanAssignment" ENABLE ROW LEVEL SECURITY;

--
-- Name: DailyMealPlanSlot; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."DailyMealPlanSlot" ENABLE ROW LEVEL SECURITY;

--
-- Name: DataExportRequest; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."DataExportRequest" ENABLE ROW LEVEL SECURITY;

--
-- Name: DiagnosticSubmission; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."DiagnosticSubmission" ENABLE ROW LEVEL SECURITY;

--
-- Name: DripResolverMarker; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."DripResolverMarker" ENABLE ROW LEVEL SECURITY;

--
-- Name: DunningAttempt; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."DunningAttempt" ENABLE ROW LEVEL SECURITY;

--
-- Name: DunningState; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."DunningState" ENABLE ROW LEVEL SECURITY;

--
-- Name: DunningState DunningState_server_only; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "DunningState_server_only" ON public."DunningState" USING (false);


--
-- Name: POLICY "DunningState_server_only" ON "DunningState"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "DunningState_server_only" ON public."DunningState" IS 'Server-only table: deny all direct client/anon access. Backend service_role only.';


--
-- Name: EmailSendLog; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."EmailSendLog" ENABLE ROW LEVEL SECURITY;

--
-- Name: ExerciseCatalogItem; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."ExerciseCatalogItem" ENABLE ROW LEVEL SECURITY;

--
-- Name: ExerciseSet; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."ExerciseSet" ENABLE ROW LEVEL SECURITY;

--
-- Name: ExtensionPairCode; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."ExtensionPairCode" ENABLE ROW LEVEL SECURITY;

--
-- Name: FastingWindow; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."FastingWindow" ENABLE ROW LEVEL SECURITY;

--
-- Name: FeePolicy; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."FeePolicy" ENABLE ROW LEVEL SECURITY;

--
-- Name: FeePolicy FeePolicy_server_only; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "FeePolicy_server_only" ON public."FeePolicy" USING (false);


--
-- Name: POLICY "FeePolicy_server_only" ON "FeePolicy"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "FeePolicy_server_only" ON public."FeePolicy" IS 'Server-only table: deny all direct client/anon access. Fee policy overrides must only be visible to platform owners. NestJS backend (service_role) bypasses RLS.';


--
-- Name: FoodItem; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."FoodItem" ENABLE ROW LEVEL SECURITY;

--
-- Name: GuestCheckout; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."GuestCheckout" ENABLE ROW LEVEL SECURITY;

--
-- Name: Habit; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."Habit" ENABLE ROW LEVEL SECURITY;

--
-- Name: HabitLog; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."HabitLog" ENABLE ROW LEVEL SECURITY;

--
-- Name: HolisticInsightCache; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."HolisticInsightCache" ENABLE ROW LEVEL SECURITY;

--
-- Name: InviteCode; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."InviteCode" ENABLE ROW LEVEL SECURITY;

--
-- Name: Invoice; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."Invoice" ENABLE ROW LEVEL SECURITY;

--
-- Name: JobListing; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."JobListing" ENABLE ROW LEVEL SECURITY;

--
-- Name: Lesson; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."Lesson" ENABLE ROW LEVEL SECURITY;

--
-- Name: LessonCompletion; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."LessonCompletion" ENABLE ROW LEVEL SECURITY;

--
-- Name: LoggedFoodEntry; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."LoggedFoodEntry" ENABLE ROW LEVEL SECURITY;

--
-- Name: MacroTarget; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."MacroTarget" ENABLE ROW LEVEL SECURITY;

--
-- Name: MarketplaceAbuseSignal; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."MarketplaceAbuseSignal" ENABLE ROW LEVEL SECURITY;

--
-- Name: MarketplaceConnectEvent; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."MarketplaceConnectEvent" ENABLE ROW LEVEL SECURITY;

--
-- Name: MarketplaceMutationIdempotency; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."MarketplaceMutationIdempotency" ENABLE ROW LEVEL SECURITY;

--
-- Name: MealPlan; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."MealPlan" ENABLE ROW LEVEL SECURITY;

--
-- Name: MealTemplate; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."MealTemplate" ENABLE ROW LEVEL SECURITY;

--
-- Name: Message; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."Message" ENABLE ROW LEVEL SECURITY;

--
-- Name: MessageDraft; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."MessageDraft" ENABLE ROW LEVEL SECURITY;

--
-- Name: MessageReport; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."MessageReport" ENABLE ROW LEVEL SECURITY;

--
-- Name: MuxProcessedEvent; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."MuxProcessedEvent" ENABLE ROW LEVEL SECURITY;

--
-- Name: Notification; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."Notification" ENABLE ROW LEVEL SECURITY;

--
-- Name: NotificationDeliveryLog; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."NotificationDeliveryLog" ENABLE ROW LEVEL SECURITY;

--
-- Name: NotificationDigestLog; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."NotificationDigestLog" ENABLE ROW LEVEL SECURITY;

--
-- Name: NotificationPreferences; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."NotificationPreferences" ENABLE ROW LEVEL SECURITY;

--
-- Name: NudgeLog; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."NudgeLog" ENABLE ROW LEVEL SECURITY;

--
-- Name: PartialRefundDecision; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."PartialRefundDecision" ENABLE ROW LEVEL SECURITY;

--
-- Name: PaymentFailure; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."PaymentFailure" ENABLE ROW LEVEL SECURITY;

--
-- Name: PaymentRecoveryToken; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."PaymentRecoveryToken" ENABLE ROW LEVEL SECURITY;

--
-- Name: PaymentReminder; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."PaymentReminder" ENABLE ROW LEVEL SECURITY;

--
-- Name: PaymentReminder PaymentReminder_server_only; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "PaymentReminder_server_only" ON public."PaymentReminder" USING (false);


--
-- Name: POLICY "PaymentReminder_server_only" ON "PaymentReminder"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "PaymentReminder_server_only" ON public."PaymentReminder" IS 'Server-only table: deny all direct client/anon access. Backend service_role only.';


--
-- Name: PayoutMethod; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."PayoutMethod" ENABLE ROW LEVEL SECURITY;

--
-- Name: PayoutSnapshot; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."PayoutSnapshot" ENABLE ROW LEVEL SECURITY;

--
-- Name: Person; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."Person" ENABLE ROW LEVEL SECURITY;

--
-- Name: PtmPrediction; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."PtmPrediction" ENABLE ROW LEVEL SECURITY;

--
-- Name: PurchaseFanout; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."PurchaseFanout" ENABLE ROW LEVEL SECURITY;

--
-- Name: ReconciliationSnapshot; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."ReconciliationSnapshot" ENABLE ROW LEVEL SECURITY;

--
-- Name: RomanMessage; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."RomanMessage" ENABLE ROW LEVEL SECURITY;

--
-- Name: RomanSession; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."RomanSession" ENABLE ROW LEVEL SECURITY;

--
-- Name: RoutineExercise; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."RoutineExercise" ENABLE ROW LEVEL SECURITY;

--
-- Name: ScheduledDrop; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."ScheduledDrop" ENABLE ROW LEVEL SECURITY;

--
-- Name: ScoutImport; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."ScoutImport" ENABLE ROW LEVEL SECURITY;

--
-- Name: ScoutImportCompletion; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."ScoutImportCompletion" ENABLE ROW LEVEL SECURITY;

--
-- Name: ScoutIngestEntity; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."ScoutIngestEntity" ENABLE ROW LEVEL SECURITY;

--
-- Name: ScoutProgressSnapshot; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."ScoutProgressSnapshot" ENABLE ROW LEVEL SECURITY;

--
-- Name: ScoutReconstructedEntity; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."ScoutReconstructedEntity" ENABLE ROW LEVEL SECURITY;

--
-- Name: ScoutReconstructionLedger; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."ScoutReconstructionLedger" ENABLE ROW LEVEL SECURITY;

--
-- Name: SessionParticipant; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."SessionParticipant" ENABLE ROW LEVEL SECURITY;

--
-- Name: SessionType; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."SessionType" ENABLE ROW LEVEL SECURITY;

--
-- Name: SplitLedgerEntry; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."SplitLedgerEntry" ENABLE ROW LEVEL SECURITY;

--
-- Name: SplitLedgerEntry SplitLedgerEntry_server_only; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "SplitLedgerEntry_server_only" ON public."SplitLedgerEntry" USING (false);


--
-- Name: POLICY "SplitLedgerEntry_server_only" ON "SplitLedgerEntry"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "SplitLedgerEntry_server_only" ON public."SplitLedgerEntry" IS 'Server-only ledger table: deny all direct client/anon access. Backend service_role only.';


--
-- Name: StripeProcessedEvent; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."StripeProcessedEvent" ENABLE ROW LEVEL SECURITY;

--
-- Name: SubCoachAssignment; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."SubCoachAssignment" ENABLE ROW LEVEL SECURITY;

--
-- Name: SubCoachInvite; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."SubCoachInvite" ENABLE ROW LEVEL SECURITY;

--
-- Name: SubCoachInvite SubCoachInvite_server_only; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "SubCoachInvite_server_only" ON public."SubCoachInvite" USING (false);


--
-- Name: POLICY "SubCoachInvite_server_only" ON "SubCoachInvite"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "SubCoachInvite_server_only" ON public."SubCoachInvite" IS 'Server-only table: invite tokens grant team membership and must never be queryable from the client. NestJS backend (service_role) bypasses RLS. Token redemption is via the public-invites controller.';


--
-- Name: SubCoachMutationIdempotency; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."SubCoachMutationIdempotency" ENABLE ROW LEVEL SECURITY;

--
-- Name: TeamAuditEvent; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."TeamAuditEvent" ENABLE ROW LEVEL SECURITY;

--
-- Name: TeamProfile; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."TeamProfile" ENABLE ROW LEVEL SECURITY;

--
-- Name: TeamProfile TeamProfile_server_only; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "TeamProfile_server_only" ON public."TeamProfile" USING (false);


--
-- Name: POLICY "TeamProfile_server_only" ON "TeamProfile"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "TeamProfile_server_only" ON public."TeamProfile" IS 'Server-only table: deny all direct client/anon access. Reads/writes via TeamService. To allow direct head-coach SELECT, replace with USING (head_coach_id = auth.uid()).';


--
-- Name: TeamSubCoachAssignment; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."TeamSubCoachAssignment" ENABLE ROW LEVEL SECURITY;

--
-- Name: User; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."User" ENABLE ROW LEVEL SECURITY;

--
-- Name: UserAIQuota; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."UserAIQuota" ENABLE ROW LEVEL SECURITY;

--
-- Name: UserBlock; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."UserBlock" ENABLE ROW LEVEL SECURITY;

--
-- Name: UserProfile; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."UserProfile" ENABLE ROW LEVEL SECURITY;

--
-- Name: WearableConnection; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."WearableConnection" ENABLE ROW LEVEL SECURITY;

--
-- Name: WearableInsightCache; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."WearableInsightCache" ENABLE ROW LEVEL SECURITY;

--
-- Name: WearableMetricDef; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."WearableMetricDef" ENABLE ROW LEVEL SECURITY;

--
-- Name: WearableProcessedEvent; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."WearableProcessedEvent" ENABLE ROW LEVEL SECURITY;

--
-- Name: WearableSample; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."WearableSample" ENABLE ROW LEVEL SECURITY;

--
-- Name: WearableUserMetricPreference; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."WearableUserMetricPreference" ENABLE ROW LEVEL SECURITY;

--
-- Name: WeightLog; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."WeightLog" ENABLE ROW LEVEL SECURITY;

--
-- Name: WorkoutBuilderIdempotencyKey; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."WorkoutBuilderIdempotencyKey" ENABLE ROW LEVEL SECURITY;

--
-- Name: WorkoutBuilderIdempotencyKey WorkoutBuilderIdempotencyKey_owner; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "WorkoutBuilderIdempotencyKey_owner" ON public."WorkoutBuilderIdempotencyKey" USING ((user_id = ( SELECT "User".id
   FROM public."User"
  WHERE ("User".supabase_id = (auth.uid())::text)))) WITH CHECK ((user_id = ( SELECT "User".id
   FROM public."User"
  WHERE ("User".supabase_id = (auth.uid())::text))));


--
-- Name: WorkoutPlan; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."WorkoutPlan" ENABLE ROW LEVEL SECURITY;

--
-- Name: WorkoutPlanExercise; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."WorkoutPlanExercise" ENABLE ROW LEVEL SECURITY;

--
-- Name: WorkoutPlanExercise WorkoutPlanExercise_through_plan; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "WorkoutPlanExercise_through_plan" ON public."WorkoutPlanExercise" USING ((EXISTS ( SELECT 1
   FROM (public."WorkoutPlan" wp
     JOIN public."User" u ON ((u.id = wp.coach_id)))
  WHERE ((wp.id = "WorkoutPlanExercise".workout_plan_id) AND (u.supabase_id = (auth.uid())::text))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM (public."WorkoutPlan" wp
     JOIN public."User" u ON ((u.id = wp.coach_id)))
  WHERE ((wp.id = "WorkoutPlanExercise".workout_plan_id) AND (u.supabase_id = (auth.uid())::text)))));


--
-- Name: WorkoutPlanRevision; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."WorkoutPlanRevision" ENABLE ROW LEVEL SECURITY;

--
-- Name: WorkoutPlan WorkoutPlan_coach_owner; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "WorkoutPlan_coach_owner" ON public."WorkoutPlan" USING ((coach_id = ( SELECT "User".id
   FROM public."User"
  WHERE ("User".supabase_id = (auth.uid())::text)))) WITH CHECK ((coach_id = ( SELECT "User".id
   FROM public."User"
  WHERE ("User".supabase_id = (auth.uid())::text))));


--
-- Name: WorkoutProgram; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."WorkoutProgram" ENABLE ROW LEVEL SECURITY;

--
-- Name: WorkoutProgramRevision; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."WorkoutProgramRevision" ENABLE ROW LEVEL SECURITY;

--
-- Name: WorkoutRoutine; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."WorkoutRoutine" ENABLE ROW LEVEL SECURITY;

--
-- Name: WorkoutSession; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."WorkoutSession" ENABLE ROW LEVEL SECURITY;

--
-- Name: _prisma_migrations; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public._prisma_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: AiActionDraft ai_action_draft_owner_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY ai_action_draft_owner_all ON public."AiActionDraft" USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: AiActionDraft ai_action_draft_participant_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY ai_action_draft_participant_select ON public."AiActionDraft" FOR SELECT USING (((app.current_user_id() IS NOT NULL) AND ((requester_id = app.current_user_id()) OR (subject_user_id = app.current_user_id()) OR (tenant_coach_id = app.current_user_id()) OR (decided_by_id = app.current_user_id()))));


--
-- Name: AiActionDraft ai_action_draft_requester_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY ai_action_draft_requester_insert ON public."AiActionDraft" FOR INSERT WITH CHECK (((app.current_user_id() IS NOT NULL) AND ((requester_id = app.current_user_id()) OR (tenant_coach_id = app.current_user_id()))));


--
-- Name: AiActionDraft ai_action_draft_tenant_decide_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY ai_action_draft_tenant_decide_update ON public."AiActionDraft" FOR UPDATE USING (((app.current_user_id() IS NOT NULL) AND (tenant_coach_id = app.current_user_id()) AND ((requester_id IS NULL) OR (requester_id <> app.current_user_id())))) WITH CHECK (((app.current_user_id() IS NOT NULL) AND (tenant_coach_id = app.current_user_id()) AND ((requester_id IS NULL) OR (requester_id <> app.current_user_id()))));


--
-- Name: AICallLog ai_call_log_owner_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY ai_call_log_owner_all ON public."AICallLog" USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: AICallLog ai_call_log_participant_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY ai_call_log_participant_insert ON public."AICallLog" FOR INSERT WITH CHECK (((app.current_user_id() IS NOT NULL) AND (("coachId" = app.current_user_id()) OR ("clientId" = app.current_user_id()))));


--
-- Name: AICallLog ai_call_log_participant_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY ai_call_log_participant_select ON public."AICallLog" FOR SELECT USING (((app.current_user_id() IS NOT NULL) AND (("coachId" = app.current_user_id()) OR ("clientId" = app.current_user_id()))));


--
-- Name: AIDraft ai_draft_client_select_approved; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY ai_draft_client_select_approved ON public."AIDraft" FOR SELECT USING (((app.current_user_id() IS NOT NULL) AND ("clientId" = app.current_user_id()) AND (status = 'APPROVED'::public."AIDraftStatus")));


--
-- Name: AIDraft ai_draft_coach_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY ai_draft_coach_all ON public."AIDraft" USING (((app.current_user_id() IS NOT NULL) AND ("coachId" = app.current_user_id()))) WITH CHECK (((app.current_user_id() IS NOT NULL) AND ("coachId" = app.current_user_id())));


--
-- Name: AIDraft ai_draft_owner_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY ai_draft_owner_all ON public."AIDraft" USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: AiRequestAudit ai_request_audit_owner_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY ai_request_audit_owner_all ON public."AiRequestAudit" USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: AiRequestAudit ai_request_audit_participant_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY ai_request_audit_participant_select ON public."AiRequestAudit" FOR SELECT USING (((app.current_user_id() IS NOT NULL) AND ((requester_id = app.current_user_id()) OR (subject_user_id = app.current_user_id()) OR (tenant_coach_id = app.current_user_id()))));


--
-- Name: AiRequestAudit ai_request_audit_requester_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY ai_request_audit_requester_insert ON public."AiRequestAudit" FOR INSERT WITH CHECK (((app.current_user_id() IS NOT NULL) AND ((requester_id = app.current_user_id()) OR (tenant_coach_id = app.current_user_id()))));


--
-- Name: AiRequestAudit ai_request_audit_tenant_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY ai_request_audit_tenant_update ON public."AiRequestAudit" FOR UPDATE USING (((app.current_user_id() IS NOT NULL) AND (tenant_coach_id = app.current_user_id()))) WITH CHECK (((app.current_user_id() IS NOT NULL) AND (tenant_coach_id = app.current_user_id())));


--
-- Name: ClientWorkoutAssignment assignment_client_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY assignment_client_read ON public."ClientWorkoutAssignment" FOR SELECT USING ((client_id = ( SELECT "User".id
   FROM public."User"
  WHERE ("User".supabase_id = (auth.uid())::text))));


--
-- Name: ClientWorkoutAssignment assignment_coach_manage; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY assignment_coach_manage ON public."ClientWorkoutAssignment" USING (((assigned_by_coach_id = ( SELECT "User".id
   FROM public."User"
  WHERE ("User".supabase_id = (auth.uid())::text))) AND (EXISTS ( SELECT 1
   FROM public."User" u
  WHERE ((u.supabase_id = (auth.uid())::text) AND (u.role = ANY (ARRAY['coach'::public."Role", 'owner'::public."Role", 'sub_coach'::public."Role"]))))))) WITH CHECK (((assigned_by_coach_id = ( SELECT "User".id
   FROM public."User"
  WHERE ("User".supabase_id = (auth.uid())::text))) AND (EXISTS ( SELECT 1
   FROM public."User" u
  WHERE ((u.supabase_id = (auth.uid())::text) AND (u.role = ANY (ARRAY['coach'::public."Role", 'owner'::public."Role", 'sub_coach'::public."Role"]))))) AND (EXISTS ( SELECT 1
   FROM public."WorkoutPlan" wp
  WHERE ((wp.id = "ClientWorkoutAssignment".workout_plan_id) AND (wp.coach_id = ( SELECT "User".id
           FROM public."User"
          WHERE ("User".supabase_id = (auth.uid())::text))))))));


--
-- Name: AuditLog audit_log_owner_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY audit_log_owner_all ON public."AuditLog" USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: BloodworkPanel bloodwork_panel_client_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY bloodwork_panel_client_all ON public."BloodworkPanel" USING (((app.current_user_id() IS NOT NULL) AND (client_id = app.current_user_id()))) WITH CHECK (((app.current_user_id() IS NOT NULL) AND (client_id = app.current_user_id()) AND ((coach_id IS NULL) OR app.is_user_coached_by(client_id, coach_id))));


--
-- Name: BloodworkPanel bloodwork_panel_client_or_coach_access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY bloodwork_panel_client_or_coach_access ON public."BloodworkPanel" USING (((client_id = app.current_user_id()) OR (NOT (coach_id IS DISTINCT FROM app.current_user_id())))) WITH CHECK (((client_id = app.current_user_id()) OR (NOT (coach_id IS DISTINCT FROM app.current_user_id()))));


--
-- Name: BloodworkPanel bloodwork_panel_coach_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY bloodwork_panel_coach_select ON public."BloodworkPanel" FOR SELECT USING (((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id())));


--
-- Name: BloodworkPanel bloodwork_panel_current_coach_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY bloodwork_panel_current_coach_insert ON public."BloodworkPanel" FOR INSERT WITH CHECK (((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()) AND app.is_current_coach_of(client_id)));


--
-- Name: BloodworkPanel bloodwork_panel_current_coach_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY bloodwork_panel_current_coach_update ON public."BloodworkPanel" FOR UPDATE USING (((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))) WITH CHECK (((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()) AND app.is_current_coach_of(client_id)));


--
-- Name: BloodworkPanel bloodwork_panel_owner_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY bloodwork_panel_owner_all ON public."BloodworkPanel" USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: CalendarConnection calendar_connection_owner_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY calendar_connection_owner_all ON public."CalendarConnection" USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: CalendarConnection calendar_connection_self_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY calendar_connection_self_all ON public."CalendarConnection" USING (((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()))) WITH CHECK (((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id())));


--
-- Name: CheckIn check_in_client_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY check_in_client_all ON public."CheckIn" USING (((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()))) WITH CHECK (((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()) AND ((coach_id IS NULL) OR app.is_user_coached_by(user_id, coach_id))));


--
-- Name: CheckIn check_in_client_or_coach_access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY check_in_client_or_coach_access ON public."CheckIn" USING (((user_id = app.current_user_id()) OR (NOT (coach_id IS DISTINCT FROM app.current_user_id())))) WITH CHECK (((user_id = app.current_user_id()) OR (NOT (coach_id IS DISTINCT FROM app.current_user_id()))));


--
-- Name: CheckIn check_in_coach_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY check_in_coach_select ON public."CheckIn" FOR SELECT USING (((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id())));


--
-- Name: CheckIn check_in_current_coach_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY check_in_current_coach_insert ON public."CheckIn" FOR INSERT WITH CHECK (((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()) AND app.is_current_coach_of(user_id)));


--
-- Name: CheckIn check_in_current_coach_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY check_in_current_coach_update ON public."CheckIn" FOR UPDATE USING (((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))) WITH CHECK (((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()) AND app.is_current_coach_of(user_id)));


--
-- Name: CheckIn check_in_owner_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY check_in_owner_all ON public."CheckIn" USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: ClientPurchase client_purchase_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY client_purchase_insert ON public."ClientPurchase" FOR INSERT WITH CHECK (((app.current_user_id() IS NOT NULL) AND (coach_user_id = app.current_user_id())));


--
-- Name: ClientPurchase client_purchase_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY client_purchase_select ON public."ClientPurchase" FOR SELECT USING (((app.current_user_id() IS NOT NULL) AND ((client_user_id = app.current_user_id()) OR (coach_user_id = app.current_user_id()))));


--
-- Name: WorkoutPlanExercise client_read_assigned_exercises; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY client_read_assigned_exercises ON public."WorkoutPlanExercise" FOR SELECT USING ((workout_plan_id IN ( SELECT "ClientWorkoutAssignment".workout_plan_id
   FROM public."ClientWorkoutAssignment"
  WHERE ("ClientWorkoutAssignment".client_id = ( SELECT "User".id
           FROM public."User"
          WHERE ("User".supabase_id = (auth.uid())::text))))));


--
-- Name: WorkoutPlan client_read_assigned_plans; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY client_read_assigned_plans ON public."WorkoutPlan" FOR SELECT USING ((id IN ( SELECT "ClientWorkoutAssignment".workout_plan_id
   FROM public."ClientWorkoutAssignment"
  WHERE ("ClientWorkoutAssignment".client_id = ( SELECT "User".id
           FROM public."User"
          WHERE ("User".supabase_id = (auth.uid())::text))))));


--
-- Name: CoachBriefPreferences coach_brief_prefs_service_role_bypass; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY coach_brief_prefs_service_role_bypass ON public."CoachBriefPreferences" TO service_role USING (true) WITH CHECK (true);


--
-- Name: CoachBriefPushLedger coach_brief_push_ledger_service_role_bypass; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY coach_brief_push_ledger_service_role_bypass ON public."CoachBriefPushLedger" TO service_role USING (true) WITH CHECK (true);


--
-- Name: CoachBrief coach_brief_service_role_bypass; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY coach_brief_service_role_bypass ON public."CoachBrief" TO service_role USING (true) WITH CHECK (true);


--
-- Name: CoachDailyLog coach_daily_log_service_role_bypass; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY coach_daily_log_service_role_bypass ON public."CoachDailyLog" TO service_role USING (true) WITH CHECK (true);


--
-- Name: coach_first_payment_notification; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.coach_first_payment_notification ENABLE ROW LEVEL SECURITY;

--
-- Name: CoachBriefPreferences coach_insert_own_brief_prefs; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY coach_insert_own_brief_prefs ON public."CoachBriefPreferences" FOR INSERT WITH CHECK (((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id())));


--
-- Name: CoachDailyLog coach_insert_own_daily_log; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY coach_insert_own_daily_log ON public."CoachDailyLog" FOR INSERT WITH CHECK (((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id())));


--
-- Name: coach_ltv_peak; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.coach_ltv_peak ENABLE ROW LEVEL SECURITY;

--
-- Name: CoachMessage coach_message_participant_access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY coach_message_participant_access ON public."CoachMessage" USING (((NOT (coach_id IS DISTINCT FROM app.current_user_id())) OR (NOT (client_id IS DISTINCT FROM app.current_user_id())) OR (NOT (sender_id IS DISTINCT FROM app.current_user_id())))) WITH CHECK (((NOT (coach_id IS DISTINCT FROM app.current_user_id())) OR (NOT (client_id IS DISTINCT FROM app.current_user_id())) OR (NOT (sender_id IS DISTINCT FROM app.current_user_id()))));


--
-- Name: CoachPackage coach_package_client_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY coach_package_client_select ON public."CoachPackage" FOR SELECT USING (true);


--
-- Name: CoachPackage coach_package_coach_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY coach_package_coach_all ON public."CoachPackage" USING (((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id())));


--
-- Name: CoachProfile coach_profile_owner_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY coach_profile_owner_all ON public."CoachProfile" USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: CoachProfile coach_profile_self_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY coach_profile_self_select ON public."CoachProfile" FOR SELECT USING (((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id())));


--
-- Name: CoachBrief coach_select_own_brief; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY coach_select_own_brief ON public."CoachBrief" FOR SELECT USING (((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id())));


--
-- Name: CoachBriefPreferences coach_select_own_brief_prefs; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY coach_select_own_brief_prefs ON public."CoachBriefPreferences" FOR SELECT USING (((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id())));


--
-- Name: CoachDailyLog coach_select_own_daily_log; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY coach_select_own_daily_log ON public."CoachDailyLog" FOR SELECT USING (((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id())));


--
-- Name: CoachSubscription coach_subscription_owner_access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY coach_subscription_owner_access ON public."CoachSubscription" USING ((coach_id = app.current_user_id())) WITH CHECK ((coach_id = app.current_user_id()));


--
-- Name: CoachBriefPreferences coach_update_own_brief_prefs; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY coach_update_own_brief_prefs ON public."CoachBriefPreferences" FOR UPDATE USING (((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))) WITH CHECK (((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id())));


--
-- Name: CoachDailyLog coach_update_own_daily_log; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY coach_update_own_daily_log ON public."CoachDailyLog" FOR UPDATE USING (((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))) WITH CHECK (((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id())));


--
-- Name: community_challenge_participations; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.community_challenge_participations ENABLE ROW LEVEL SECURITY;

--
-- Name: community_challenge_participations community_challenge_participations_coach_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_challenge_participations_coach_select ON public.community_challenge_participations FOR SELECT USING (app.is_community_workspace_coach(workspace_id));


--
-- Name: community_challenge_participations community_challenge_participations_own_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_challenge_participations_own_all ON public.community_challenge_participations USING ((user_id = app.current_user_id())) WITH CHECK (((user_id = app.current_user_id()) AND app.is_community_workspace_member(workspace_id)));


--
-- Name: community_challenges; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.community_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: community_challenges community_challenges_coach_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_challenges_coach_all ON public.community_challenges USING (app.is_community_workspace_coach(workspace_id)) WITH CHECK (app.is_community_workspace_coach(workspace_id));


--
-- Name: community_challenges community_challenges_member_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_challenges_member_select ON public.community_challenges FOR SELECT USING ((((cohort_id IS NULL) AND app.is_community_workspace_member(workspace_id)) OR ((cohort_id IS NOT NULL) AND app.shares_community_cohort(cohort_id))));


--
-- Name: community_classroom_media_assets; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.community_classroom_media_assets ENABLE ROW LEVEL SECURITY;

--
-- Name: community_classroom_media_assets community_classroom_media_assets_coach_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_classroom_media_assets_coach_all ON public.community_classroom_media_assets USING (app.is_community_workspace_coach(workspace_id)) WITH CHECK (app.is_community_workspace_coach(workspace_id));


--
-- Name: community_classroom_media_assets community_classroom_media_assets_member_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_classroom_media_assets_member_select ON public.community_classroom_media_assets FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.community_classroom_posts p
  WHERE ((p.id = community_classroom_media_assets.post_id) AND (p.status = 'published'::public."CommunityClassroomPostStatus") AND ((p.release_at IS NULL) OR (p.release_at <= now())) AND (p.soft_deleted_at IS NULL) AND (((p.cohort_id IS NULL) AND app.is_community_workspace_member(p.workspace_id)) OR ((p.cohort_id IS NOT NULL) AND app.shares_community_cohort(p.cohort_id)))))));


--
-- Name: community_classroom_posts; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.community_classroom_posts ENABLE ROW LEVEL SECURITY;

--
-- Name: community_classroom_posts community_classroom_posts_coach_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_classroom_posts_coach_all ON public.community_classroom_posts USING (app.is_community_workspace_coach(workspace_id)) WITH CHECK (app.is_community_workspace_coach(workspace_id));


--
-- Name: community_classroom_posts community_classroom_posts_member_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_classroom_posts_member_select ON public.community_classroom_posts FOR SELECT USING (((status = 'published'::public."CommunityClassroomPostStatus") AND ((release_at IS NULL) OR (release_at <= now())) AND (soft_deleted_at IS NULL) AND (((cohort_id IS NULL) AND app.is_community_workspace_member(workspace_id)) OR ((cohort_id IS NOT NULL) AND app.shares_community_cohort(cohort_id)))));


--
-- Name: community_cohorts; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.community_cohorts ENABLE ROW LEVEL SECURITY;

--
-- Name: community_cohorts community_cohorts_coach_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_cohorts_coach_all ON public.community_cohorts USING (app.is_community_workspace_coach(workspace_id)) WITH CHECK (app.is_community_workspace_coach(workspace_id));


--
-- Name: community_cohorts community_cohorts_member_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_cohorts_member_select ON public.community_cohorts FOR SELECT USING (app.shares_community_cohort(id));


--
-- Name: community_event_rsvps; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.community_event_rsvps ENABLE ROW LEVEL SECURITY;

--
-- Name: community_event_rsvps community_event_rsvps_coach_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_event_rsvps_coach_select ON public.community_event_rsvps FOR SELECT USING (app.is_community_workspace_coach(workspace_id));


--
-- Name: community_event_rsvps community_event_rsvps_own_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_event_rsvps_own_all ON public.community_event_rsvps USING ((user_id = app.current_user_id())) WITH CHECK (((user_id = app.current_user_id()) AND app.is_community_workspace_member(workspace_id)));


--
-- Name: community_events; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.community_events ENABLE ROW LEVEL SECURITY;

--
-- Name: community_events community_events_coach_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_events_coach_all ON public.community_events USING (app.is_community_workspace_coach(workspace_id)) WITH CHECK (app.is_community_workspace_coach(workspace_id));


--
-- Name: community_events community_events_member_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_events_member_select ON public.community_events FOR SELECT USING ((((cohort_id IS NULL) AND app.is_community_workspace_member(workspace_id)) OR ((cohort_id IS NOT NULL) AND app.shares_community_cohort(cohort_id))));


--
-- Name: community_memberships; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.community_memberships ENABLE ROW LEVEL SECURITY;

--
-- Name: community_memberships community_memberships_coach_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_memberships_coach_all ON public.community_memberships USING (app.is_community_workspace_coach(workspace_id)) WITH CHECK (app.is_community_workspace_coach(workspace_id));


--
-- Name: community_memberships community_memberships_self_or_shared_cohort_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_memberships_self_or_shared_cohort_select ON public.community_memberships FOR SELECT USING (((user_id = app.current_user_id()) OR app.shares_community_cohort(cohort_id)));


--
-- Name: community_messages; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.community_messages ENABLE ROW LEVEL SECURITY;

--
-- Name: community_messages_2026_12; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.community_messages_2026_12 ENABLE ROW LEVEL SECURITY;

--
-- Name: community_messages_2027_01; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.community_messages_2027_01 ENABLE ROW LEVEL SECURITY;

--
-- Name: community_messages_2027_02; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.community_messages_2027_02 ENABLE ROW LEVEL SECURITY;

--
-- Name: community_messages_2028_03; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.community_messages_2028_03 ENABLE ROW LEVEL SECURITY;

--
-- Name: community_messages community_messages_author_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_messages_author_delete ON public.community_messages FOR DELETE USING (((sender_id = app.current_user_id()) OR app.is_community_workspace_coach(workspace_id)));


--
-- Name: community_messages community_messages_author_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_messages_author_insert ON public.community_messages FOR INSERT WITH CHECK (((sender_id = app.current_user_id()) AND (app.is_community_workspace_coach(workspace_id) OR ((scope = 'cohort'::public."CommunityMessageScope") AND app.shares_community_cohort(cohort_id)) OR ((scope = 'dm'::public."CommunityMessageScope") AND (recipient_user_id IS NOT NULL)))));


--
-- Name: community_messages community_messages_author_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_messages_author_update ON public.community_messages FOR UPDATE USING (((sender_id = app.current_user_id()) OR app.is_community_workspace_coach(workspace_id))) WITH CHECK (((sender_id = app.current_user_id()) OR app.is_community_workspace_coach(workspace_id)));


--
-- Name: community_messages_default; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.community_messages_default ENABLE ROW LEVEL SECURITY;

--
-- Name: community_messages community_messages_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_messages_select ON public.community_messages FOR SELECT USING ((app.is_community_workspace_coach(workspace_id) OR ((scope = 'cohort'::public."CommunityMessageScope") AND app.shares_community_cohort(cohort_id)) OR ((scope = 'dm'::public."CommunityMessageScope") AND ((sender_id = app.current_user_id()) OR (recipient_user_id = app.current_user_id())))));


--
-- Name: community_moderation_actions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.community_moderation_actions ENABLE ROW LEVEL SECURITY;

--
-- Name: community_moderation_actions community_moderation_actions_coach_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_moderation_actions_coach_all ON public.community_moderation_actions USING (app.is_community_workspace_coach(workspace_id)) WITH CHECK (app.is_community_workspace_coach(workspace_id));


--
-- Name: community_moderation_actions community_moderation_actions_reporter_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_moderation_actions_reporter_insert ON public.community_moderation_actions FOR INSERT WITH CHECK (((reported_by_id = app.current_user_id()) AND app.is_community_workspace_member(workspace_id)));


--
-- Name: community_moderation_actions community_moderation_actions_reporter_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_moderation_actions_reporter_select ON public.community_moderation_actions FOR SELECT USING ((reported_by_id = app.current_user_id()));


--
-- Name: community_posts; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.community_posts ENABLE ROW LEVEL SECURITY;

--
-- Name: community_posts community_posts_coach_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_posts_coach_all ON public.community_posts USING (app.is_community_workspace_coach(workspace_id)) WITH CHECK (app.is_community_workspace_coach(workspace_id));


--
-- Name: community_posts community_posts_member_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_posts_member_select ON public.community_posts FOR SELECT USING ((((release_at IS NULL) OR (release_at <= now())) AND ((visibility)::text = 'active'::text) AND (((scope = 'hall'::public."CommunityPostScope") AND app.is_community_workspace_member(workspace_id)) OR ((scope = 'cohort'::public."CommunityPostScope") AND app.shares_community_cohort(cohort_id)))));


--
-- Name: community_responses; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.community_responses ENABLE ROW LEVEL SECURITY;

--
-- Name: community_responses community_responses_coach_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_responses_coach_all ON public.community_responses USING (app.is_community_workspace_coach(workspace_id)) WITH CHECK (app.is_community_workspace_coach(workspace_id));


--
-- Name: community_responses community_responses_member_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_responses_member_select ON public.community_responses FOR SELECT USING (app.is_community_workspace_member(workspace_id));


--
-- Name: community_responses community_responses_own_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_responses_own_delete ON public.community_responses FOR DELETE USING ((user_id = app.current_user_id()));


--
-- Name: community_responses community_responses_own_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_responses_own_insert ON public.community_responses FOR INSERT WITH CHECK (((user_id = app.current_user_id()) AND app.is_community_workspace_member(workspace_id)));


--
-- Name: community_search_entries; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.community_search_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: community_search_entries community_search_entries_coach_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_search_entries_coach_all ON public.community_search_entries USING (app.is_community_workspace_coach("workspaceId")) WITH CHECK (app.is_community_workspace_coach("workspaceId"));


--
-- Name: community_search_entries community_search_entries_member_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_search_entries_member_select ON public.community_search_entries FOR SELECT USING ((("softDeletedAt" IS NULL) AND ((("cohortId" IS NULL) AND app.is_community_workspace_member("workspaceId")) OR (("cohortId" IS NOT NULL) AND app.shares_community_cohort("cohortId")))));


--
-- Name: community_voice_notes; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.community_voice_notes ENABLE ROW LEVEL SECURITY;

--
-- Name: community_voice_notes community_voice_notes_coach_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_voice_notes_coach_all ON public.community_voice_notes USING (app.is_community_workspace_coach(workspace_id)) WITH CHECK (app.is_community_workspace_coach(workspace_id));


--
-- Name: community_voice_notes community_voice_notes_member_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_voice_notes_member_select ON public.community_voice_notes FOR SELECT USING (((soft_deleted_at IS NULL) AND (((conversation_id IS NULL) AND (((cohort_id IS NULL) AND app.is_community_workspace_member(workspace_id)) OR ((cohort_id IS NOT NULL) AND app.shares_community_cohort(cohort_id)))) OR ((conversation_id IS NOT NULL) AND (author_id = app.current_user_id())))));


--
-- Name: community_wearable_prompt_sources; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.community_wearable_prompt_sources ENABLE ROW LEVEL SECURITY;

--
-- Name: community_wearable_prompt_sources community_wearable_prompt_sources_coach_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_wearable_prompt_sources_coach_all ON public.community_wearable_prompt_sources USING ((EXISTS ( SELECT 1
   FROM public.community_wearable_prompts p
  WHERE ((p.id = community_wearable_prompt_sources."promptId") AND app.is_community_workspace_coach(p."workspaceId"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM public.community_wearable_prompts p
  WHERE ((p.id = community_wearable_prompt_sources."promptId") AND app.is_community_workspace_coach(p."workspaceId")))));


--
-- Name: community_wearable_prompts; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.community_wearable_prompts ENABLE ROW LEVEL SECURITY;

--
-- Name: community_wearable_prompts community_wearable_prompts_coach_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_wearable_prompts_coach_all ON public.community_wearable_prompts USING (app.is_community_workspace_coach("workspaceId")) WITH CHECK (app.is_community_workspace_coach("workspaceId"));


--
-- Name: community_workspaces; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.community_workspaces ENABLE ROW LEVEL SECURITY;

--
-- Name: community_workspaces community_workspaces_coach_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_workspaces_coach_all ON public.community_workspaces USING ((coach_id = app.current_user_id())) WITH CHECK ((coach_id = app.current_user_id()));


--
-- Name: community_workspaces community_workspaces_member_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_workspaces_member_select ON public.community_workspaces FOR SELECT USING (app.is_community_workspace_member(id));


--
-- Name: ConnectAccount connect_account_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY connect_account_select ON public."ConnectAccount" FOR SELECT USING (((app.current_user_id() IS NOT NULL) AND (coach_user_id = app.current_user_id())));


--
-- Name: ConnectCustomer connect_customer_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY connect_customer_select ON public."ConnectCustomer" FOR SELECT USING (((app.current_user_id() IS NOT NULL) AND (client_user_id = app.current_user_id())));


--
-- Name: ConnectTransfer connect_transfer_destination_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY connect_transfer_destination_select ON public."ConnectTransfer" FOR SELECT USING (((app.current_user_id() IS NOT NULL) AND (destination_user_id = app.current_user_id())));


--
-- Name: ConnectTransfer connect_transfer_owner_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY connect_transfer_owner_all ON public."ConnectTransfer" USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: ConversationReview conversation_review_owner_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY conversation_review_owner_all ON public."ConversationReview" USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: ConversationReview conversation_review_participant_access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY conversation_review_participant_access ON public."ConversationReview" USING (((app.current_user_id() IS NOT NULL) AND ((coach_id = app.current_user_id()) OR (client_id = app.current_user_id())))) WITH CHECK (((app.current_user_id() IS NOT NULL) AND ((coach_id = app.current_user_id()) OR (client_id = app.current_user_id()))));


--
-- Name: CoachCrmIntegration crm_integration_deny_all_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY crm_integration_deny_all_delete ON public."CoachCrmIntegration" AS RESTRICTIVE FOR DELETE USING (false);


--
-- Name: CoachCrmIntegration crm_integration_deny_all_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY crm_integration_deny_all_insert ON public."CoachCrmIntegration" AS RESTRICTIVE FOR INSERT WITH CHECK (false);


--
-- Name: CoachCrmIntegration crm_integration_deny_all_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY crm_integration_deny_all_select ON public."CoachCrmIntegration" AS RESTRICTIVE FOR SELECT USING (false);


--
-- Name: CoachCrmIntegration crm_integration_deny_all_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY crm_integration_deny_all_update ON public."CoachCrmIntegration" AS RESTRICTIVE FOR UPDATE USING (false) WITH CHECK (false);


--
-- Name: DataExportRequest data_export_owner_access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY data_export_owner_access ON public."DataExportRequest" USING ((user_id = app.current_user_id())) WITH CHECK ((user_id = app.current_user_id()));


--
-- Name: data_export_request; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.data_export_request ENABLE ROW LEVEL SECURITY;

--
-- Name: deletion_audit; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.deletion_audit ENABLE ROW LEVEL SECURITY;

--
-- Name: ClientAssetGrant deny_all_anon_ClientAssetGrant; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "deny_all_anon_ClientAssetGrant" ON public."ClientAssetGrant" AS RESTRICTIVE TO anon USING (false) WITH CHECK (false);


--
-- Name: POLICY "deny_all_anon_ClientAssetGrant" ON "ClientAssetGrant"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "deny_all_anon_ClientAssetGrant" ON public."ClientAssetGrant" IS 'RESTRICTIVE deny-all: anon can never read/write this server-only table (S1-DB-01).';


--
-- Name: CoachMediaAsset deny_all_anon_CoachMediaAsset; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "deny_all_anon_CoachMediaAsset" ON public."CoachMediaAsset" AS RESTRICTIVE TO anon USING (false) WITH CHECK (false);


--
-- Name: POLICY "deny_all_anon_CoachMediaAsset" ON "CoachMediaAsset"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "deny_all_anon_CoachMediaAsset" ON public."CoachMediaAsset" IS 'RESTRICTIVE deny-all: anon can never read/write this server-only table (S1-DB-01).';


--
-- Name: CoachPackageContent deny_all_anon_CoachPackageContent; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "deny_all_anon_CoachPackageContent" ON public."CoachPackageContent" AS RESTRICTIVE TO anon USING (false) WITH CHECK (false);


--
-- Name: POLICY "deny_all_anon_CoachPackageContent" ON "CoachPackageContent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "deny_all_anon_CoachPackageContent" ON public."CoachPackageContent" IS 'RESTRICTIVE deny-all: anon can never read/write this server-only table (S1-DB-01).';


--
-- Name: DripResolverMarker deny_all_anon_DripResolverMarker; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "deny_all_anon_DripResolverMarker" ON public."DripResolverMarker" AS RESTRICTIVE TO anon USING (false) WITH CHECK (false);


--
-- Name: POLICY "deny_all_anon_DripResolverMarker" ON "DripResolverMarker"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "deny_all_anon_DripResolverMarker" ON public."DripResolverMarker" IS 'RESTRICTIVE deny-all: anon can never read/write this server-only table (S1-DB-01).';


--
-- Name: DunningAttempt deny_all_anon_DunningAttempt; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "deny_all_anon_DunningAttempt" ON public."DunningAttempt" AS RESTRICTIVE TO anon USING (false) WITH CHECK (false);


--
-- Name: POLICY "deny_all_anon_DunningAttempt" ON "DunningAttempt"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "deny_all_anon_DunningAttempt" ON public."DunningAttempt" IS 'RESTRICTIVE deny-all: anon can never read/write this server-only table (S1-DB-01).';


--
-- Name: MuxProcessedEvent deny_all_anon_MuxProcessedEvent; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "deny_all_anon_MuxProcessedEvent" ON public."MuxProcessedEvent" AS RESTRICTIVE TO anon USING (false) WITH CHECK (false);


--
-- Name: POLICY "deny_all_anon_MuxProcessedEvent" ON "MuxProcessedEvent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "deny_all_anon_MuxProcessedEvent" ON public."MuxProcessedEvent" IS 'RESTRICTIVE deny-all: anon can never read/write this server-only table (S1-DB-01).';


--
-- Name: NudgeLog deny_all_anon_NudgeLog; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "deny_all_anon_NudgeLog" ON public."NudgeLog" AS RESTRICTIVE TO anon USING (false) WITH CHECK (false);


--
-- Name: POLICY "deny_all_anon_NudgeLog" ON "NudgeLog"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "deny_all_anon_NudgeLog" ON public."NudgeLog" IS 'RESTRICTIVE deny-all: anon can never read/write this server-only table (S1-DB-01).';


--
-- Name: PaymentRecoveryToken deny_all_anon_PaymentRecoveryToken; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "deny_all_anon_PaymentRecoveryToken" ON public."PaymentRecoveryToken" AS RESTRICTIVE TO anon USING (false) WITH CHECK (false);


--
-- Name: POLICY "deny_all_anon_PaymentRecoveryToken" ON "PaymentRecoveryToken"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "deny_all_anon_PaymentRecoveryToken" ON public."PaymentRecoveryToken" IS 'RESTRICTIVE deny-all: anon can never read/write this server-only table (S1-DB-01).';


--
-- Name: PayoutMethod deny_all_anon_PayoutMethod; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "deny_all_anon_PayoutMethod" ON public."PayoutMethod" AS RESTRICTIVE TO anon USING (false) WITH CHECK (false);


--
-- Name: POLICY "deny_all_anon_PayoutMethod" ON "PayoutMethod"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "deny_all_anon_PayoutMethod" ON public."PayoutMethod" IS 'RESTRICTIVE deny-all: anon can never read/write this server-only table (S1-DB-01).';


--
-- Name: PurchaseFanout deny_all_anon_PurchaseFanout; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "deny_all_anon_PurchaseFanout" ON public."PurchaseFanout" AS RESTRICTIVE TO anon USING (false) WITH CHECK (false);


--
-- Name: POLICY "deny_all_anon_PurchaseFanout" ON "PurchaseFanout"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "deny_all_anon_PurchaseFanout" ON public."PurchaseFanout" IS 'RESTRICTIVE deny-all: anon can never read/write this server-only table (S1-DB-01).';


--
-- Name: ScheduledDrop deny_all_anon_ScheduledDrop; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "deny_all_anon_ScheduledDrop" ON public."ScheduledDrop" AS RESTRICTIVE TO anon USING (false) WITH CHECK (false);


--
-- Name: POLICY "deny_all_anon_ScheduledDrop" ON "ScheduledDrop"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "deny_all_anon_ScheduledDrop" ON public."ScheduledDrop" IS 'RESTRICTIVE deny-all: anon can never read/write this server-only table (S1-DB-01).';


--
-- Name: UserAIQuota deny_all_anon_UserAIQuota; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "deny_all_anon_UserAIQuota" ON public."UserAIQuota" AS RESTRICTIVE TO anon USING (false) WITH CHECK (false);


--
-- Name: POLICY "deny_all_anon_UserAIQuota" ON "UserAIQuota"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "deny_all_anon_UserAIQuota" ON public."UserAIQuota" IS 'RESTRICTIVE deny-all: anon can never read/write this server-only table (S1-DB-01).';


--
-- Name: coach_ltv_peak deny_all_anon_coach_ltv_peak; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_anon_coach_ltv_peak ON public.coach_ltv_peak AS RESTRICTIVE TO anon USING (false) WITH CHECK (false);


--
-- Name: POLICY deny_all_anon_coach_ltv_peak ON coach_ltv_peak; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY deny_all_anon_coach_ltv_peak ON public.coach_ltv_peak IS 'RESTRICTIVE deny-all: anon can never read/write this server-only table (S1-DB-01).';


--
-- Name: community_messages_2026_12 deny_all_anon_community_messages_2026_12; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_anon_community_messages_2026_12 ON public.community_messages_2026_12 AS RESTRICTIVE TO anon USING (false) WITH CHECK (false);


--
-- Name: community_messages_2027_01 deny_all_anon_community_messages_2027_01; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_anon_community_messages_2027_01 ON public.community_messages_2027_01 AS RESTRICTIVE TO anon USING (false) WITH CHECK (false);


--
-- Name: community_messages_2027_02 deny_all_anon_community_messages_2027_02; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_anon_community_messages_2027_02 ON public.community_messages_2027_02 AS RESTRICTIVE TO anon USING (false) WITH CHECK (false);


--
-- Name: community_messages_2028_03 deny_all_anon_community_messages_2028_03; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_anon_community_messages_2028_03 ON public.community_messages_2028_03 AS RESTRICTIVE TO anon USING (false) WITH CHECK (false);


--
-- Name: community_messages_default deny_all_anon_community_messages_default; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_anon_community_messages_default ON public.community_messages_default AS RESTRICTIVE TO anon USING (false) WITH CHECK (false);


--
-- Name: ExtensionPairCode deny_all_anon_extension_pair_code; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_anon_extension_pair_code ON public."ExtensionPairCode" AS RESTRICTIVE TO anon USING (false);


--
-- Name: MarketplaceAbuseSignal deny_all_anon_marketplace_abuse_signal; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_anon_marketplace_abuse_signal ON public."MarketplaceAbuseSignal" AS RESTRICTIVE TO anon USING (false) WITH CHECK (false);


--
-- Name: POLICY deny_all_anon_marketplace_abuse_signal ON "MarketplaceAbuseSignal"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY deny_all_anon_marketplace_abuse_signal ON public."MarketplaceAbuseSignal" IS 'RESTRICTIVE deny-all: anon can never read/write the abuse-signal store regardless of any permissive policy.';


--
-- Name: MarketplaceConnectEvent deny_all_anon_marketplace_connect_event; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_anon_marketplace_connect_event ON public."MarketplaceConnectEvent" AS RESTRICTIVE TO anon USING (false) WITH CHECK (false);


--
-- Name: POLICY deny_all_anon_marketplace_connect_event ON "MarketplaceConnectEvent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY deny_all_anon_marketplace_connect_event ON public."MarketplaceConnectEvent" IS 'RESTRICTIVE deny-all: anon can never read/write the Connect-event ledger regardless of any permissive policy.';


--
-- Name: MarketplaceMutationIdempotency deny_all_anon_marketplace_idempotency; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_anon_marketplace_idempotency ON public."MarketplaceMutationIdempotency" AS RESTRICTIVE TO anon USING (false) WITH CHECK (false);


--
-- Name: POLICY deny_all_anon_marketplace_idempotency ON "MarketplaceMutationIdempotency"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY deny_all_anon_marketplace_idempotency ON public."MarketplaceMutationIdempotency" IS 'RESTRICTIVE deny-all: anon can never read/write the ledger regardless of any permissive policy.';


--
-- Name: Person deny_all_anon_person; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_anon_person ON public."Person" AS RESTRICTIVE TO anon USING (false) WITH CHECK (false);


--
-- Name: POLICY deny_all_anon_person ON "Person"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY deny_all_anon_person ON public."Person" IS 'RESTRICTIVE deny-all: anon can never read/write roster records regardless of any permissive policy.';


--
-- Name: recent_auth_nonce deny_all_anon_recent_auth_nonce; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_anon_recent_auth_nonce ON public.recent_auth_nonce AS RESTRICTIVE TO anon USING (false) WITH CHECK (false);


--
-- Name: POLICY deny_all_anon_recent_auth_nonce ON recent_auth_nonce; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY deny_all_anon_recent_auth_nonce ON public.recent_auth_nonce IS 'RESTRICTIVE deny-all: anon can never read/write this server-only table (S1-DB-01).';


--
-- Name: ScoutImport deny_all_anon_scout_import; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_anon_scout_import ON public."ScoutImport" AS RESTRICTIVE TO anon USING (false) WITH CHECK (false);


--
-- Name: POLICY deny_all_anon_scout_import ON "ScoutImport"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY deny_all_anon_scout_import ON public."ScoutImport" IS 'RESTRICTIVE deny-all: anon can never read/write the import lifecycle row.';


--
-- Name: ScoutImportCompletion deny_all_anon_scout_import_completion; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_anon_scout_import_completion ON public."ScoutImportCompletion" AS RESTRICTIVE TO anon USING (false) WITH CHECK (false);


--
-- Name: POLICY deny_all_anon_scout_import_completion ON "ScoutImportCompletion"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY deny_all_anon_scout_import_completion ON public."ScoutImportCompletion" IS 'RESTRICTIVE deny-all: anon can never read/write the completion ledger.';


--
-- Name: ScoutIngestEntity deny_all_anon_scout_ingest; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_anon_scout_ingest ON public."ScoutIngestEntity" AS RESTRICTIVE TO anon USING (false) WITH CHECK (false);


--
-- Name: POLICY deny_all_anon_scout_ingest ON "ScoutIngestEntity"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY deny_all_anon_scout_ingest ON public."ScoutIngestEntity" IS 'RESTRICTIVE deny-all: anon can never read/write crawl data regardless of any permissive policy.';


--
-- Name: ScoutProgressSnapshot deny_all_anon_scout_progress_snapshot; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_anon_scout_progress_snapshot ON public."ScoutProgressSnapshot" AS RESTRICTIVE TO anon USING (false) WITH CHECK (false);


--
-- Name: POLICY deny_all_anon_scout_progress_snapshot ON "ScoutProgressSnapshot"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY deny_all_anon_scout_progress_snapshot ON public."ScoutProgressSnapshot" IS 'RESTRICTIVE deny-all: anon can never read/write scout progress snapshots.';


--
-- Name: ScoutReconstructedEntity deny_all_anon_scout_reconstructed_entity; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_anon_scout_reconstructed_entity ON public."ScoutReconstructedEntity" AS RESTRICTIVE TO anon USING (false) WITH CHECK (false);


--
-- Name: POLICY deny_all_anon_scout_reconstructed_entity ON "ScoutReconstructedEntity"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY deny_all_anon_scout_reconstructed_entity ON public."ScoutReconstructedEntity" IS 'RESTRICTIVE deny-all: anon can never read/write reconstructed entities regardless of any permissive policy.';


--
-- Name: ScoutReconstructionLedger deny_all_anon_scout_reconstruction; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_anon_scout_reconstruction ON public."ScoutReconstructionLedger" AS RESTRICTIVE TO anon USING (false) WITH CHECK (false);


--
-- Name: POLICY deny_all_anon_scout_reconstruction ON "ScoutReconstructionLedger"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY deny_all_anon_scout_reconstruction ON public."ScoutReconstructionLedger" IS 'RESTRICTIVE deny-all: anon can never read/write the reconciliation ledger regardless of any permissive policy.';


--
-- Name: SubCoachAssignment deny_all_anon_subcoach_assignment; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_anon_subcoach_assignment ON public."SubCoachAssignment" AS RESTRICTIVE TO anon USING (false);


--
-- Name: SubCoachMutationIdempotency deny_all_anon_subcoach_idempotency; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_anon_subcoach_idempotency ON public."SubCoachMutationIdempotency" AS RESTRICTIVE TO anon USING (false);


--
-- Name: ClientAssetGrant deny_all_authenticated_ClientAssetGrant; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "deny_all_authenticated_ClientAssetGrant" ON public."ClientAssetGrant" AS RESTRICTIVE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: POLICY "deny_all_authenticated_ClientAssetGrant" ON "ClientAssetGrant"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "deny_all_authenticated_ClientAssetGrant" ON public."ClientAssetGrant" IS 'RESTRICTIVE deny-all: authenticated principals can never read/write this server-only table (S1-DB-01).';


--
-- Name: CoachMediaAsset deny_all_authenticated_CoachMediaAsset; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "deny_all_authenticated_CoachMediaAsset" ON public."CoachMediaAsset" AS RESTRICTIVE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: POLICY "deny_all_authenticated_CoachMediaAsset" ON "CoachMediaAsset"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "deny_all_authenticated_CoachMediaAsset" ON public."CoachMediaAsset" IS 'RESTRICTIVE deny-all: authenticated principals can never read/write this server-only table (S1-DB-01).';


--
-- Name: CoachPackageContent deny_all_authenticated_CoachPackageContent; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "deny_all_authenticated_CoachPackageContent" ON public."CoachPackageContent" AS RESTRICTIVE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: POLICY "deny_all_authenticated_CoachPackageContent" ON "CoachPackageContent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "deny_all_authenticated_CoachPackageContent" ON public."CoachPackageContent" IS 'RESTRICTIVE deny-all: authenticated principals can never read/write this server-only table (S1-DB-01).';


--
-- Name: DripResolverMarker deny_all_authenticated_DripResolverMarker; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "deny_all_authenticated_DripResolverMarker" ON public."DripResolverMarker" AS RESTRICTIVE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: POLICY "deny_all_authenticated_DripResolverMarker" ON "DripResolverMarker"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "deny_all_authenticated_DripResolverMarker" ON public."DripResolverMarker" IS 'RESTRICTIVE deny-all: authenticated principals can never read/write this server-only table (S1-DB-01).';


--
-- Name: DunningAttempt deny_all_authenticated_DunningAttempt; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "deny_all_authenticated_DunningAttempt" ON public."DunningAttempt" AS RESTRICTIVE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: POLICY "deny_all_authenticated_DunningAttempt" ON "DunningAttempt"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "deny_all_authenticated_DunningAttempt" ON public."DunningAttempt" IS 'RESTRICTIVE deny-all: authenticated principals can never read/write this server-only table (S1-DB-01).';


--
-- Name: MuxProcessedEvent deny_all_authenticated_MuxProcessedEvent; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "deny_all_authenticated_MuxProcessedEvent" ON public."MuxProcessedEvent" AS RESTRICTIVE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: POLICY "deny_all_authenticated_MuxProcessedEvent" ON "MuxProcessedEvent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "deny_all_authenticated_MuxProcessedEvent" ON public."MuxProcessedEvent" IS 'RESTRICTIVE deny-all: authenticated principals can never read/write this server-only table (S1-DB-01).';


--
-- Name: NudgeLog deny_all_authenticated_NudgeLog; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "deny_all_authenticated_NudgeLog" ON public."NudgeLog" AS RESTRICTIVE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: POLICY "deny_all_authenticated_NudgeLog" ON "NudgeLog"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "deny_all_authenticated_NudgeLog" ON public."NudgeLog" IS 'RESTRICTIVE deny-all: authenticated principals can never read/write this server-only table (S1-DB-01).';


--
-- Name: PaymentRecoveryToken deny_all_authenticated_PaymentRecoveryToken; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "deny_all_authenticated_PaymentRecoveryToken" ON public."PaymentRecoveryToken" AS RESTRICTIVE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: POLICY "deny_all_authenticated_PaymentRecoveryToken" ON "PaymentRecoveryToken"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "deny_all_authenticated_PaymentRecoveryToken" ON public."PaymentRecoveryToken" IS 'RESTRICTIVE deny-all: authenticated principals can never read/write this server-only table (S1-DB-01).';


--
-- Name: PayoutMethod deny_all_authenticated_PayoutMethod; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "deny_all_authenticated_PayoutMethod" ON public."PayoutMethod" AS RESTRICTIVE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: POLICY "deny_all_authenticated_PayoutMethod" ON "PayoutMethod"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "deny_all_authenticated_PayoutMethod" ON public."PayoutMethod" IS 'RESTRICTIVE deny-all: authenticated principals can never read/write this server-only table (S1-DB-01).';


--
-- Name: PurchaseFanout deny_all_authenticated_PurchaseFanout; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "deny_all_authenticated_PurchaseFanout" ON public."PurchaseFanout" AS RESTRICTIVE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: POLICY "deny_all_authenticated_PurchaseFanout" ON "PurchaseFanout"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "deny_all_authenticated_PurchaseFanout" ON public."PurchaseFanout" IS 'RESTRICTIVE deny-all: authenticated principals can never read/write this server-only table (S1-DB-01).';


--
-- Name: ScheduledDrop deny_all_authenticated_ScheduledDrop; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "deny_all_authenticated_ScheduledDrop" ON public."ScheduledDrop" AS RESTRICTIVE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: POLICY "deny_all_authenticated_ScheduledDrop" ON "ScheduledDrop"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "deny_all_authenticated_ScheduledDrop" ON public."ScheduledDrop" IS 'RESTRICTIVE deny-all: authenticated principals can never read/write this server-only table (S1-DB-01).';


--
-- Name: UserAIQuota deny_all_authenticated_UserAIQuota; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "deny_all_authenticated_UserAIQuota" ON public."UserAIQuota" AS RESTRICTIVE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: POLICY "deny_all_authenticated_UserAIQuota" ON "UserAIQuota"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "deny_all_authenticated_UserAIQuota" ON public."UserAIQuota" IS 'RESTRICTIVE deny-all: authenticated principals can never read/write this server-only table (S1-DB-01).';


--
-- Name: coach_ltv_peak deny_all_authenticated_coach_ltv_peak; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_authenticated_coach_ltv_peak ON public.coach_ltv_peak AS RESTRICTIVE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: POLICY deny_all_authenticated_coach_ltv_peak ON coach_ltv_peak; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY deny_all_authenticated_coach_ltv_peak ON public.coach_ltv_peak IS 'RESTRICTIVE deny-all: authenticated principals can never read/write this server-only table (S1-DB-01).';


--
-- Name: community_messages_2026_12 deny_all_authenticated_community_messages_2026_12; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_authenticated_community_messages_2026_12 ON public.community_messages_2026_12 AS RESTRICTIVE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: community_messages_2027_01 deny_all_authenticated_community_messages_2027_01; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_authenticated_community_messages_2027_01 ON public.community_messages_2027_01 AS RESTRICTIVE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: community_messages_2027_02 deny_all_authenticated_community_messages_2027_02; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_authenticated_community_messages_2027_02 ON public.community_messages_2027_02 AS RESTRICTIVE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: community_messages_2028_03 deny_all_authenticated_community_messages_2028_03; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_authenticated_community_messages_2028_03 ON public.community_messages_2028_03 AS RESTRICTIVE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: community_messages_default deny_all_authenticated_community_messages_default; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_authenticated_community_messages_default ON public.community_messages_default AS RESTRICTIVE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: ExtensionPairCode deny_all_authenticated_extension_pair_code; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_authenticated_extension_pair_code ON public."ExtensionPairCode" AS RESTRICTIVE TO authenticated USING (false);


--
-- Name: MarketplaceAbuseSignal deny_all_authenticated_marketplace_abuse_signal; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_authenticated_marketplace_abuse_signal ON public."MarketplaceAbuseSignal" AS RESTRICTIVE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: POLICY deny_all_authenticated_marketplace_abuse_signal ON "MarketplaceAbuseSignal"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY deny_all_authenticated_marketplace_abuse_signal ON public."MarketplaceAbuseSignal" IS 'RESTRICTIVE deny-all: authenticated principals can never read/write the abuse-signal store; only service_role (Primitive A) may.';


--
-- Name: MarketplaceConnectEvent deny_all_authenticated_marketplace_connect_event; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_authenticated_marketplace_connect_event ON public."MarketplaceConnectEvent" AS RESTRICTIVE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: POLICY deny_all_authenticated_marketplace_connect_event ON "MarketplaceConnectEvent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY deny_all_authenticated_marketplace_connect_event ON public."MarketplaceConnectEvent" IS 'RESTRICTIVE deny-all: authenticated principals can never read/write the Connect-event ledger; only service_role (Primitive A) may.';


--
-- Name: MarketplaceMutationIdempotency deny_all_authenticated_marketplace_idempotency; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_authenticated_marketplace_idempotency ON public."MarketplaceMutationIdempotency" AS RESTRICTIVE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: POLICY deny_all_authenticated_marketplace_idempotency ON "MarketplaceMutationIdempotency"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY deny_all_authenticated_marketplace_idempotency ON public."MarketplaceMutationIdempotency" IS 'RESTRICTIVE deny-all: authenticated principals can never read/write the ledger; only service_role (Primitive A) may.';


--
-- Name: Person deny_all_authenticated_person; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_authenticated_person ON public."Person" AS RESTRICTIVE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: POLICY deny_all_authenticated_person ON "Person"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY deny_all_authenticated_person ON public."Person" IS 'RESTRICTIVE deny-all: authenticated principals can never read/write roster records directly; only service_role may (no cross-tenant oracle).';


--
-- Name: recent_auth_nonce deny_all_authenticated_recent_auth_nonce; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_authenticated_recent_auth_nonce ON public.recent_auth_nonce AS RESTRICTIVE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: POLICY deny_all_authenticated_recent_auth_nonce ON recent_auth_nonce; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY deny_all_authenticated_recent_auth_nonce ON public.recent_auth_nonce IS 'RESTRICTIVE deny-all: authenticated principals can never read/write this server-only table (S1-DB-01).';


--
-- Name: ScoutImport deny_all_authenticated_scout_import; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_authenticated_scout_import ON public."ScoutImport" AS RESTRICTIVE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: POLICY deny_all_authenticated_scout_import ON "ScoutImport"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY deny_all_authenticated_scout_import ON public."ScoutImport" IS 'RESTRICTIVE deny-all: authenticated principals can never read/write the import lifecycle row; only service_role may.';


--
-- Name: ScoutImportCompletion deny_all_authenticated_scout_import_completion; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_authenticated_scout_import_completion ON public."ScoutImportCompletion" AS RESTRICTIVE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: POLICY deny_all_authenticated_scout_import_completion ON "ScoutImportCompletion"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY deny_all_authenticated_scout_import_completion ON public."ScoutImportCompletion" IS 'RESTRICTIVE deny-all: authenticated principals can never read/write the completion ledger; only service_role may.';


--
-- Name: ScoutIngestEntity deny_all_authenticated_scout_ingest; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_authenticated_scout_ingest ON public."ScoutIngestEntity" AS RESTRICTIVE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: POLICY deny_all_authenticated_scout_ingest ON "ScoutIngestEntity"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY deny_all_authenticated_scout_ingest ON public."ScoutIngestEntity" IS 'RESTRICTIVE deny-all: authenticated principals can never read/write crawl data; only service_role may.';


--
-- Name: ScoutProgressSnapshot deny_all_authenticated_scout_progress_snapshot; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_authenticated_scout_progress_snapshot ON public."ScoutProgressSnapshot" AS RESTRICTIVE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: POLICY deny_all_authenticated_scout_progress_snapshot ON "ScoutProgressSnapshot"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY deny_all_authenticated_scout_progress_snapshot ON public."ScoutProgressSnapshot" IS 'RESTRICTIVE deny-all: authenticated principals can never read/write scout progress snapshots; only service_role may.';


--
-- Name: ScoutReconstructedEntity deny_all_authenticated_scout_reconstructed_entity; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_authenticated_scout_reconstructed_entity ON public."ScoutReconstructedEntity" AS RESTRICTIVE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: POLICY deny_all_authenticated_scout_reconstructed_entity ON "ScoutReconstructedEntity"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY deny_all_authenticated_scout_reconstructed_entity ON public."ScoutReconstructedEntity" IS 'RESTRICTIVE deny-all: authenticated principals can never read/write reconstructed entities directly; only service_role may (no cross-tenant oracle).';


--
-- Name: ScoutReconstructionLedger deny_all_authenticated_scout_reconstruction; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_authenticated_scout_reconstruction ON public."ScoutReconstructionLedger" AS RESTRICTIVE TO authenticated USING (false) WITH CHECK (false);


--
-- Name: POLICY deny_all_authenticated_scout_reconstruction ON "ScoutReconstructionLedger"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY deny_all_authenticated_scout_reconstruction ON public."ScoutReconstructionLedger" IS 'RESTRICTIVE deny-all: authenticated principals can never read/write the ledger directly; only service_role may.';


--
-- Name: SubCoachAssignment deny_all_authenticated_subcoach_assignment; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_authenticated_subcoach_assignment ON public."SubCoachAssignment" AS RESTRICTIVE TO authenticated USING (false);


--
-- Name: SubCoachMutationIdempotency deny_all_authenticated_subcoach_idempotency; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY deny_all_authenticated_subcoach_idempotency ON public."SubCoachMutationIdempotency" AS RESTRICTIVE TO authenticated USING (false);


--
-- Name: FastingWindow fasting_window_current_coach_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY fasting_window_current_coach_select ON public."FastingWindow" FOR SELECT USING (((app.current_user_id() IS NOT NULL) AND app.is_current_coach_of(user_id)));


--
-- Name: FastingWindow fasting_window_owner_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY fasting_window_owner_all ON public."FastingWindow" USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: FastingWindow fasting_window_user_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY fasting_window_user_all ON public."FastingWindow" USING (((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()))) WITH CHECK (((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id())));


--
-- Name: LoggedFoodEntry food_entry_owner_access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY food_entry_owner_access ON public."LoggedFoodEntry" USING ((user_id = app.current_user_id())) WITH CHECK ((user_id = app.current_user_id()));


--
-- Name: GuestCheckout guest_checkout_deny_all_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY guest_checkout_deny_all_delete ON public."GuestCheckout" AS RESTRICTIVE FOR DELETE USING (false);


--
-- Name: GuestCheckout guest_checkout_deny_all_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY guest_checkout_deny_all_insert ON public."GuestCheckout" AS RESTRICTIVE FOR INSERT WITH CHECK (false);


--
-- Name: GuestCheckout guest_checkout_deny_all_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY guest_checkout_deny_all_select ON public."GuestCheckout" AS RESTRICTIVE FOR SELECT USING (false);


--
-- Name: GuestCheckout guest_checkout_deny_all_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY guest_checkout_deny_all_update ON public."GuestCheckout" AS RESTRICTIVE FOR UPDATE USING (false) WITH CHECK (false);


--
-- Name: Habit habit_owner_access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY habit_owner_access ON public."Habit" USING ((user_id = app.current_user_id())) WITH CHECK ((user_id = app.current_user_id()));


--
-- Name: InviteCode invite_code_coach_owner_access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY invite_code_coach_owner_access ON public."InviteCode" USING (((coach_id = app.current_user_id()) OR (NOT (invited_by_user_id IS DISTINCT FROM app.current_user_id())))) WITH CHECK (((coach_id = app.current_user_id()) OR (NOT (invited_by_user_id IS DISTINCT FROM app.current_user_id()))));


--
-- Name: Invoice invoice_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY invoice_select ON public."Invoice" FOR SELECT USING (((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id())));


--
-- Name: CoachLandingLead landing_lead_deny_all_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY landing_lead_deny_all_delete ON public."CoachLandingLead" AS RESTRICTIVE FOR DELETE USING (false);


--
-- Name: CoachLandingLead landing_lead_deny_all_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY landing_lead_deny_all_insert ON public."CoachLandingLead" AS RESTRICTIVE FOR INSERT WITH CHECK (false);


--
-- Name: CoachLandingLead landing_lead_deny_all_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY landing_lead_deny_all_select ON public."CoachLandingLead" AS RESTRICTIVE FOR SELECT USING (false);


--
-- Name: CoachLandingLead landing_lead_deny_all_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY landing_lead_deny_all_update ON public."CoachLandingLead" AS RESTRICTIVE FOR UPDATE USING (false) WITH CHECK (false);


--
-- Name: CoachLandingPage landing_page_deny_all_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY landing_page_deny_all_delete ON public."CoachLandingPage" AS RESTRICTIVE FOR DELETE USING (false);


--
-- Name: CoachLandingPage landing_page_deny_all_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY landing_page_deny_all_insert ON public."CoachLandingPage" AS RESTRICTIVE FOR INSERT WITH CHECK (false);


--
-- Name: CoachLandingPage landing_page_deny_all_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY landing_page_deny_all_select ON public."CoachLandingPage" AS RESTRICTIVE FOR SELECT USING (false);


--
-- Name: CoachLandingPage landing_page_deny_all_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY landing_page_deny_all_update ON public."CoachLandingPage" AS RESTRICTIVE FOR UPDATE USING (false) WITH CHECK (false);


--
-- Name: CoachLandingPageSection landing_section_deny_all_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY landing_section_deny_all_delete ON public."CoachLandingPageSection" AS RESTRICTIVE FOR DELETE USING (false);


--
-- Name: CoachLandingPageSection landing_section_deny_all_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY landing_section_deny_all_insert ON public."CoachLandingPageSection" AS RESTRICTIVE FOR INSERT WITH CHECK (false);


--
-- Name: CoachLandingPageSection landing_section_deny_all_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY landing_section_deny_all_select ON public."CoachLandingPageSection" AS RESTRICTIVE FOR SELECT USING (false);


--
-- Name: CoachLandingPageSection landing_section_deny_all_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY landing_section_deny_all_update ON public."CoachLandingPageSection" AS RESTRICTIVE FOR UPDATE USING (false) WITH CHECK (false);


--
-- Name: CoachLandingPageView landing_view_deny_all_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY landing_view_deny_all_delete ON public."CoachLandingPageView" AS RESTRICTIVE FOR DELETE USING (false);


--
-- Name: CoachLandingPageView landing_view_deny_all_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY landing_view_deny_all_insert ON public."CoachLandingPageView" AS RESTRICTIVE FOR INSERT WITH CHECK (false);


--
-- Name: CoachLandingPageView landing_view_deny_all_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY landing_view_deny_all_select ON public."CoachLandingPageView" AS RESTRICTIVE FOR SELECT USING (false);


--
-- Name: CoachLandingPageView landing_view_deny_all_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY landing_view_deny_all_update ON public."CoachLandingPageView" AS RESTRICTIVE FOR UPDATE USING (false) WITH CHECK (false);


--
-- Name: MacroTarget macro_target_client_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY macro_target_client_select ON public."MacroTarget" FOR SELECT USING (((app.current_user_id() IS NOT NULL) AND (client_id = app.current_user_id())));


--
-- Name: MacroTarget macro_target_coach_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY macro_target_coach_all ON public."MacroTarget" USING (((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))) WITH CHECK (((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id())));


--
-- Name: MacroTarget macro_target_owner_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY macro_target_owner_all ON public."MacroTarget" USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: Message message_delete_sender; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY message_delete_sender ON public."Message" FOR DELETE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (sender_id = app.current_user_id()))));


--
-- Name: MessageDraft message_draft_coach_access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY message_draft_coach_access ON public."MessageDraft" USING (((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))) WITH CHECK (((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id())));


--
-- Name: Message message_insert_sender; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY message_insert_sender ON public."Message" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (sender_id = app.current_user_id()))));


--
-- Name: MessageReport message_report_insert_reporter_or_owner; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY message_report_insert_reporter_or_owner ON public."MessageReport" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (reporter_id = app.current_user_id()) AND (EXISTS ( SELECT 1
   FROM public."CoachMessage" cm
  WHERE ((cm.id = "MessageReport".message_id) AND ((cm.coach_id = app.current_user_id()) OR (cm.client_id = app.current_user_id()) OR (cm.sender_id = app.current_user_id()))))))));


--
-- Name: MessageReport message_report_select_reporter_or_owner; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY message_report_select_reporter_or_owner ON public."MessageReport" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (reporter_id = app.current_user_id()))));


--
-- Name: MessageReport message_report_update_owner_only; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY message_report_update_owner_only ON public."MessageReport" FOR UPDATE USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: Message message_select_party_or_owner; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY message_select_party_or_owner ON public."Message" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((sender_id = app.current_user_id()) OR (recipient_id = app.current_user_id())))));


--
-- Name: Message message_update_sender_or_owner; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY message_update_sender_or_owner ON public."Message" FOR UPDATE USING (((app.current_user_id() IS NOT NULL) AND ((sender_id = app.current_user_id()) OR app.is_owner()))) WITH CHECK (((app.current_user_id() IS NOT NULL) AND ((sender_id = app.current_user_id()) OR app.is_owner())));


--
-- Name: Notification notification_owner_access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY notification_owner_access ON public."Notification" USING ((user_id = app.current_user_id())) WITH CHECK ((user_id = app.current_user_id()));


--
-- Name: NotificationPreferences notification_prefs_owner_access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY notification_prefs_owner_access ON public."NotificationPreferences" USING ((user_id = app.current_user_id())) WITH CHECK ((user_id = app.current_user_id()));


--
-- Name: ClientAssetGrant p_ClientAssetGrant_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "p_ClientAssetGrant_service_role_all" ON public."ClientAssetGrant" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY "p_ClientAssetGrant_service_role_all" ON "ClientAssetGrant"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "p_ClientAssetGrant_service_role_all" ON public."ClientAssetGrant" IS 'Primitive A: service_role bypass (S1-DB-01). Table is reached only by the backend Prisma client.';


--
-- Name: CoachMediaAsset p_CoachMediaAsset_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "p_CoachMediaAsset_service_role_all" ON public."CoachMediaAsset" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY "p_CoachMediaAsset_service_role_all" ON "CoachMediaAsset"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "p_CoachMediaAsset_service_role_all" ON public."CoachMediaAsset" IS 'Primitive A: service_role bypass (S1-DB-01). Table is reached only by the backend Prisma client.';


--
-- Name: CoachPackageContent p_CoachPackageContent_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "p_CoachPackageContent_service_role_all" ON public."CoachPackageContent" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY "p_CoachPackageContent_service_role_all" ON "CoachPackageContent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "p_CoachPackageContent_service_role_all" ON public."CoachPackageContent" IS 'Primitive A: service_role bypass (S1-DB-01). Table is reached only by the backend Prisma client.';


--
-- Name: DripResolverMarker p_DripResolverMarker_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "p_DripResolverMarker_service_role_all" ON public."DripResolverMarker" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY "p_DripResolverMarker_service_role_all" ON "DripResolverMarker"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "p_DripResolverMarker_service_role_all" ON public."DripResolverMarker" IS 'Primitive A: service_role bypass (S1-DB-01). Table is reached only by the backend Prisma client.';


--
-- Name: DunningAttempt p_DunningAttempt_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "p_DunningAttempt_service_role_all" ON public."DunningAttempt" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY "p_DunningAttempt_service_role_all" ON "DunningAttempt"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "p_DunningAttempt_service_role_all" ON public."DunningAttempt" IS 'Primitive A: service_role bypass (S1-DB-01). Table is reached only by the backend Prisma client.';


--
-- Name: MuxProcessedEvent p_MuxProcessedEvent_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "p_MuxProcessedEvent_service_role_all" ON public."MuxProcessedEvent" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY "p_MuxProcessedEvent_service_role_all" ON "MuxProcessedEvent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "p_MuxProcessedEvent_service_role_all" ON public."MuxProcessedEvent" IS 'Primitive A: service_role bypass (S1-DB-01). Table is reached only by the backend Prisma client.';


--
-- Name: NudgeLog p_NudgeLog_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "p_NudgeLog_service_role_all" ON public."NudgeLog" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY "p_NudgeLog_service_role_all" ON "NudgeLog"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "p_NudgeLog_service_role_all" ON public."NudgeLog" IS 'Primitive A: service_role bypass (S1-DB-01). Table is reached only by the backend Prisma client.';


--
-- Name: PaymentRecoveryToken p_PaymentRecoveryToken_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "p_PaymentRecoveryToken_service_role_all" ON public."PaymentRecoveryToken" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY "p_PaymentRecoveryToken_service_role_all" ON "PaymentRecoveryToken"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "p_PaymentRecoveryToken_service_role_all" ON public."PaymentRecoveryToken" IS 'Primitive A: service_role bypass (S1-DB-01). Table is reached only by the backend Prisma client.';


--
-- Name: PayoutMethod p_PayoutMethod_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "p_PayoutMethod_service_role_all" ON public."PayoutMethod" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY "p_PayoutMethod_service_role_all" ON "PayoutMethod"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "p_PayoutMethod_service_role_all" ON public."PayoutMethod" IS 'Primitive A: service_role bypass (S1-DB-01). Table is reached only by the backend Prisma client.';


--
-- Name: PurchaseFanout p_PurchaseFanout_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "p_PurchaseFanout_service_role_all" ON public."PurchaseFanout" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY "p_PurchaseFanout_service_role_all" ON "PurchaseFanout"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "p_PurchaseFanout_service_role_all" ON public."PurchaseFanout" IS 'Primitive A: service_role bypass (S1-DB-01). Table is reached only by the backend Prisma client.';


--
-- Name: ScheduledDrop p_ScheduledDrop_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "p_ScheduledDrop_service_role_all" ON public."ScheduledDrop" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY "p_ScheduledDrop_service_role_all" ON "ScheduledDrop"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "p_ScheduledDrop_service_role_all" ON public."ScheduledDrop" IS 'Primitive A: service_role bypass (S1-DB-01). Table is reached only by the backend Prisma client.';


--
-- Name: UserAIQuota p_UserAIQuota_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "p_UserAIQuota_service_role_all" ON public."UserAIQuota" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY "p_UserAIQuota_service_role_all" ON "UserAIQuota"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY "p_UserAIQuota_service_role_all" ON public."UserAIQuota" IS 'Primitive A: service_role bypass (S1-DB-01). Table is reached only by the backend Prisma client.';


--
-- Name: ActivityEvent p_activityevent_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_activityevent_delete ON public."ActivityEvent" FOR DELETE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((actor_id = app.current_user_id()) OR (coach_id = app.current_user_id()) OR (client_id = app.current_user_id()) OR app.is_current_coach_of(client_id)))));


--
-- Name: POLICY p_activityevent_delete ON "ActivityEvent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_activityevent_delete ON public."ActivityEvent" IS 'PR-RLS-06 participant-event delete: owner, or a participant (actor_id/coach_id/client_id) or the current coach of client_id.';


--
-- Name: ActivityEvent p_activityevent_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_activityevent_insert ON public."ActivityEvent" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((actor_id = app.current_user_id()) OR (coach_id = app.current_user_id()) OR (client_id = app.current_user_id()) OR app.is_current_coach_of(client_id)))));


--
-- Name: POLICY p_activityevent_insert ON "ActivityEvent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_activityevent_insert ON public."ActivityEvent" IS 'PR-RLS-06 participant-event insert: owner, or a participant (actor_id/coach_id/client_id) or the current coach of client_id.';


--
-- Name: ActivityEvent p_activityevent_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_activityevent_select ON public."ActivityEvent" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((actor_id = app.current_user_id()) OR (coach_id = app.current_user_id()) OR (client_id = app.current_user_id()) OR app.is_current_coach_of(client_id)))));


--
-- Name: POLICY p_activityevent_select ON "ActivityEvent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_activityevent_select ON public."ActivityEvent" IS 'PR-RLS-06 participant-event read: owner, or a participant (actor_id/coach_id/client_id) or the current coach of client_id.';


--
-- Name: ActivityEvent p_activityevent_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_activityevent_service_role_all ON public."ActivityEvent" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_activityevent_service_role_all ON "ActivityEvent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_activityevent_service_role_all ON public."ActivityEvent" IS 'PR-RLS-06 Primitive A: service_role bypass for server-side jobs and migrations.';


--
-- Name: ActivityEvent p_activityevent_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_activityevent_update ON public."ActivityEvent" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((actor_id = app.current_user_id()) OR (coach_id = app.current_user_id()) OR (client_id = app.current_user_id()) OR app.is_current_coach_of(client_id))))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((actor_id = app.current_user_id()) OR (coach_id = app.current_user_id()) OR (client_id = app.current_user_id()) OR app.is_current_coach_of(client_id)))));


--
-- Name: POLICY p_activityevent_update ON "ActivityEvent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_activityevent_update ON public."ActivityEvent" IS 'PR-RLS-06 participant-event update: owner, or a participant (actor_id/coach_id/client_id) or the current coach of client_id.';


--
-- Name: AiRoadmap p_airoadmap_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_airoadmap_delete ON public."AiRoadmap" FOR DELETE USING ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."DiagnosticSubmission" ds
  WHERE ((ds.id = "AiRoadmap".submission_id) AND (ds.user_id = app.current_user_id()))))));


--
-- Name: POLICY p_airoadmap_delete ON "AiRoadmap"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_airoadmap_delete ON public."AiRoadmap" IS 'PR-RLS-06 child-via-diagnostic-submission delete: owner, or the user who owns the parent DiagnosticSubmission.';


--
-- Name: AiRoadmap p_airoadmap_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_airoadmap_insert ON public."AiRoadmap" FOR INSERT WITH CHECK ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."DiagnosticSubmission" ds
  WHERE ((ds.id = "AiRoadmap".submission_id) AND (ds.user_id = app.current_user_id()))))));


--
-- Name: POLICY p_airoadmap_insert ON "AiRoadmap"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_airoadmap_insert ON public."AiRoadmap" IS 'PR-RLS-06 child-via-diagnostic-submission insert: owner, or the user who owns the parent DiagnosticSubmission.';


--
-- Name: AiRoadmap p_airoadmap_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_airoadmap_select ON public."AiRoadmap" FOR SELECT USING ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."DiagnosticSubmission" ds
  WHERE ((ds.id = "AiRoadmap".submission_id) AND (ds.user_id = app.current_user_id()))))));


--
-- Name: POLICY p_airoadmap_select ON "AiRoadmap"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_airoadmap_select ON public."AiRoadmap" IS 'PR-RLS-06 child-via-diagnostic-submission read: owner, or the user who owns the parent DiagnosticSubmission (submission_id -> user_id).';


--
-- Name: AiRoadmap p_airoadmap_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_airoadmap_service_role_all ON public."AiRoadmap" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_airoadmap_service_role_all ON "AiRoadmap"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_airoadmap_service_role_all ON public."AiRoadmap" IS 'PR-RLS-06 Primitive A: service_role bypass for server-side jobs and migrations.';


--
-- Name: AiRoadmap p_airoadmap_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_airoadmap_update ON public."AiRoadmap" FOR UPDATE USING ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."DiagnosticSubmission" ds
  WHERE ((ds.id = "AiRoadmap".submission_id) AND (ds.user_id = app.current_user_id())))))) WITH CHECK ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."DiagnosticSubmission" ds
  WHERE ((ds.id = "AiRoadmap".submission_id) AND (ds.user_id = app.current_user_id()))))));


--
-- Name: POLICY p_airoadmap_update ON "AiRoadmap"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_airoadmap_update ON public."AiRoadmap" IS 'PR-RLS-06 child-via-diagnostic-submission update: owner, or the user who owns the parent DiagnosticSubmission.';


--
-- Name: Applicant p_applicant_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_applicant_insert ON public."Applicant" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()))));


--
-- Name: POLICY p_applicant_insert ON "Applicant"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_applicant_insert ON public."Applicant" IS 'Write-scope: a pre-coach user may INSERT only their own profile (user_id = self).';


--
-- Name: Applicant p_applicant_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_applicant_select ON public."Applicant" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR (EXISTS ( SELECT 1
   FROM public."TeamSubCoachAssignment" tsca
  WHERE ((tsca.sub_coach_id = "Applicant".user_id) AND (tsca.head_coach_id = app.current_user_id()) AND (tsca.archived_at IS NULL))))))));


--
-- Name: POLICY p_applicant_select ON "Applicant"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_applicant_select ON public."Applicant" IS 'Read: the applicant themselves (user_id), or the head coach of the applicant once flipped to a non-archived sub-coach (reused TeamSubCoachAssignment predicate). anon sees zero. Cross-applicant reads are denied (IDOR / PII).';


--
-- Name: Applicant p_applicant_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_applicant_service_role_all ON public."Applicant" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_applicant_service_role_all ON "Applicant"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_applicant_service_role_all ON public."Applicant" IS 'Primitive A: service_role bypass for server-side jobs/migrations/seeds.';


--
-- Name: Applicant p_applicant_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_applicant_update ON public."Applicant" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id())))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()))));


--
-- Name: POLICY p_applicant_update ON "Applicant"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_applicant_update ON public."Applicant" IS 'Write-scope: only owner or the row''s user_id may UPDATE; CHECK prevents re-owning to another user_id.';


--
-- Name: Application p_application_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_application_insert ON public."Application" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (applicant_user_id = app.current_user_id()))));


--
-- Name: POLICY p_application_insert ON "Application"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_application_insert ON public."Application" IS 'Write-scope: only the applying user (applicant_user_id = self) may INSERT an application. Hirers never create applications.';


--
-- Name: Application p_application_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_application_select ON public."Application" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((applicant_user_id = app.current_user_id()) OR (hirer_id = app.current_user_id())))));


--
-- Name: POLICY p_application_select ON "Application"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_application_select ON public."Application" IS 'Read: the applying user (applicant_user_id) or the owning hirer of the listing (hirer_id). anon sees zero. Cross-principal reads denied (IDOR / PII).';


--
-- Name: Application p_application_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_application_service_role_all ON public."Application" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_application_service_role_all ON "Application"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_application_service_role_all ON public."Application" IS 'Primitive A: service_role bypass for server-side jobs/migrations/seeds.';


--
-- Name: Application p_application_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_application_update ON public."Application" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((applicant_user_id = app.current_user_id()) OR (hirer_id = app.current_user_id()))))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((applicant_user_id = app.current_user_id()) OR (hirer_id = app.current_user_id())))));


--
-- Name: POLICY p_application_update ON "Application"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_application_update ON public."Application" IS 'Write-scope: the applying user may UPDATE/withdraw their own application; the owning hirer may advance pipeline status on applications to their listing. CHECK keeps both columns owner-pinned.';


--
-- Name: BloodworkAttachment p_bloodworkattachment_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_bloodworkattachment_delete ON public."BloodworkAttachment" FOR DELETE USING (app.is_owner());


--
-- Name: POLICY p_bloodworkattachment_delete ON "BloodworkAttachment"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_bloodworkattachment_delete ON public."BloodworkAttachment" IS 'PHI attachment pointers are server-managed; only service role / owner may delete them.';


--
-- Name: BloodworkAttachment p_bloodworkattachment_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_bloodworkattachment_insert ON public."BloodworkAttachment" FOR INSERT WITH CHECK ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."BloodworkPanel" bp
  WHERE ((bp.id = "BloodworkAttachment".panel_id) AND ((bp.client_id = app.current_user_id()) OR (bp.coach_id = app.current_user_id()) OR app.is_current_coach_of(bp.client_id)))))));


--
-- Name: POLICY p_bloodworkattachment_insert ON "BloodworkAttachment"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_bloodworkattachment_insert ON public."BloodworkAttachment" IS 'Insert attachment pointers only into panels the caller owns, coaches, or is an owner of.';


--
-- Name: BloodworkAttachment p_bloodworkattachment_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_bloodworkattachment_select ON public."BloodworkAttachment" FOR SELECT USING ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."BloodworkPanel" bp
  WHERE ((bp.id = "BloodworkAttachment".panel_id) AND ((bp.client_id = app.current_user_id()) OR (bp.coach_id = app.current_user_id()) OR app.is_current_coach_of(bp.client_id)))))));


--
-- Name: POLICY p_bloodworkattachment_select ON "BloodworkAttachment"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_bloodworkattachment_select ON public."BloodworkAttachment" IS 'Read PHI attachment pointers only for the panel client, panel coach, the current coach of that client, or an owner.';


--
-- Name: BloodworkAttachment p_bloodworkattachment_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_bloodworkattachment_service_role_all ON public."BloodworkAttachment" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_bloodworkattachment_service_role_all ON "BloodworkAttachment"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_bloodworkattachment_service_role_all ON public."BloodworkAttachment" IS 'Service role bypass for server-side PHI attachment jobs and migrations.';


--
-- Name: BloodworkAttachment p_bloodworkattachment_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_bloodworkattachment_update ON public."BloodworkAttachment" FOR UPDATE USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: POLICY p_bloodworkattachment_update ON "BloodworkAttachment"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_bloodworkattachment_update ON public."BloodworkAttachment" IS 'PHI attachment metadata (scan state) is server-managed; only service role / owner may amend it.';


--
-- Name: BloodworkResult p_bloodworkresult_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_bloodworkresult_delete ON public."BloodworkResult" FOR DELETE USING (app.is_owner());


--
-- Name: POLICY p_bloodworkresult_delete ON "BloodworkResult"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_bloodworkresult_delete ON public."BloodworkResult" IS 'PHI lab rows are immutable client-side; only service role / owner may delete them.';


--
-- Name: BloodworkResult p_bloodworkresult_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_bloodworkresult_insert ON public."BloodworkResult" FOR INSERT WITH CHECK ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."BloodworkPanel" bp
  WHERE ((bp.id = "BloodworkResult".panel_id) AND ((bp.client_id = app.current_user_id()) OR (bp.coach_id = app.current_user_id()) OR app.is_current_coach_of(bp.client_id)))))));


--
-- Name: POLICY p_bloodworkresult_insert ON "BloodworkResult"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_bloodworkresult_insert ON public."BloodworkResult" IS 'Insert lab markers only into panels the caller owns, coaches, or is an owner of.';


--
-- Name: BloodworkResult p_bloodworkresult_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_bloodworkresult_select ON public."BloodworkResult" FOR SELECT USING ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."BloodworkPanel" bp
  WHERE ((bp.id = "BloodworkResult".panel_id) AND ((bp.client_id = app.current_user_id()) OR (bp.coach_id = app.current_user_id()) OR app.is_current_coach_of(bp.client_id)))))));


--
-- Name: POLICY p_bloodworkresult_select ON "BloodworkResult"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_bloodworkresult_select ON public."BloodworkResult" IS 'Read PHI lab markers only for the panel client, panel coach, the current coach of that client, or an owner.';


--
-- Name: BloodworkResult p_bloodworkresult_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_bloodworkresult_service_role_all ON public."BloodworkResult" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_bloodworkresult_service_role_all ON "BloodworkResult"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_bloodworkresult_service_role_all ON public."BloodworkResult" IS 'Service role bypass for server-side PHI jobs and migrations.';


--
-- Name: BloodworkResult p_bloodworkresult_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_bloodworkresult_update ON public."BloodworkResult" FOR UPDATE USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: POLICY p_bloodworkresult_update ON "BloodworkResult"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_bloodworkresult_update ON public."BloodworkResult" IS 'PHI lab rows are immutable client-side; only service role / owner may amend them.';


--
-- Name: BuildWeekDay p_buildweekday_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_buildweekday_delete ON public."BuildWeekDay" FOR DELETE USING (app.is_owner());


--
-- Name: POLICY p_buildweekday_delete ON "BuildWeekDay"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_buildweekday_delete ON public."BuildWeekDay" IS 'Owner-write: only owner (or service_role) may DELETE curriculum days.';


--
-- Name: BuildWeekDay p_buildweekday_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_buildweekday_insert ON public."BuildWeekDay" FOR INSERT WITH CHECK (app.is_owner());


--
-- Name: POLICY p_buildweekday_insert ON "BuildWeekDay"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_buildweekday_insert ON public."BuildWeekDay" IS 'Owner-write: only owner (or service_role) may INSERT curriculum days.';


--
-- Name: BuildWeekDay p_buildweekday_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_buildweekday_select ON public."BuildWeekDay" FOR SELECT USING (true);


--
-- Name: POLICY p_buildweekday_select ON "BuildWeekDay"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_buildweekday_select ON public."BuildWeekDay" IS 'Public-catalog read: build-week curriculum is shared reference content; anyone (incl. anon) may SELECT.';


--
-- Name: BuildWeekDay p_buildweekday_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_buildweekday_service_role_all ON public."BuildWeekDay" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_buildweekday_service_role_all ON "BuildWeekDay"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_buildweekday_service_role_all ON public."BuildWeekDay" IS 'Primitive A: service_role bypass for server-side jobs/migrations (curriculum seeding).';


--
-- Name: BuildWeekDay p_buildweekday_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_buildweekday_update ON public."BuildWeekDay" FOR UPDATE USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: POLICY p_buildweekday_update ON "BuildWeekDay"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_buildweekday_update ON public."BuildWeekDay" IS 'Owner-write: only owner (or service_role) may UPDATE curriculum days.';


--
-- Name: BuildWeekDayCompletion p_buildweekdaycompletion_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_buildweekdaycompletion_delete ON public."BuildWeekDayCompletion" FOR DELETE USING ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."BuildWeekEnrollment" bwe
  WHERE ((bwe.id = "BuildWeekDayCompletion".enrollment_id) AND (bwe.user_id = app.current_user_id()))))));


--
-- Name: POLICY p_buildweekdaycompletion_delete ON "BuildWeekDayCompletion"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_buildweekdaycompletion_delete ON public."BuildWeekDayCompletion" IS 'Child-via-enrollment delete: owner or the enrollment''s user may DELETE their completion rows.';


--
-- Name: BuildWeekDayCompletion p_buildweekdaycompletion_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_buildweekdaycompletion_insert ON public."BuildWeekDayCompletion" FOR INSERT WITH CHECK ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."BuildWeekEnrollment" bwe
  WHERE ((bwe.id = "BuildWeekDayCompletion".enrollment_id) AND (bwe.user_id = app.current_user_id()))))));


--
-- Name: POLICY p_buildweekdaycompletion_insert ON "BuildWeekDayCompletion"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_buildweekdaycompletion_insert ON public."BuildWeekDayCompletion" IS 'Child-via-enrollment write: owner or the enrollment''s user may INSERT completion rows.';


--
-- Name: BuildWeekDayCompletion p_buildweekdaycompletion_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_buildweekdaycompletion_select ON public."BuildWeekDayCompletion" FOR SELECT USING ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."BuildWeekEnrollment" bwe
  WHERE ((bwe.id = "BuildWeekDayCompletion".enrollment_id) AND (bwe.user_id = app.current_user_id()))))));


--
-- Name: POLICY p_buildweekdaycompletion_select ON "BuildWeekDayCompletion"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_buildweekdaycompletion_select ON public."BuildWeekDayCompletion" IS 'Child-via-enrollment read: owner or the enrollment''s user (user_id) may SELECT their completion rows.';


--
-- Name: BuildWeekDayCompletion p_buildweekdaycompletion_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_buildweekdaycompletion_service_role_all ON public."BuildWeekDayCompletion" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_buildweekdaycompletion_service_role_all ON "BuildWeekDayCompletion"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_buildweekdaycompletion_service_role_all ON public."BuildWeekDayCompletion" IS 'Primitive A: service_role bypass for server-side jobs/migrations.';


--
-- Name: BuildWeekDayCompletion p_buildweekdaycompletion_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_buildweekdaycompletion_update ON public."BuildWeekDayCompletion" FOR UPDATE USING ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."BuildWeekEnrollment" bwe
  WHERE ((bwe.id = "BuildWeekDayCompletion".enrollment_id) AND (bwe.user_id = app.current_user_id())))))) WITH CHECK ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."BuildWeekEnrollment" bwe
  WHERE ((bwe.id = "BuildWeekDayCompletion".enrollment_id) AND (bwe.user_id = app.current_user_id()))))));


--
-- Name: POLICY p_buildweekdaycompletion_update ON "BuildWeekDayCompletion"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_buildweekdaycompletion_update ON public."BuildWeekDayCompletion" IS 'Child-via-enrollment update: owner or the enrollment''s user may UPDATE; CHECK reverifies the parent enrollment.';


--
-- Name: BuildWeekEnrollment p_buildweekenrollment_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_buildweekenrollment_delete ON public."BuildWeekEnrollment" FOR DELETE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()))));


--
-- Name: POLICY p_buildweekenrollment_delete ON "BuildWeekEnrollment"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_buildweekenrollment_delete ON public."BuildWeekEnrollment" IS 'User-self delete: owner or the enrolling user may DELETE their enrollment.';


--
-- Name: BuildWeekEnrollment p_buildweekenrollment_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_buildweekenrollment_insert ON public."BuildWeekEnrollment" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()))));


--
-- Name: POLICY p_buildweekenrollment_insert ON "BuildWeekEnrollment"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_buildweekenrollment_insert ON public."BuildWeekEnrollment" IS 'User-self write: only owner or the enrolling user may INSERT (own row).';


--
-- Name: BuildWeekEnrollment p_buildweekenrollment_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_buildweekenrollment_select ON public."BuildWeekEnrollment" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()))));


--
-- Name: POLICY p_buildweekenrollment_select ON "BuildWeekEnrollment"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_buildweekenrollment_select ON public."BuildWeekEnrollment" IS 'User-self read: owner or the enrolling user (user_id) may SELECT their enrollment.';


--
-- Name: BuildWeekEnrollment p_buildweekenrollment_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_buildweekenrollment_service_role_all ON public."BuildWeekEnrollment" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_buildweekenrollment_service_role_all ON "BuildWeekEnrollment"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_buildweekenrollment_service_role_all ON public."BuildWeekEnrollment" IS 'Primitive A: service_role bypass for server-side jobs/migrations.';


--
-- Name: BuildWeekEnrollment p_buildweekenrollment_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_buildweekenrollment_update ON public."BuildWeekEnrollment" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id())))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()))));


--
-- Name: POLICY p_buildweekenrollment_update ON "BuildWeekEnrollment"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_buildweekenrollment_update ON public."BuildWeekEnrollment" IS 'User-self update: owner or the enrolling user may UPDATE; CHECK prevents re-owning to another user_id.';


--
-- Name: ChargeDispute p_chargedispute_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_chargedispute_delete ON public."ChargeDispute" FOR DELETE USING (app.is_owner());


--
-- Name: POLICY p_chargedispute_delete ON "ChargeDispute"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_chargedispute_delete ON public."ChargeDispute" IS 'Financial dispute records are retained; only service role / owner may delete them.';


--
-- Name: ChargeDispute p_chargedispute_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_chargedispute_insert ON public."ChargeDispute" FOR INSERT WITH CHECK (app.is_owner());


--
-- Name: POLICY p_chargedispute_insert ON "ChargeDispute"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_chargedispute_insert ON public."ChargeDispute" IS 'Dispute rows originate from Stripe webhooks (service role); only owner may insert otherwise.';


--
-- Name: ChargeDispute p_chargedispute_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_chargedispute_select ON public."ChargeDispute" FOR SELECT USING ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."ClientPurchase" cp
  WHERE ((cp.id = "ChargeDispute".purchase_id) AND ((cp.client_user_id = app.current_user_id()) OR (cp.coach_user_id = app.current_user_id())))))));


--
-- Name: POLICY p_chargedispute_select ON "ChargeDispute"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_chargedispute_select ON public."ChargeDispute" IS 'Read a dispute only as a party (client or coach) to the underlying purchase, or as an owner.';


--
-- Name: ChargeDispute p_chargedispute_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_chargedispute_service_role_all ON public."ChargeDispute" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_chargedispute_service_role_all ON "ChargeDispute"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_chargedispute_service_role_all ON public."ChargeDispute" IS 'Service role bypass: Stripe dispute rows are written exclusively by webhook handlers.';


--
-- Name: ChargeDispute p_chargedispute_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_chargedispute_update ON public."ChargeDispute" FOR UPDATE USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: POLICY p_chargedispute_update ON "ChargeDispute"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_chargedispute_update ON public."ChargeDispute" IS 'Dispute state transitions are webhook-driven (service role); only owner may update otherwise.';


--
-- Name: ChargeRefund p_chargerefund_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_chargerefund_delete ON public."ChargeRefund" FOR DELETE USING ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."ClientPurchase" cp
  WHERE ((cp.id = "ChargeRefund".purchase_id) AND ((cp.client_user_id = app.current_user_id()) OR (cp.coach_user_id = app.current_user_id())))))));


--
-- Name: POLICY p_chargerefund_delete ON "ChargeRefund"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_chargerefund_delete ON public."ChargeRefund" IS 'Only a party to the purchase, an owner, or service role may delete a refund record.';


--
-- Name: ChargeRefund p_chargerefund_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_chargerefund_insert ON public."ChargeRefund" FOR INSERT WITH CHECK ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."ClientPurchase" cp
  WHERE ((cp.id = "ChargeRefund".purchase_id) AND ((cp.client_user_id = app.current_user_id()) OR (cp.coach_user_id = app.current_user_id())))))));


--
-- Name: POLICY p_chargerefund_insert ON "ChargeRefund"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_chargerefund_insert ON public."ChargeRefund" IS 'A party to the purchase (coach-initiated refund) or an owner may record a refund; service role covers webhook rows.';


--
-- Name: ChargeRefund p_chargerefund_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_chargerefund_select ON public."ChargeRefund" FOR SELECT USING ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."ClientPurchase" cp
  WHERE ((cp.id = "ChargeRefund".purchase_id) AND ((cp.client_user_id = app.current_user_id()) OR (cp.coach_user_id = app.current_user_id())))))));


--
-- Name: POLICY p_chargerefund_select ON "ChargeRefund"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_chargerefund_select ON public."ChargeRefund" IS 'Read a refund only as a party (client or coach) to the underlying purchase, or as an owner.';


--
-- Name: ChargeRefund p_chargerefund_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_chargerefund_service_role_all ON public."ChargeRefund" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_chargerefund_service_role_all ON "ChargeRefund"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_chargerefund_service_role_all ON public."ChargeRefund" IS 'Service role bypass: refund rows are written by webhook handlers and admin tooling.';


--
-- Name: ChargeRefund p_chargerefund_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_chargerefund_update ON public."ChargeRefund" FOR UPDATE USING ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."ClientPurchase" cp
  WHERE ((cp.id = "ChargeRefund".purchase_id) AND ((cp.client_user_id = app.current_user_id()) OR (cp.coach_user_id = app.current_user_id()))))))) WITH CHECK ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."ClientPurchase" cp
  WHERE ((cp.id = "ChargeRefund".purchase_id) AND ((cp.client_user_id = app.current_user_id()) OR (cp.coach_user_id = app.current_user_id())))))));


--
-- Name: POLICY p_chargerefund_update ON "ChargeRefund"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_chargerefund_update ON public."ChargeRefund" IS 'A party to the purchase or an owner may amend a refund row; service role covers webhook updates.';


--
-- Name: ClientCoachConsent p_clientcoachconsent_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_clientcoachconsent_delete ON public."ClientCoachConsent" FOR DELETE USING (app.is_owner());


--
-- Name: POLICY p_clientcoachconsent_delete ON "ClientCoachConsent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_clientcoachconsent_delete ON public."ClientCoachConsent" IS 'DELETE restricted to the owner escalation role (app.is_owner()). Consent records are legal evidence; account-deletion cleanup (src/account-deletion/account-deletion.service.ts:816-819 clientCoachConsent.deleteMany) runs as the Supabase service_role (BYPASSRLS). This policy is the defense-in-depth path for any non-bypass connection and intentionally denies tenant-side deletion.';


--
-- Name: ClientCoachConsent p_clientcoachconsent_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_clientcoachconsent_insert ON public."ClientCoachConsent" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((client_id = app.current_user_id()) OR (coach_id = app.current_user_id()) OR app.is_current_coach_of(client_id)))));


--
-- Name: POLICY p_clientcoachconsent_insert ON "ClientCoachConsent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_clientcoachconsent_insert ON public."ClientCoachConsent" IS 'A client may record their own consent and a coach may record consent for their client; owner is also allowed.';


--
-- Name: ClientCoachConsent p_clientcoachconsent_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_clientcoachconsent_select ON public."ClientCoachConsent" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((client_id = app.current_user_id()) OR (coach_id = app.current_user_id()) OR app.is_current_coach_of(client_id)))));


--
-- Name: POLICY p_clientcoachconsent_select ON "ClientCoachConsent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_clientcoachconsent_select ON public."ClientCoachConsent" IS 'Read consent rows only as the consenting client, the named coach, the current coach of that client, or an owner.';


--
-- Name: ClientCoachConsent p_clientcoachconsent_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_clientcoachconsent_service_role_all ON public."ClientCoachConsent" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_clientcoachconsent_service_role_all ON "ClientCoachConsent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_clientcoachconsent_service_role_all ON public."ClientCoachConsent" IS 'Service role bypass for server-side consent lifecycle jobs and migrations.';


--
-- Name: ClientCoachConsent p_clientcoachconsent_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_clientcoachconsent_update ON public."ClientCoachConsent" FOR UPDATE USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: POLICY p_clientcoachconsent_update ON "ClientCoachConsent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_clientcoachconsent_update ON public."ClientCoachConsent" IS 'UPDATE restricted to the owner escalation role (app.is_owner()). Consent lifecycle transitions (grant re-issue, revoke) flow through the backend ConsentService (src/consent/consent.service.ts:171-253: upsert/re-grant at :171-190, revoke at :250-253) which runs as the Supabase service_role (BYPASSRLS); this policy is the defense-in-depth path for any non-bypass connection and intentionally denies tenant-side mutation.';


--
-- Name: ClientOutcome p_clientoutcome_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_clientoutcome_delete ON public."ClientOutcome" FOR DELETE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR app.is_current_coach_of(user_id)))));


--
-- Name: POLICY p_clientoutcome_delete ON "ClientOutcome"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_clientoutcome_delete ON public."ClientOutcome" IS 'PR-RLS-06 user-self-current-coach delete: owner, the user, or the user''s current coach.';


--
-- Name: ClientOutcome p_clientoutcome_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_clientoutcome_insert ON public."ClientOutcome" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR app.is_current_coach_of(user_id)))));


--
-- Name: POLICY p_clientoutcome_insert ON "ClientOutcome"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_clientoutcome_insert ON public."ClientOutcome" IS 'PR-RLS-06 user-self-current-coach insert: owner, the user, or the user''s current coach.';


--
-- Name: ClientOutcome p_clientoutcome_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_clientoutcome_select ON public."ClientOutcome" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR app.is_current_coach_of(user_id)))));


--
-- Name: POLICY p_clientoutcome_select ON "ClientOutcome"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_clientoutcome_select ON public."ClientOutcome" IS 'PR-RLS-06 user-self-current-coach read: owner, the user (user_id), or the user''s current coach.';


--
-- Name: ClientOutcome p_clientoutcome_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_clientoutcome_service_role_all ON public."ClientOutcome" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_clientoutcome_service_role_all ON "ClientOutcome"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_clientoutcome_service_role_all ON public."ClientOutcome" IS 'PR-RLS-06 Primitive A: service_role bypass for server-side jobs and migrations.';


--
-- Name: ClientOutcome p_clientoutcome_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_clientoutcome_update ON public."ClientOutcome" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR app.is_current_coach_of(user_id))))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR app.is_current_coach_of(user_id)))));


--
-- Name: POLICY p_clientoutcome_update ON "ClientOutcome"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_clientoutcome_update ON public."ClientOutcome" IS 'PR-RLS-06 user-self-current-coach update: owner, the user, or the user''s current coach.';


--
-- Name: ClientSignal p_clientsignal_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_clientsignal_delete ON public."ClientSignal" FOR DELETE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR app.is_current_coach_of(user_id)))));


--
-- Name: POLICY p_clientsignal_delete ON "ClientSignal"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_clientsignal_delete ON public."ClientSignal" IS 'PR-RLS-06 user-self-current-coach delete: owner, the user, or the user''s current coach.';


--
-- Name: ClientSignal p_clientsignal_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_clientsignal_insert ON public."ClientSignal" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR app.is_current_coach_of(user_id)))));


--
-- Name: POLICY p_clientsignal_insert ON "ClientSignal"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_clientsignal_insert ON public."ClientSignal" IS 'PR-RLS-06 user-self-current-coach insert: owner, the user, or the user''s current coach.';


--
-- Name: ClientSignal p_clientsignal_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_clientsignal_select ON public."ClientSignal" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR app.is_current_coach_of(user_id)))));


--
-- Name: POLICY p_clientsignal_select ON "ClientSignal"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_clientsignal_select ON public."ClientSignal" IS 'PR-RLS-06 user-self-current-coach read: owner, the user (user_id), or the user''s current coach.';


--
-- Name: ClientSignal p_clientsignal_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_clientsignal_service_role_all ON public."ClientSignal" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_clientsignal_service_role_all ON "ClientSignal"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_clientsignal_service_role_all ON public."ClientSignal" IS 'PR-RLS-06 Primitive A: service_role bypass for server-side jobs and migrations.';


--
-- Name: ClientSignal p_clientsignal_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_clientsignal_update ON public."ClientSignal" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR app.is_current_coach_of(user_id))))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR app.is_current_coach_of(user_id)))));


--
-- Name: POLICY p_clientsignal_update ON "ClientSignal"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_clientsignal_update ON public."ClientSignal" IS 'PR-RLS-06 user-self-current-coach update: owner, the user, or the user''s current coach.';


--
-- Name: ClientWorkoutAssignmentSnapshot p_clientworkoutassignmentsnapshot_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_clientworkoutassignmentsnapshot_delete ON public."ClientWorkoutAssignmentSnapshot" FOR DELETE USING ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."ClientWorkoutAssignment" cwa
  WHERE ((cwa.id = "ClientWorkoutAssignmentSnapshot".assignment_id) AND ((cwa.assigned_by_coach_id = app.current_user_id()) OR app.is_current_coach_of(cwa.client_id) OR app.is_subcoach_of(cwa.client_id)))))));


--
-- Name: POLICY p_clientworkoutassignmentsnapshot_delete ON "ClientWorkoutAssignmentSnapshot"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_clientworkoutassignmentsnapshot_delete ON public."ClientWorkoutAssignmentSnapshot" IS 'Child-via-assignment delete: owner admin, the assigning coach, or that client''s coach/sub-coach may DELETE.';


--
-- Name: ClientWorkoutAssignmentSnapshot p_clientworkoutassignmentsnapshot_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_clientworkoutassignmentsnapshot_insert ON public."ClientWorkoutAssignmentSnapshot" FOR INSERT WITH CHECK ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."ClientWorkoutAssignment" cwa
  WHERE ((cwa.id = "ClientWorkoutAssignmentSnapshot".assignment_id) AND ((cwa.assigned_by_coach_id = app.current_user_id()) OR app.is_current_coach_of(cwa.client_id) OR app.is_subcoach_of(cwa.client_id)))))));


--
-- Name: POLICY p_clientworkoutassignmentsnapshot_insert ON "ClientWorkoutAssignmentSnapshot"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_clientworkoutassignmentsnapshot_insert ON public."ClientWorkoutAssignmentSnapshot" IS 'Child-via-assignment write: owner admin, the assigning coach, or that client''s current coach/sub-coach may INSERT the snapshot (taken inside the assign tx).';


--
-- Name: ClientWorkoutAssignmentSnapshot p_clientworkoutassignmentsnapshot_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_clientworkoutassignmentsnapshot_select ON public."ClientWorkoutAssignmentSnapshot" FOR SELECT USING ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."ClientWorkoutAssignment" cwa
  WHERE ((cwa.id = "ClientWorkoutAssignmentSnapshot".assignment_id) AND ((cwa.client_id = app.current_user_id()) OR (cwa.assigned_by_coach_id = app.current_user_id()) OR app.is_current_coach_of(cwa.client_id) OR app.is_subcoach_of(cwa.client_id)))))));


--
-- Name: POLICY p_clientworkoutassignmentsnapshot_select ON "ClientWorkoutAssignmentSnapshot"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_clientworkoutassignmentsnapshot_select ON public."ClientWorkoutAssignmentSnapshot" IS 'Child-via-assignment read: owner admin, the assigned client, the assigning coach, or that client''s current coach/sub-coach may SELECT the snapshot.';


--
-- Name: ClientWorkoutAssignmentSnapshot p_clientworkoutassignmentsnapshot_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_clientworkoutassignmentsnapshot_service_role_all ON public."ClientWorkoutAssignmentSnapshot" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_clientworkoutassignmentsnapshot_service_role_all ON "ClientWorkoutAssignmentSnapshot"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_clientworkoutassignmentsnapshot_service_role_all ON public."ClientWorkoutAssignmentSnapshot" IS 'Primitive A: service_role bypass for server-side jobs/migrations.';


--
-- Name: ClientWorkoutAssignmentSnapshot p_clientworkoutassignmentsnapshot_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_clientworkoutassignmentsnapshot_update ON public."ClientWorkoutAssignmentSnapshot" FOR UPDATE USING ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."ClientWorkoutAssignment" cwa
  WHERE ((cwa.id = "ClientWorkoutAssignmentSnapshot".assignment_id) AND ((cwa.assigned_by_coach_id = app.current_user_id()) OR app.is_current_coach_of(cwa.client_id) OR app.is_subcoach_of(cwa.client_id))))))) WITH CHECK ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."ClientWorkoutAssignment" cwa
  WHERE ((cwa.id = "ClientWorkoutAssignmentSnapshot".assignment_id) AND ((cwa.assigned_by_coach_id = app.current_user_id()) OR app.is_current_coach_of(cwa.client_id) OR app.is_subcoach_of(cwa.client_id)))))));


--
-- Name: POLICY p_clientworkoutassignmentsnapshot_update ON "ClientWorkoutAssignmentSnapshot"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_clientworkoutassignmentsnapshot_update ON public."ClientWorkoutAssignmentSnapshot" IS 'Child-via-assignment update: owner admin, the assigning coach, or that client''s coach/sub-coach may UPDATE; snapshots are immutable in practice but the policy keeps the parent check symmetric.';


--
-- Name: coach_ltv_peak p_coach_ltv_peak_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coach_ltv_peak_service_role_all ON public.coach_ltv_peak TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_coach_ltv_peak_service_role_all ON coach_ltv_peak; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coach_ltv_peak_service_role_all ON public.coach_ltv_peak IS 'Primitive A: service_role bypass (S1-DB-01). Table is reached only by the backend Prisma client.';


--
-- Name: CoachAlert p_coachalert_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachalert_delete ON public."CoachAlert" FOR DELETE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((coach_id = app.current_user_id()) OR (client_id = app.current_user_id()) OR app.is_current_coach_of(client_id)))));


--
-- Name: POLICY p_coachalert_delete ON "CoachAlert"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachalert_delete ON public."CoachAlert" IS 'PR-RLS-02: owner, the alert coach, the alert client, or the client''s current coach may delete.';


--
-- Name: CoachAlert p_coachalert_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachalert_insert ON public."CoachAlert" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((coach_id = app.current_user_id()) OR (client_id = app.current_user_id()) OR app.is_current_coach_of(client_id)))));


--
-- Name: POLICY p_coachalert_insert ON "CoachAlert"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachalert_insert ON public."CoachAlert" IS 'PR-RLS-02: owner, the alert coach, the alert client, or the client''s current coach may insert.';


--
-- Name: CoachAlert p_coachalert_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachalert_select ON public."CoachAlert" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((coach_id = app.current_user_id()) OR (client_id = app.current_user_id()) OR app.is_current_coach_of(client_id)))));


--
-- Name: POLICY p_coachalert_select ON "CoachAlert"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachalert_select ON public."CoachAlert" IS 'PR-RLS-02: owner, the alert coach, the alert client, or the client''s current coach may read.';


--
-- Name: CoachAlert p_coachalert_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachalert_service_role_all ON public."CoachAlert" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_coachalert_service_role_all ON "CoachAlert"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachalert_service_role_all ON public."CoachAlert" IS 'PR-RLS-02: service_role bypass for server-side jobs and migrations.';


--
-- Name: CoachAlert p_coachalert_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachalert_update ON public."CoachAlert" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((coach_id = app.current_user_id()) OR (client_id = app.current_user_id()) OR app.is_current_coach_of(client_id))))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((coach_id = app.current_user_id()) OR (client_id = app.current_user_id()) OR app.is_current_coach_of(client_id)))));


--
-- Name: POLICY p_coachalert_update ON "CoachAlert"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachalert_update ON public."CoachAlert" IS 'PR-RLS-02: owner, the alert coach, the alert client, or the client''s current coach may update.';


--
-- Name: CoachAvailability p_coachavailability_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachavailability_delete ON public."CoachAvailability" FOR DELETE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))));


--
-- Name: POLICY p_coachavailability_delete ON "CoachAvailability"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachavailability_delete ON public."CoachAvailability" IS 'PR-RLS-02: owner or the owning coach (incl. a sub-coach over their own rows) may delete; head coach has no write access.';


--
-- Name: CoachAvailability p_coachavailability_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachavailability_insert ON public."CoachAvailability" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))));


--
-- Name: POLICY p_coachavailability_insert ON "CoachAvailability"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachavailability_insert ON public."CoachAvailability" IS 'PR-RLS-02: owner or the owning coach (incl. a sub-coach over their own rows) may insert; head coach has no write access.';


--
-- Name: CoachAvailability p_coachavailability_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachavailability_select ON public."CoachAvailability" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((coach_id = app.current_user_id()) OR (EXISTS ( SELECT 1
   FROM public."TeamSubCoachAssignment" tsca
  WHERE ((tsca.sub_coach_id = "CoachAvailability".coach_id) AND (tsca.head_coach_id = app.current_user_id()) AND (tsca.archived_at IS NULL))))))));


--
-- Name: POLICY p_coachavailability_select ON "CoachAvailability"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachavailability_select ON public."CoachAvailability" IS 'PR-RLS-02: owner or the owning coach (sub-coaches own their rows) may read; the head coach gets SELECT-only on sub-coaches under their team (non-archived TeamSubCoachAssignment).';


--
-- Name: CoachAvailability p_coachavailability_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachavailability_service_role_all ON public."CoachAvailability" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_coachavailability_service_role_all ON "CoachAvailability"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachavailability_service_role_all ON public."CoachAvailability" IS 'PR-RLS-02: service_role bypass for server-side jobs and migrations.';


--
-- Name: CoachAvailability p_coachavailability_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachavailability_update ON public."CoachAvailability" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id())))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))));


--
-- Name: POLICY p_coachavailability_update ON "CoachAvailability"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachavailability_update ON public."CoachAvailability" IS 'PR-RLS-02: owner or the owning coach (incl. a sub-coach over their own rows) may update; head coach has no write access.';


--
-- Name: CoachAvailabilityOverride p_coachavailabilityoverride_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachavailabilityoverride_delete ON public."CoachAvailabilityOverride" FOR DELETE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))));


--
-- Name: POLICY p_coachavailabilityoverride_delete ON "CoachAvailabilityOverride"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachavailabilityoverride_delete ON public."CoachAvailabilityOverride" IS 'PR-RLS-02: owner or the owning coach (incl. a sub-coach over their own rows) may delete; head coach has no write access.';


--
-- Name: CoachAvailabilityOverride p_coachavailabilityoverride_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachavailabilityoverride_insert ON public."CoachAvailabilityOverride" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))));


--
-- Name: POLICY p_coachavailabilityoverride_insert ON "CoachAvailabilityOverride"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachavailabilityoverride_insert ON public."CoachAvailabilityOverride" IS 'PR-RLS-02: owner or the owning coach (incl. a sub-coach over their own rows) may insert; head coach has no write access.';


--
-- Name: CoachAvailabilityOverride p_coachavailabilityoverride_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachavailabilityoverride_select ON public."CoachAvailabilityOverride" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((coach_id = app.current_user_id()) OR (EXISTS ( SELECT 1
   FROM public."TeamSubCoachAssignment" tsca
  WHERE ((tsca.sub_coach_id = "CoachAvailabilityOverride".coach_id) AND (tsca.head_coach_id = app.current_user_id()) AND (tsca.archived_at IS NULL))))))));


--
-- Name: POLICY p_coachavailabilityoverride_select ON "CoachAvailabilityOverride"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachavailabilityoverride_select ON public."CoachAvailabilityOverride" IS 'PR-RLS-02: owner or the owning coach (sub-coaches own their rows) may read; the head coach gets SELECT-only on sub-coaches under their team (non-archived TeamSubCoachAssignment).';


--
-- Name: CoachAvailabilityOverride p_coachavailabilityoverride_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachavailabilityoverride_service_role_all ON public."CoachAvailabilityOverride" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_coachavailabilityoverride_service_role_all ON "CoachAvailabilityOverride"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachavailabilityoverride_service_role_all ON public."CoachAvailabilityOverride" IS 'PR-RLS-02: service_role bypass for server-side jobs and migrations.';


--
-- Name: CoachAvailabilityOverride p_coachavailabilityoverride_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachavailabilityoverride_update ON public."CoachAvailabilityOverride" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id())))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))));


--
-- Name: POLICY p_coachavailabilityoverride_update ON "CoachAvailabilityOverride"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachavailabilityoverride_update ON public."CoachAvailabilityOverride" IS 'PR-RLS-02: owner or the owning coach (incl. a sub-coach over their own rows) may update; head coach has no write access.';


--
-- Name: CoachEffectivenessScore p_coacheffectivenessscore_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coacheffectivenessscore_delete ON public."CoachEffectivenessScore" FOR DELETE USING (app.is_owner());


--
-- Name: POLICY p_coacheffectivenessscore_delete ON "CoachEffectivenessScore"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coacheffectivenessscore_delete ON public."CoachEffectivenessScore" IS 'PR-RLS-02: owner-only delete; coaches cannot remove their own analytics.';


--
-- Name: CoachEffectivenessScore p_coacheffectivenessscore_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coacheffectivenessscore_insert ON public."CoachEffectivenessScore" FOR INSERT WITH CHECK (app.is_owner());


--
-- Name: POLICY p_coacheffectivenessscore_insert ON "CoachEffectivenessScore"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coacheffectivenessscore_insert ON public."CoachEffectivenessScore" IS 'PR-RLS-02: owner-only insert; coaches cannot fabricate their own analytics.';


--
-- Name: CoachEffectivenessScore p_coacheffectivenessscore_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coacheffectivenessscore_select ON public."CoachEffectivenessScore" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))));


--
-- Name: POLICY p_coacheffectivenessscore_select ON "CoachEffectivenessScore"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coacheffectivenessscore_select ON public."CoachEffectivenessScore" IS 'PR-RLS-02: owner or the scored coach may read their own effectiveness score.';


--
-- Name: CoachEffectivenessScore p_coacheffectivenessscore_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coacheffectivenessscore_service_role_all ON public."CoachEffectivenessScore" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_coacheffectivenessscore_service_role_all ON "CoachEffectivenessScore"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coacheffectivenessscore_service_role_all ON public."CoachEffectivenessScore" IS 'PR-RLS-02: service_role bypass for server-side jobs and migrations.';


--
-- Name: CoachEffectivenessScore p_coacheffectivenessscore_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coacheffectivenessscore_update ON public."CoachEffectivenessScore" FOR UPDATE USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: POLICY p_coacheffectivenessscore_update ON "CoachEffectivenessScore"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coacheffectivenessscore_update ON public."CoachEffectivenessScore" IS 'PR-RLS-02: owner-only update; coaches cannot alter their own analytics.';


--
-- Name: coach_first_payment_notification p_coachfirstpayment_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachfirstpayment_select ON public.coach_first_payment_notification FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ("coachId" = app.current_user_id()))));


--
-- Name: POLICY p_coachfirstpayment_select ON coach_first_payment_notification; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachfirstpayment_select ON public.coach_first_payment_notification IS 'Owner-self read: a coach reads only their own first-payment row (coachId = self); platform owner reads all. anon (NULL current_user_id) sees zero. Cross-coach reads are denied (IDOR).';


--
-- Name: coach_first_payment_notification p_coachfirstpayment_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachfirstpayment_service_role_all ON public.coach_first_payment_notification TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_coachfirstpayment_service_role_all ON coach_first_payment_notification; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachfirstpayment_service_role_all ON public.coach_first_payment_notification IS 'Primitive A: service_role bypass. The Stripe webhook handler (sole writer of this ledger) runs under service_role; all INSERTs flow through here.';


--
-- Name: CoachGuideline p_coachguideline_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachguideline_delete ON public."CoachGuideline" FOR DELETE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((coach_id = app.current_user_id()) OR (client_id = app.current_user_id()) OR app.is_current_coach_of(client_id)))));


--
-- Name: POLICY p_coachguideline_delete ON "CoachGuideline"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachguideline_delete ON public."CoachGuideline" IS 'PR-RLS-02: owner, the guideline coach, the guideline client, or the client''s current coach may delete.';


--
-- Name: CoachGuideline p_coachguideline_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachguideline_insert ON public."CoachGuideline" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((coach_id = app.current_user_id()) OR (client_id = app.current_user_id()) OR app.is_current_coach_of(client_id)))));


--
-- Name: POLICY p_coachguideline_insert ON "CoachGuideline"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachguideline_insert ON public."CoachGuideline" IS 'PR-RLS-02: owner, the guideline coach, the guideline client, or the client''s current coach may insert.';


--
-- Name: CoachGuideline p_coachguideline_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachguideline_select ON public."CoachGuideline" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((coach_id = app.current_user_id()) OR (client_id = app.current_user_id()) OR app.is_current_coach_of(client_id)))));


--
-- Name: POLICY p_coachguideline_select ON "CoachGuideline"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachguideline_select ON public."CoachGuideline" IS 'PR-RLS-02: owner, the guideline coach, the guideline client, or the client''s current coach may read.';


--
-- Name: CoachGuideline p_coachguideline_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachguideline_service_role_all ON public."CoachGuideline" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_coachguideline_service_role_all ON "CoachGuideline"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachguideline_service_role_all ON public."CoachGuideline" IS 'PR-RLS-02: service_role bypass for server-side jobs and migrations.';


--
-- Name: CoachGuideline p_coachguideline_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachguideline_update ON public."CoachGuideline" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((coach_id = app.current_user_id()) OR (client_id = app.current_user_id()) OR app.is_current_coach_of(client_id))))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((coach_id = app.current_user_id()) OR (client_id = app.current_user_id()) OR app.is_current_coach_of(client_id)))));


--
-- Name: POLICY p_coachguideline_update ON "CoachGuideline"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachguideline_update ON public."CoachGuideline" IS 'PR-RLS-02: owner, the guideline coach, the guideline client, or the client''s current coach may update.';


--
-- Name: CoachingSession p_coachingsession_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachingsession_delete ON public."CoachingSession" FOR DELETE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((coach_id = app.current_user_id()) OR (client_id = app.current_user_id()) OR app.is_current_coach_of(client_id)))));


--
-- Name: POLICY p_coachingsession_delete ON "CoachingSession"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachingsession_delete ON public."CoachingSession" IS 'PR-RLS-03 Primitive D write: only the owner, the session''s own coach, the session''s lead client, or that client''s current coach may delete the session.';


--
-- Name: CoachingSession p_coachingsession_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachingsession_insert ON public."CoachingSession" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((coach_id = app.current_user_id()) OR (client_id = app.current_user_id()) OR app.is_current_coach_of(client_id)))));


--
-- Name: POLICY p_coachingsession_insert ON "CoachingSession"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachingsession_insert ON public."CoachingSession" IS 'PR-RLS-03 Primitive D write: only the owner, the session''s own coach (coach_id = caller), the session''s lead client (client_id = caller), or that client''s current coach may create the session. coach_id/client_id ARE the authorization columns, so there is no IDOR escape — passing client_id = me means I am that session''s lead client by definition.';


--
-- Name: CoachingSession p_coachingsession_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachingsession_select ON public."CoachingSession" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((coach_id = app.current_user_id()) OR (client_id = app.current_user_id()) OR app.is_current_coach_of(client_id)))));


--
-- Name: POLICY p_coachingsession_select ON "CoachingSession"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachingsession_select ON public."CoachingSession" IS 'PR-RLS-03 Primitive D: owner, the session coach, the lead client, or the client''s current coach may read the session.';


--
-- Name: CoachingSession p_coachingsession_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachingsession_service_role_all ON public."CoachingSession" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_coachingsession_service_role_all ON "CoachingSession"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachingsession_service_role_all ON public."CoachingSession" IS 'PR-RLS-03 Primitive A: service_role full bypass for server-side jobs and migrations.';


--
-- Name: CoachingSession p_coachingsession_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachingsession_update ON public."CoachingSession" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((coach_id = app.current_user_id()) OR (client_id = app.current_user_id()) OR app.is_current_coach_of(client_id))))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((coach_id = app.current_user_id()) OR (client_id = app.current_user_id()) OR app.is_current_coach_of(client_id)))));


--
-- Name: POLICY p_coachingsession_update ON "CoachingSession"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachingsession_update ON public."CoachingSession" IS 'PR-RLS-03 Primitive D write (USING + WITH CHECK): only the owner, the session''s own coach, the session''s lead client, or that client''s current coach may update the session. coach_id/client_id are the authorization columns; WITH CHECK prevents re-pointing the session to a coach/client the caller is not.';


--
-- Name: CoachNudge p_coachnudge_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachnudge_delete ON public."CoachNudge" FOR DELETE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((coach_id = app.current_user_id()) OR (client_id = app.current_user_id()) OR app.is_current_coach_of(client_id)))));


--
-- Name: POLICY p_coachnudge_delete ON "CoachNudge"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachnudge_delete ON public."CoachNudge" IS 'PR-RLS-02: owner, the nudge coach, the nudge client, or the client''s current coach may delete.';


--
-- Name: CoachNudge p_coachnudge_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachnudge_insert ON public."CoachNudge" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((coach_id = app.current_user_id()) OR (client_id = app.current_user_id()) OR app.is_current_coach_of(client_id)))));


--
-- Name: POLICY p_coachnudge_insert ON "CoachNudge"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachnudge_insert ON public."CoachNudge" IS 'PR-RLS-02: owner, the nudge coach, the nudge client, or the client''s current coach may insert.';


--
-- Name: CoachNudge p_coachnudge_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachnudge_select ON public."CoachNudge" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((coach_id = app.current_user_id()) OR (client_id = app.current_user_id()) OR app.is_current_coach_of(client_id)))));


--
-- Name: POLICY p_coachnudge_select ON "CoachNudge"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachnudge_select ON public."CoachNudge" IS 'PR-RLS-02: owner, the nudge coach, the nudge client, or the client''s current coach may read.';


--
-- Name: CoachNudge p_coachnudge_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachnudge_service_role_all ON public."CoachNudge" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_coachnudge_service_role_all ON "CoachNudge"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachnudge_service_role_all ON public."CoachNudge" IS 'PR-RLS-02: service_role bypass for server-side jobs and migrations.';


--
-- Name: CoachNudge p_coachnudge_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachnudge_update ON public."CoachNudge" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((coach_id = app.current_user_id()) OR (client_id = app.current_user_id()) OR app.is_current_coach_of(client_id))))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((coach_id = app.current_user_id()) OR (client_id = app.current_user_id()) OR app.is_current_coach_of(client_id)))));


--
-- Name: POLICY p_coachnudge_update ON "CoachNudge"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachnudge_update ON public."CoachNudge" IS 'PR-RLS-02: owner, the nudge coach, the nudge client, or the client''s current coach may update.';


--
-- Name: CoachOffer p_coachoffer_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachoffer_insert ON public."CoachOffer" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (head_coach_id = app.current_user_id()))));


--
-- Name: POLICY p_coachoffer_insert ON "CoachOffer"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachoffer_insert ON public."CoachOffer" IS 'Write-scope: only the offering head coach (head_coach_id = self) may INSERT an offer. HeadCoachOnly/NoActiveSubCoach gating is enforced in the TM-12 service layer.';


--
-- Name: CoachOffer p_coachoffer_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachoffer_select ON public."CoachOffer" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((head_coach_id = app.current_user_id()) OR (applicant_user_id = app.current_user_id())))));


--
-- Name: POLICY p_coachoffer_select ON "CoachOffer"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachoffer_select ON public."CoachOffer" IS 'Read: the offering head coach (head_coach_id) or the applicant the offer was made to (applicant_user_id). anon sees zero. Cross-coach reads denied (IDOR / financial).';


--
-- Name: CoachOffer p_coachoffer_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachoffer_service_role_all ON public."CoachOffer" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_coachoffer_service_role_all ON "CoachOffer"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachoffer_service_role_all ON public."CoachOffer" IS 'Primitive A: service_role bypass for the transactional accept/withdraw path + server-side jobs.';


--
-- Name: CoachOffer p_coachoffer_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachoffer_update ON public."CoachOffer" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((head_coach_id = app.current_user_id()) OR (applicant_user_id = app.current_user_id()))))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((head_coach_id = app.current_user_id()) OR (applicant_user_id = app.current_user_id())))));


--
-- Name: POLICY p_coachoffer_update ON "CoachOffer"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachoffer_update ON public."CoachOffer" IS 'Write-scope: the head coach may withdraw/edit their own offer; the applicant may accept/reject an offer made to them. CHECK keeps head_coach_id/applicant_user_id owner-pinned. The atomic accept-with-withdraw-others runs as service_role.';


--
-- Name: CoachOnboardingProgress p_coachonboardingprogress_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachonboardingprogress_delete ON public."CoachOnboardingProgress" FOR DELETE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))));


--
-- Name: POLICY p_coachonboardingprogress_delete ON "CoachOnboardingProgress"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachonboardingprogress_delete ON public."CoachOnboardingProgress" IS 'PR-RLS-02: owner or the coach who owns the onboarding row may delete.';


--
-- Name: CoachOnboardingProgress p_coachonboardingprogress_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachonboardingprogress_insert ON public."CoachOnboardingProgress" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))));


--
-- Name: POLICY p_coachonboardingprogress_insert ON "CoachOnboardingProgress"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachonboardingprogress_insert ON public."CoachOnboardingProgress" IS 'PR-RLS-02: owner or the coach who owns the onboarding row may insert.';


--
-- Name: CoachOnboardingProgress p_coachonboardingprogress_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachonboardingprogress_select ON public."CoachOnboardingProgress" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))));


--
-- Name: POLICY p_coachonboardingprogress_select ON "CoachOnboardingProgress"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachonboardingprogress_select ON public."CoachOnboardingProgress" IS 'PR-RLS-02: owner or the coach who owns the onboarding row may read.';


--
-- Name: CoachOnboardingProgress p_coachonboardingprogress_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachonboardingprogress_service_role_all ON public."CoachOnboardingProgress" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_coachonboardingprogress_service_role_all ON "CoachOnboardingProgress"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachonboardingprogress_service_role_all ON public."CoachOnboardingProgress" IS 'PR-RLS-02: service_role bypass for server-side jobs and migrations.';


--
-- Name: CoachOnboardingProgress p_coachonboardingprogress_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_coachonboardingprogress_update ON public."CoachOnboardingProgress" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id())))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))));


--
-- Name: POLICY p_coachonboardingprogress_update ON "CoachOnboardingProgress"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_coachonboardingprogress_update ON public."CoachOnboardingProgress" IS 'PR-RLS-02: owner or the coach who owns the onboarding row may update.';


--
-- Name: community_messages_2026_12 p_community_messages_2026_12_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_community_messages_2026_12_service_role_all ON public.community_messages_2026_12 TO service_role USING (true) WITH CHECK (true);


--
-- Name: community_messages_2027_01 p_community_messages_2027_01_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_community_messages_2027_01_service_role_all ON public.community_messages_2027_01 TO service_role USING (true) WITH CHECK (true);


--
-- Name: community_messages_2027_02 p_community_messages_2027_02_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_community_messages_2027_02_service_role_all ON public.community_messages_2027_02 TO service_role USING (true) WITH CHECK (true);


--
-- Name: community_messages_2028_03 p_community_messages_2028_03_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_community_messages_2028_03_service_role_all ON public.community_messages_2028_03 TO service_role USING (true) WITH CHECK (true);


--
-- Name: community_messages_default p_community_messages_default_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_community_messages_default_service_role_all ON public.community_messages_default TO service_role USING (true) WITH CHECK (true);


--
-- Name: CommunityWin p_communitywin_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_communitywin_delete ON public."CommunityWin" FOR DELETE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR (coach_id = app.current_user_id()) OR app.is_current_coach_of(user_id)))));


--
-- Name: POLICY p_communitywin_delete ON "CommunityWin"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_communitywin_delete ON public."CommunityWin" IS 'PR-RLS-07: DELETE allowed when caller is the win author (user_id = app.current_user_id()), the assigned coach (coach_id = app.current_user_id()), the current coach of the author (app.is_current_coach_of(user_id)), or the service-role/owner bypass (app.is_owner()). visibility=''public'' grants READ access (see p_communitywin_select) but never WRITE access — preventing IDOR-style deletion of other users'' public wins.';


--
-- Name: CommunityWin p_communitywin_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_communitywin_insert ON public."CommunityWin" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR app.is_current_coach_of(user_id)))));


--
-- Name: POLICY p_communitywin_insert ON "CommunityWin"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_communitywin_insert ON public."CommunityWin" IS 'PR-RLS-07: INSERT allowed when caller is the win author (user_id = app.current_user_id()), the current coach of the author (app.is_current_coach_of(user_id)), or the service-role/owner bypass (app.is_owner()). visibility=''public'' grants READ access (see p_communitywin_select) but never WRITE access — preventing IDOR-style forging of public wins for other users.';


--
-- Name: CommunityWin p_communitywin_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_communitywin_select ON public."CommunityWin" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR (coach_id = app.current_user_id()) OR (visibility = 'public'::text) OR app.is_current_coach_of(user_id)))));


--
-- Name: POLICY p_communitywin_select ON "CommunityWin"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_communitywin_select ON public."CommunityWin" IS 'PR-RLS-07: author, assigned/current coach (cohort read), public-visibility, or owner may read a win.';


--
-- Name: CommunityWin p_communitywin_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_communitywin_service_role_all ON public."CommunityWin" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_communitywin_service_role_all ON "CommunityWin"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_communitywin_service_role_all ON public."CommunityWin" IS 'PR-RLS-07: service_role bypass for server-side community jobs.';


--
-- Name: CommunityWin p_communitywin_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_communitywin_update ON public."CommunityWin" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR (coach_id = app.current_user_id()) OR app.is_current_coach_of(user_id))))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR (coach_id = app.current_user_id()) OR app.is_current_coach_of(user_id)))));


--
-- Name: POLICY p_communitywin_update ON "CommunityWin"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_communitywin_update ON public."CommunityWin" IS 'PR-RLS-07: UPDATE allowed when caller is the win author (user_id = app.current_user_id()), the assigned coach (coach_id = app.current_user_id()), the current coach of the author (app.is_current_coach_of(user_id)), or the service-role/owner bypass (app.is_owner()). visibility=''public'' grants READ access (see p_communitywin_select) but never WRITE access — preventing IDOR-style mutation of other users'' public wins.';


--
-- Name: ContractAuditEvent p_contractauditevent_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_contractauditevent_insert ON public."ContractAuditEvent" FOR INSERT WITH CHECK (app.is_owner());


--
-- Name: POLICY p_contractauditevent_insert ON "ContractAuditEvent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_contractauditevent_insert ON public."ContractAuditEvent" IS 'Write-restricted: only owner (or service_role via Primitive A) may INSERT audit rows. Normal authenticated principals (coach/client/sub-coach/anon) cannot forge audit-trail entries; the webhook handler inserts as service_role.';


--
-- Name: ContractAuditEvent p_contractauditevent_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_contractauditevent_select ON public."ContractAuditEvent" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM public."ContractEnvelope" ce
  WHERE ((ce.id = "ContractAuditEvent".envelope_id) AND ((ce.coach_id = app.current_user_id()) OR (ce.client_id = app.current_user_id()))))))));


--
-- Name: POLICY p_contractauditevent_select ON "ContractAuditEvent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_contractauditevent_select ON public."ContractAuditEvent" IS 'Owner-of-envelope read: owner, or the owning coach/signing client of the parent ContractEnvelope, may SELECT its audit events. anon sees zero. Foreign principals are blocked through the parent predicate (IDOR).';


--
-- Name: ContractAuditEvent p_contractauditevent_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_contractauditevent_service_role_all ON public."ContractAuditEvent" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_contractauditevent_service_role_all ON "ContractAuditEvent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_contractauditevent_service_role_all ON public."ContractAuditEvent" IS 'Primitive A: service_role bypass. Audit rows are written by the webhook handler / server jobs running as service_role (the SECURITY DEFINER write path).';


--
-- Name: ContractEnvelope p_contractenvelope_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_contractenvelope_insert ON public."ContractEnvelope" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))));


--
-- Name: POLICY p_contractenvelope_insert ON "ContractEnvelope"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_contractenvelope_insert ON public."ContractEnvelope" IS 'Write: only owner or the owning coach (coach_id = self) may INSERT an envelope. Clients never create envelopes directly; sub-coaches get SELECT only.';


--
-- Name: ContractEnvelope p_contractenvelope_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_contractenvelope_select ON public."ContractEnvelope" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((coach_id = app.current_user_id()) OR (client_id = app.current_user_id()) OR (EXISTS ( SELECT 1
   FROM public."TeamSubCoachAssignment" tsca
  WHERE ((tsca.sub_coach_id = "ContractEnvelope".coach_id) AND (tsca.head_coach_id = app.current_user_id()) AND (tsca.archived_at IS NULL))))))));


--
-- Name: POLICY p_contractenvelope_select ON "ContractEnvelope"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_contractenvelope_select ON public."ContractEnvelope" IS 'Read: owner-coach (coach_id), the signing client (client_id), or the head coach of the owning sub-coach (non-archived TeamSubCoachAssignment) may SELECT. anon sees zero. Cross-coach reads are denied (IDOR).';


--
-- Name: ContractEnvelope p_contractenvelope_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_contractenvelope_service_role_all ON public."ContractEnvelope" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_contractenvelope_service_role_all ON "ContractEnvelope"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_contractenvelope_service_role_all ON public."ContractEnvelope" IS 'Primitive A: service_role bypass for the webhook handler + server-side jobs.';


--
-- Name: ContractEnvelope p_contractenvelope_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_contractenvelope_update ON public."ContractEnvelope" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id())))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))));


--
-- Name: POLICY p_contractenvelope_update ON "ContractEnvelope"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_contractenvelope_update ON public."ContractEnvelope" IS 'Update: owner or owning coach (coach_id) may UPDATE; CHECK prevents re-owning to another coach_id. Status advances from provider events run as service_role.';


--
-- Name: ContractTemplate p_contracttemplate_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_contracttemplate_insert ON public."ContractTemplate" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))));


--
-- Name: POLICY p_contracttemplate_insert ON "ContractTemplate"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_contracttemplate_insert ON public."ContractTemplate" IS 'Owner-coach write: a coach may INSERT only templates they own (coach_id = self). Platform templates are seeded via service_role.';


--
-- Name: ContractTemplate p_contracttemplate_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_contracttemplate_select ON public."ContractTemplate" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((coach_id = app.current_user_id()) OR (is_platform = true)))));


--
-- Name: POLICY p_contracttemplate_select ON "ContractTemplate"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_contracttemplate_select ON public."ContractTemplate" IS 'Owner-coach reads own templates; any authenticated user may read platform/system templates (is_platform = true). anon (NULL current_user_id) sees zero.';


--
-- Name: ContractTemplate p_contracttemplate_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_contracttemplate_service_role_all ON public."ContractTemplate" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_contracttemplate_service_role_all ON "ContractTemplate"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_contracttemplate_service_role_all ON public."ContractTemplate" IS 'Primitive A: service_role bypass for server-side jobs/migrations/seeds.';


--
-- Name: ContractTemplate p_contracttemplate_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_contracttemplate_update ON public."ContractTemplate" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id())))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))));


--
-- Name: POLICY p_contracttemplate_update ON "ContractTemplate"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_contracttemplate_update ON public."ContractTemplate" IS 'Owner-coach update: only owner or the row''s coach_id may UPDATE; CHECK prevents re-owning to another coach_id.';


--
-- Name: DailyMealPlan p_dailymealplan_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_dailymealplan_delete ON public."DailyMealPlan" FOR DELETE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))));


--
-- Name: POLICY p_dailymealplan_delete ON "DailyMealPlan"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_dailymealplan_delete ON public."DailyMealPlan" IS 'PR-RLS-05 coach-self: only the owner or owning coach may delete their daily meal plans.';


--
-- Name: DailyMealPlan p_dailymealplan_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_dailymealplan_insert ON public."DailyMealPlan" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))));


--
-- Name: POLICY p_dailymealplan_insert ON "DailyMealPlan"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_dailymealplan_insert ON public."DailyMealPlan" IS 'PR-RLS-05 coach-self: only the owner or the coach themselves may create plans under their coach_id.';


--
-- Name: DailyMealPlan p_dailymealplan_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_dailymealplan_select ON public."DailyMealPlan" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))));


--
-- Name: POLICY p_dailymealplan_select ON "DailyMealPlan"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_dailymealplan_select ON public."DailyMealPlan" IS 'PR-RLS-05 coach-self: owner or the owning coach may read their daily meal plans.';


--
-- Name: DailyMealPlan p_dailymealplan_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_dailymealplan_service_role_all ON public."DailyMealPlan" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_dailymealplan_service_role_all ON "DailyMealPlan"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_dailymealplan_service_role_all ON public."DailyMealPlan" IS 'PR-RLS-05 Primitive A: service_role bypass for server-side jobs and migrations.';


--
-- Name: DailyMealPlan p_dailymealplan_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_dailymealplan_update ON public."DailyMealPlan" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id())))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))));


--
-- Name: POLICY p_dailymealplan_update ON "DailyMealPlan"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_dailymealplan_update ON public."DailyMealPlan" IS 'PR-RLS-05 coach-self: only the owner or owning coach may update; post-image must remain under that coach_id.';


--
-- Name: DailyMealPlanAssignment p_dailymealplanassignment_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_dailymealplanassignment_delete ON public."DailyMealPlanAssignment" FOR DELETE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((client_id = app.current_user_id()) OR (assigned_by_coach_id = app.current_user_id())))));


--
-- Name: POLICY p_dailymealplanassignment_delete ON "DailyMealPlanAssignment"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_dailymealplanassignment_delete ON public."DailyMealPlanAssignment" IS 'PR-RLS-05 client-self-or-assigned-coach: only the owner, assigned client, or assigning coach may delete. Transitive current-coach access is intentionally excluded.';


--
-- Name: DailyMealPlanAssignment p_dailymealplanassignment_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_dailymealplanassignment_insert ON public."DailyMealPlanAssignment" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((client_id = app.current_user_id()) OR (assigned_by_coach_id = app.current_user_id())))));


--
-- Name: POLICY p_dailymealplanassignment_insert ON "DailyMealPlanAssignment"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_dailymealplanassignment_insert ON public."DailyMealPlanAssignment" IS 'PR-RLS-05 client-self-or-assigned-coach: only the owner, the assigned client, or the assigning coach may insert. Transitive current-coach access is intentionally excluded.';


--
-- Name: DailyMealPlanAssignment p_dailymealplanassignment_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_dailymealplanassignment_select ON public."DailyMealPlanAssignment" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((client_id = app.current_user_id()) OR (assigned_by_coach_id = app.current_user_id())))));


--
-- Name: POLICY p_dailymealplanassignment_select ON "DailyMealPlanAssignment"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_dailymealplanassignment_select ON public."DailyMealPlanAssignment" IS 'PR-RLS-05 client-self-or-assigned-coach: only the owner, the assigned client (client_id), or the assigning coach (assigned_by_coach_id) may read. Transitive app.is_current_coach_of(client_id) is intentionally EXCLUDED so a later/different current coach cannot see assignments they did not make.';


--
-- Name: DailyMealPlanAssignment p_dailymealplanassignment_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_dailymealplanassignment_service_role_all ON public."DailyMealPlanAssignment" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_dailymealplanassignment_service_role_all ON "DailyMealPlanAssignment"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_dailymealplanassignment_service_role_all ON public."DailyMealPlanAssignment" IS 'PR-RLS-05 Primitive A: service_role bypass for server-side jobs and migrations.';


--
-- Name: DailyMealPlanAssignment p_dailymealplanassignment_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_dailymealplanassignment_update ON public."DailyMealPlanAssignment" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((client_id = app.current_user_id()) OR (assigned_by_coach_id = app.current_user_id()))))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((client_id = app.current_user_id()) OR (assigned_by_coach_id = app.current_user_id())))));


--
-- Name: POLICY p_dailymealplanassignment_update ON "DailyMealPlanAssignment"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_dailymealplanassignment_update ON public."DailyMealPlanAssignment" IS 'PR-RLS-05 client-self-or-assigned-coach: only the owner, assigned client, or assigning coach may update; post-image must satisfy the same predicate. Transitive current-coach access is intentionally excluded.';


--
-- Name: DailyMealPlanSlot p_dailymealplanslot_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_dailymealplanslot_delete ON public."DailyMealPlanSlot" FOR DELETE USING ((app.is_owner() OR ((EXISTS ( SELECT 1
   FROM public."DailyMealPlan" dmp
  WHERE ((dmp.id = "DailyMealPlanSlot".daily_meal_plan_id) AND (dmp.coach_id = app.current_user_id())))) OR (EXISTS ( SELECT 1
   FROM public."MealTemplate" mt
  WHERE ((mt.id = "DailyMealPlanSlot".meal_template_id) AND (mt.coach_id = app.current_user_id())))))));


--
-- Name: POLICY p_dailymealplanslot_delete ON "DailyMealPlanSlot"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_dailymealplanslot_delete ON public."DailyMealPlanSlot" IS 'PR-RLS-05 child-via-daily-meal-plan: only the owner or the coach owning the parent DailyMealPlan or referenced MealTemplate may delete.';


--
-- Name: DailyMealPlanSlot p_dailymealplanslot_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_dailymealplanslot_insert ON public."DailyMealPlanSlot" FOR INSERT WITH CHECK ((app.is_owner() OR ((EXISTS ( SELECT 1
   FROM public."DailyMealPlan" dmp
  WHERE ((dmp.id = "DailyMealPlanSlot".daily_meal_plan_id) AND (dmp.coach_id = app.current_user_id())))) OR (EXISTS ( SELECT 1
   FROM public."MealTemplate" mt
  WHERE ((mt.id = "DailyMealPlanSlot".meal_template_id) AND (mt.coach_id = app.current_user_id())))))));


--
-- Name: POLICY p_dailymealplanslot_insert ON "DailyMealPlanSlot"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_dailymealplanslot_insert ON public."DailyMealPlanSlot" IS 'PR-RLS-05 child-via-daily-meal-plan: only the owner or the coach owning the parent DailyMealPlan or referenced MealTemplate may insert a slot.';


--
-- Name: DailyMealPlanSlot p_dailymealplanslot_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_dailymealplanslot_select ON public."DailyMealPlanSlot" FOR SELECT USING ((app.is_owner() OR ((EXISTS ( SELECT 1
   FROM public."DailyMealPlan" dmp
  WHERE ((dmp.id = "DailyMealPlanSlot".daily_meal_plan_id) AND (dmp.coach_id = app.current_user_id())))) OR (EXISTS ( SELECT 1
   FROM public."MealTemplate" mt
  WHERE ((mt.id = "DailyMealPlanSlot".meal_template_id) AND (mt.coach_id = app.current_user_id())))))));


--
-- Name: POLICY p_dailymealplanslot_select ON "DailyMealPlanSlot"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_dailymealplanslot_select ON public."DailyMealPlanSlot" IS 'PR-RLS-05 child-via-daily-meal-plan: owner, or the coach owning the parent DailyMealPlan or the referenced MealTemplate, may read.';


--
-- Name: DailyMealPlanSlot p_dailymealplanslot_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_dailymealplanslot_service_role_all ON public."DailyMealPlanSlot" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_dailymealplanslot_service_role_all ON "DailyMealPlanSlot"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_dailymealplanslot_service_role_all ON public."DailyMealPlanSlot" IS 'PR-RLS-05 Primitive A: service_role bypass for server-side jobs and migrations.';


--
-- Name: DailyMealPlanSlot p_dailymealplanslot_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_dailymealplanslot_update ON public."DailyMealPlanSlot" FOR UPDATE USING ((app.is_owner() OR ((EXISTS ( SELECT 1
   FROM public."DailyMealPlan" dmp
  WHERE ((dmp.id = "DailyMealPlanSlot".daily_meal_plan_id) AND (dmp.coach_id = app.current_user_id())))) OR (EXISTS ( SELECT 1
   FROM public."MealTemplate" mt
  WHERE ((mt.id = "DailyMealPlanSlot".meal_template_id) AND (mt.coach_id = app.current_user_id()))))))) WITH CHECK ((app.is_owner() OR ((EXISTS ( SELECT 1
   FROM public."DailyMealPlan" dmp
  WHERE ((dmp.id = "DailyMealPlanSlot".daily_meal_plan_id) AND (dmp.coach_id = app.current_user_id())))) OR (EXISTS ( SELECT 1
   FROM public."MealTemplate" mt
  WHERE ((mt.id = "DailyMealPlanSlot".meal_template_id) AND (mt.coach_id = app.current_user_id())))))));


--
-- Name: POLICY p_dailymealplanslot_update ON "DailyMealPlanSlot"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_dailymealplanslot_update ON public."DailyMealPlanSlot" IS 'PR-RLS-05 child-via-daily-meal-plan: only the owner or owning coach (parent plan or referenced template) may update; post-image must satisfy the same parent ownership.';


--
-- Name: data_export_request p_data_export_request_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_data_export_request_delete ON public.data_export_request FOR DELETE USING (app.is_owner());


--
-- Name: POLICY p_data_export_request_delete ON data_export_request; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_data_export_request_delete ON public.data_export_request IS 'DELETE restricted to the owner escalation role (app.is_owner()). Export artifacts are expired by the nightly cron and purged during account deletion (src/account-deletion/account-deletion.service.ts:816-819 dataExportRequest.deleteMany), both running as the Supabase service_role (BYPASSRLS). This policy is the defense-in-depth path for any non-bypass connection and intentionally denies tenant-side deletion.';


--
-- Name: data_export_request p_data_export_request_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_data_export_request_insert ON public.data_export_request FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()))));


--
-- Name: POLICY p_data_export_request_insert ON data_export_request; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_data_export_request_insert ON public.data_export_request IS 'A user may request an export only for themselves; owner may request on behalf.';


--
-- Name: data_export_request p_data_export_request_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_data_export_request_select ON public.data_export_request FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()))));


--
-- Name: POLICY p_data_export_request_select ON data_export_request; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_data_export_request_select ON public.data_export_request IS 'A user polls only their own GDPR export status (and signed URL); owner may read any.';


--
-- Name: data_export_request p_data_export_request_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_data_export_request_service_role_all ON public.data_export_request TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_data_export_request_service_role_all ON data_export_request; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_data_export_request_service_role_all ON public.data_export_request IS 'Service role bypass for the GDPR export worker that runs and expires export jobs.';


--
-- Name: data_export_request p_data_export_request_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_data_export_request_update ON public.data_export_request FOR UPDATE USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: POLICY p_data_export_request_update ON data_export_request; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_data_export_request_update ON public.data_export_request IS 'Export status transitions and signed-URL minting are server-driven; only service role / owner may update.';


--
-- Name: deletion_audit p_deletion_audit_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_deletion_audit_delete ON public.deletion_audit FOR DELETE USING (app.is_owner());


--
-- Name: POLICY p_deletion_audit_delete ON deletion_audit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_deletion_audit_delete ON public.deletion_audit IS 'Audit lines are immutable evidence; only service role / owner may delete them.';


--
-- Name: deletion_audit p_deletion_audit_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_deletion_audit_insert ON public.deletion_audit FOR INSERT WITH CHECK (app.is_owner());


--
-- Name: POLICY p_deletion_audit_insert ON deletion_audit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_deletion_audit_insert ON public.deletion_audit IS 'Audit lines are append-only system events written by the deletion worker (service role); only owner may insert otherwise.';


--
-- Name: deletion_audit p_deletion_audit_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_deletion_audit_select ON public.deletion_audit FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR (actor_id = app.current_user_id())))));


--
-- Name: POLICY p_deletion_audit_select ON deletion_audit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_deletion_audit_select ON public.deletion_audit IS 'Read deletion-audit lines only as the subject user, the acting user, or an owner (privacy evidence).';


--
-- Name: deletion_audit p_deletion_audit_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_deletion_audit_service_role_all ON public.deletion_audit TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_deletion_audit_service_role_all ON deletion_audit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_deletion_audit_service_role_all ON public.deletion_audit IS 'Service role bypass: deletion-lifecycle audit lines are written by the deletion worker and cron.';


--
-- Name: deletion_audit p_deletion_audit_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_deletion_audit_update ON public.deletion_audit FOR UPDATE USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: POLICY p_deletion_audit_update ON deletion_audit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_deletion_audit_update ON public.deletion_audit IS 'Audit lines are immutable evidence; only service role / owner may amend them.';


--
-- Name: DiagnosticSubmission p_diagnosticsubmission_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_diagnosticsubmission_delete ON public."DiagnosticSubmission" FOR DELETE USING (app.is_owner());


--
-- Name: POLICY p_diagnosticsubmission_delete ON "DiagnosticSubmission"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_diagnosticsubmission_delete ON public."DiagnosticSubmission" IS 'Diagnostic intake is retained for funnel attribution; only service role / owner may delete it.';


--
-- Name: DiagnosticSubmission p_diagnosticsubmission_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_diagnosticsubmission_insert ON public."DiagnosticSubmission" FOR INSERT WITH CHECK ((app.is_owner() OR (user_id IS NULL) OR ((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()))));


--
-- Name: POLICY p_diagnosticsubmission_insert ON "DiagnosticSubmission"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_diagnosticsubmission_insert ON public."DiagnosticSubmission" IS 'Allow anonymous lead-funnel intake (user_id NULL) plus self-attributed and owner inserts.';


--
-- Name: DiagnosticSubmission p_diagnosticsubmission_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_diagnosticsubmission_select ON public."DiagnosticSubmission" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()))));


--
-- Name: POLICY p_diagnosticsubmission_select ON "DiagnosticSubmission"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_diagnosticsubmission_select ON public."DiagnosticSubmission" IS 'Read diagnostic intake only as the attributed user or an owner; anonymous rows (user_id NULL) are not readable by the public role.';


--
-- Name: DiagnosticSubmission p_diagnosticsubmission_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_diagnosticsubmission_service_role_all ON public."DiagnosticSubmission" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_diagnosticsubmission_service_role_all ON "DiagnosticSubmission"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_diagnosticsubmission_service_role_all ON public."DiagnosticSubmission" IS 'Service role bypass for server-side diagnostic scoring and migrations.';


--
-- Name: DiagnosticSubmission p_diagnosticsubmission_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_diagnosticsubmission_update ON public."DiagnosticSubmission" FOR UPDATE USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: POLICY p_diagnosticsubmission_update ON "DiagnosticSubmission"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_diagnosticsubmission_update ON public."DiagnosticSubmission" IS 'UPDATE restricted to the owner escalation role (app.is_owner()). The two production lifecycle paths run as the Supabase service_role (BYPASSRLS): anonymous-row attach in DiagnosticService.attachUser() (src/diagnostic/diagnostic.service.ts:190-195) and user_id nullification during account deletion (src/account-deletion/account-deletion.service.ts:646-648). This policy is the defense-in-depth path for any non-bypass connection and intentionally denies tenant-side mutation, including a tenant attaching themselves to a user_id-NULL row.';


--
-- Name: EmailSendLog p_emailsendlog_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_emailsendlog_delete ON public."EmailSendLog" FOR DELETE USING (app.is_owner());


--
-- Name: POLICY p_emailsendlog_delete ON "EmailSendLog"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_emailsendlog_delete ON public."EmailSendLog" IS 'PR-RLS-07: owner-only DELETE — tenant users may not delete email-send rows.';


--
-- Name: EmailSendLog p_emailsendlog_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_emailsendlog_insert ON public."EmailSendLog" FOR INSERT WITH CHECK (app.is_owner());


--
-- Name: POLICY p_emailsendlog_insert ON "EmailSendLog"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_emailsendlog_insert ON public."EmailSendLog" IS 'PR-RLS-07: owner-only INSERT — tenant users may not write email-send rows.';


--
-- Name: EmailSendLog p_emailsendlog_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_emailsendlog_select ON public."EmailSendLog" FOR SELECT USING (app.is_owner());


--
-- Name: POLICY p_emailsendlog_select ON "EmailSendLog"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_emailsendlog_select ON public."EmailSendLog" IS 'PR-RLS-07: owner-only SELECT — email delivery PII has no tenant owner column.';


--
-- Name: EmailSendLog p_emailsendlog_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_emailsendlog_service_role_all ON public."EmailSendLog" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_emailsendlog_service_role_all ON "EmailSendLog"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_emailsendlog_service_role_all ON public."EmailSendLog" IS 'PR-RLS-07: service_role bypass for server-side email-send jobs and migrations.';


--
-- Name: EmailSendLog p_emailsendlog_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_emailsendlog_update ON public."EmailSendLog" FOR UPDATE USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: POLICY p_emailsendlog_update ON "EmailSendLog"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_emailsendlog_update ON public."EmailSendLog" IS 'PR-RLS-07: owner-only UPDATE — tenant users may not mutate email-send rows.';


--
-- Name: ExerciseCatalogItem p_exercisecatalogitem_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_exercisecatalogitem_delete ON public."ExerciseCatalogItem" FOR DELETE USING (app.is_owner());


--
-- Name: POLICY p_exercisecatalogitem_delete ON "ExerciseCatalogItem"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_exercisecatalogitem_delete ON public."ExerciseCatalogItem" IS 'Owner-write: only owner (or service_role) may DELETE catalog rows.';


--
-- Name: ExerciseCatalogItem p_exercisecatalogitem_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_exercisecatalogitem_insert ON public."ExerciseCatalogItem" FOR INSERT WITH CHECK (app.is_owner());


--
-- Name: POLICY p_exercisecatalogitem_insert ON "ExerciseCatalogItem"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_exercisecatalogitem_insert ON public."ExerciseCatalogItem" IS 'Owner-write: only owner (or service_role) may INSERT catalog rows.';


--
-- Name: ExerciseCatalogItem p_exercisecatalogitem_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_exercisecatalogitem_select ON public."ExerciseCatalogItem" FOR SELECT USING (true);


--
-- Name: POLICY p_exercisecatalogitem_select ON "ExerciseCatalogItem"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_exercisecatalogitem_select ON public."ExerciseCatalogItem" IS 'Public-catalog read: the exercise picker is a public reference catalog; anyone (incl. anon) may SELECT.';


--
-- Name: ExerciseCatalogItem p_exercisecatalogitem_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_exercisecatalogitem_service_role_all ON public."ExerciseCatalogItem" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_exercisecatalogitem_service_role_all ON "ExerciseCatalogItem"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_exercisecatalogitem_service_role_all ON public."ExerciseCatalogItem" IS 'Primitive A: service_role bypass for server-side jobs/migrations (catalog seeding/enrichment).';


--
-- Name: ExerciseCatalogItem p_exercisecatalogitem_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_exercisecatalogitem_update ON public."ExerciseCatalogItem" FOR UPDATE USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: POLICY p_exercisecatalogitem_update ON "ExerciseCatalogItem"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_exercisecatalogitem_update ON public."ExerciseCatalogItem" IS 'Owner-write: only owner (or service_role) may UPDATE catalog rows.';


--
-- Name: ExerciseSet p_exerciseset_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_exerciseset_delete ON public."ExerciseSet" FOR DELETE USING ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."WorkoutSession" ws
  WHERE ((ws.id = "ExerciseSet".workout_id) AND ((ws.user_id = app.current_user_id()) OR app.is_current_coach_of(ws.user_id)))))));


--
-- Name: POLICY p_exerciseset_delete ON "ExerciseSet"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_exerciseset_delete ON public."ExerciseSet" IS 'Child-via-session delete: owner, session owner, or current coach may DELETE.';


--
-- Name: ExerciseSet p_exerciseset_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_exerciseset_insert ON public."ExerciseSet" FOR INSERT WITH CHECK ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."WorkoutSession" ws
  WHERE ((ws.id = "ExerciseSet".workout_id) AND ((ws.user_id = app.current_user_id()) OR app.is_current_coach_of(ws.user_id)))))));


--
-- Name: POLICY p_exerciseset_insert ON "ExerciseSet"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_exerciseset_insert ON public."ExerciseSet" IS 'Child-via-session write: owner, the session owner, or that user''s current coach may INSERT.';


--
-- Name: ExerciseSet p_exerciseset_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_exerciseset_select ON public."ExerciseSet" FOR SELECT USING ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."WorkoutSession" ws
  WHERE ((ws.id = "ExerciseSet".workout_id) AND ((ws.user_id = app.current_user_id()) OR app.is_current_coach_of(ws.user_id)))))));


--
-- Name: POLICY p_exerciseset_select ON "ExerciseSet"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_exerciseset_select ON public."ExerciseSet" IS 'Child-via-session read: owner, the session owner (user_id), or that user''s current coach may SELECT.';


--
-- Name: ExerciseSet p_exerciseset_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_exerciseset_service_role_all ON public."ExerciseSet" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_exerciseset_service_role_all ON "ExerciseSet"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_exerciseset_service_role_all ON public."ExerciseSet" IS 'Primitive A: service_role bypass for server-side jobs/migrations.';


--
-- Name: ExerciseSet p_exerciseset_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_exerciseset_update ON public."ExerciseSet" FOR UPDATE USING ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."WorkoutSession" ws
  WHERE ((ws.id = "ExerciseSet".workout_id) AND ((ws.user_id = app.current_user_id()) OR app.is_current_coach_of(ws.user_id))))))) WITH CHECK ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."WorkoutSession" ws
  WHERE ((ws.id = "ExerciseSet".workout_id) AND ((ws.user_id = app.current_user_id()) OR app.is_current_coach_of(ws.user_id)))))));


--
-- Name: POLICY p_exerciseset_update ON "ExerciseSet"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_exerciseset_update ON public."ExerciseSet" IS 'Child-via-session update: owner, session owner, or current coach may UPDATE; CHECK reverifies the parent session.';


--
-- Name: FoodItem p_fooditem_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_fooditem_delete ON public."FoodItem" FOR DELETE USING (app.is_owner());


--
-- Name: POLICY p_fooditem_delete ON "FoodItem"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_fooditem_delete ON public."FoodItem" IS 'FoodItem is a global catalog (USDA FDC + OpenFoodFacts upstream). No per-row ownership column exists. Non-bypass writes are denied; only app.is_owner() (catalog admins) or service_role may write. See RLS_REMEDIATION_PLAN.md.';


--
-- Name: FoodItem p_fooditem_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_fooditem_insert ON public."FoodItem" FOR INSERT WITH CHECK (app.is_owner());


--
-- Name: POLICY p_fooditem_insert ON "FoodItem"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_fooditem_insert ON public."FoodItem" IS 'FoodItem is a global catalog (USDA FDC + OpenFoodFacts upstream). No per-row ownership column exists. Non-bypass writes are denied; only app.is_owner() (catalog admins) or service_role may write. See RLS_REMEDIATION_PLAN.md.';


--
-- Name: FoodItem p_fooditem_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_fooditem_select ON public."FoodItem" FOR SELECT USING (true);


--
-- Name: POLICY p_fooditem_select ON "FoodItem"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_fooditem_select ON public."FoodItem" IS 'PR-RLS-05 public-catalog-read: the food catalog is a shared reference table; any caller (including unauthenticated) may read.';


--
-- Name: FoodItem p_fooditem_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_fooditem_service_role_all ON public."FoodItem" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_fooditem_service_role_all ON "FoodItem"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_fooditem_service_role_all ON public."FoodItem" IS 'PR-RLS-05 Primitive A: service_role bypass for server-side jobs and migrations.';


--
-- Name: FoodItem p_fooditem_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_fooditem_update ON public."FoodItem" FOR UPDATE USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: POLICY p_fooditem_update ON "FoodItem"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_fooditem_update ON public."FoodItem" IS 'FoodItem is a global catalog (USDA FDC + OpenFoodFacts upstream). No per-row ownership column exists. Non-bypass writes are denied; only app.is_owner() (catalog admins) or service_role may write. See RLS_REMEDIATION_PLAN.md.';


--
-- Name: HabitLog p_habitlog_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_habitlog_delete ON public."HabitLog" FOR DELETE USING ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."Habit" h
  WHERE ((h.id = "HabitLog".habit_id) AND ((h.user_id = app.current_user_id()) OR app.is_current_coach_of(h.user_id)))))));


--
-- Name: POLICY p_habitlog_delete ON "HabitLog"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_habitlog_delete ON public."HabitLog" IS 'PR-RLS-07: habit owner or that owner''s current coach (or backend owner) may delete a habit log.';


--
-- Name: HabitLog p_habitlog_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_habitlog_insert ON public."HabitLog" FOR INSERT WITH CHECK ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."Habit" h
  WHERE ((h.id = "HabitLog".habit_id) AND ((h.user_id = app.current_user_id()) OR app.is_current_coach_of(h.user_id)))))));


--
-- Name: POLICY p_habitlog_insert ON "HabitLog"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_habitlog_insert ON public."HabitLog" IS 'PR-RLS-07: habit owner or that owner''s current coach (or backend owner) may write a habit log.';


--
-- Name: HabitLog p_habitlog_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_habitlog_select ON public."HabitLog" FOR SELECT USING ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."Habit" h
  WHERE ((h.id = "HabitLog".habit_id) AND ((h.user_id = app.current_user_id()) OR app.is_current_coach_of(h.user_id)))))));


--
-- Name: POLICY p_habitlog_select ON "HabitLog"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_habitlog_select ON public."HabitLog" IS 'PR-RLS-07: habit owner or that owner''s current coach (or backend owner) may read a habit log.';


--
-- Name: HabitLog p_habitlog_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_habitlog_service_role_all ON public."HabitLog" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_habitlog_service_role_all ON "HabitLog"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_habitlog_service_role_all ON public."HabitLog" IS 'PR-RLS-07: service_role bypass for server-side habit jobs.';


--
-- Name: HabitLog p_habitlog_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_habitlog_update ON public."HabitLog" FOR UPDATE USING ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."Habit" h
  WHERE ((h.id = "HabitLog".habit_id) AND ((h.user_id = app.current_user_id()) OR app.is_current_coach_of(h.user_id))))))) WITH CHECK ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."Habit" h
  WHERE ((h.id = "HabitLog".habit_id) AND ((h.user_id = app.current_user_id()) OR app.is_current_coach_of(h.user_id)))))));


--
-- Name: POLICY p_habitlog_update ON "HabitLog"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_habitlog_update ON public."HabitLog" IS 'PR-RLS-07: habit owner or that owner''s current coach (or backend owner) may update a habit log.';


--
-- Name: HolisticInsightCache p_holisticinsightcache_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_holisticinsightcache_delete ON public."HolisticInsightCache" FOR DELETE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR app.is_current_coach_of(user_id)))));


--
-- Name: POLICY p_holisticinsightcache_delete ON "HolisticInsightCache"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_holisticinsightcache_delete ON public."HolisticInsightCache" IS 'PR-RLS-06 user-self-current-coach delete: owner, the user, or the user''s current coach.';


--
-- Name: HolisticInsightCache p_holisticinsightcache_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_holisticinsightcache_insert ON public."HolisticInsightCache" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR app.is_current_coach_of(user_id)))));


--
-- Name: POLICY p_holisticinsightcache_insert ON "HolisticInsightCache"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_holisticinsightcache_insert ON public."HolisticInsightCache" IS 'PR-RLS-06 user-self-current-coach insert: owner, the user, or the user''s current coach.';


--
-- Name: HolisticInsightCache p_holisticinsightcache_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_holisticinsightcache_select ON public."HolisticInsightCache" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR app.is_current_coach_of(user_id)))));


--
-- Name: POLICY p_holisticinsightcache_select ON "HolisticInsightCache"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_holisticinsightcache_select ON public."HolisticInsightCache" IS 'PR-RLS-06 user-self-current-coach read: owner, the user (user_id), or the user''s current coach.';


--
-- Name: HolisticInsightCache p_holisticinsightcache_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_holisticinsightcache_service_role_all ON public."HolisticInsightCache" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_holisticinsightcache_service_role_all ON "HolisticInsightCache"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_holisticinsightcache_service_role_all ON public."HolisticInsightCache" IS 'PR-RLS-06 Primitive A: service_role bypass for server-side jobs and migrations.';


--
-- Name: HolisticInsightCache p_holisticinsightcache_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_holisticinsightcache_update ON public."HolisticInsightCache" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR app.is_current_coach_of(user_id))))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR app.is_current_coach_of(user_id)))));


--
-- Name: POLICY p_holisticinsightcache_update ON "HolisticInsightCache"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_holisticinsightcache_update ON public."HolisticInsightCache" IS 'PR-RLS-06 user-self-current-coach update: owner, the user, or the user''s current coach.';


--
-- Name: JobListing p_joblisting_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_joblisting_insert ON public."JobListing" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (hirer_id = app.current_user_id()))));


--
-- Name: POLICY p_joblisting_insert ON "JobListing"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_joblisting_insert ON public."JobListing" IS 'Write-scope: a hirer may INSERT only listings they own (hirer_id = self). Verified-hirer gating is enforced in TM-2 service layer.';


--
-- Name: JobListing p_joblisting_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_joblisting_select ON public."JobListing" FOR SELECT USING ((app.is_owner() OR (status = 'published'::public."JobListingStatus") OR ((app.current_user_id() IS NOT NULL) AND (hirer_id = app.current_user_id()))));


--
-- Name: POLICY p_joblisting_select ON "JobListing"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_joblisting_select ON public."JobListing" IS 'Public-read: anyone (incl. anon, NULL current_user_id) may SELECT published listings. The owning hirer additionally reads their own draft/closed rows. Non-published rows are invisible to anon and to other users.';


--
-- Name: JobListing p_joblisting_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_joblisting_service_role_all ON public."JobListing" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_joblisting_service_role_all ON "JobListing"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_joblisting_service_role_all ON public."JobListing" IS 'Primitive A: service_role bypass for server-side jobs/migrations/seeds.';


--
-- Name: JobListing p_joblisting_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_joblisting_update ON public."JobListing" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (hirer_id = app.current_user_id())))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (hirer_id = app.current_user_id()))));


--
-- Name: POLICY p_joblisting_update ON "JobListing"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_joblisting_update ON public."JobListing" IS 'Write-scope: only owner or the row''s hirer_id may UPDATE (publish/close/edit); CHECK prevents re-owning to another hirer_id.';


--
-- Name: Lesson p_lesson_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_lesson_delete ON public."Lesson" FOR DELETE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))));


--
-- Name: POLICY p_lesson_delete ON "Lesson"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_lesson_delete ON public."Lesson" IS 'PR-RLS-06 coach-self delete: owner, or coach deleting their own lesson.';


--
-- Name: Lesson p_lesson_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_lesson_insert ON public."Lesson" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))));


--
-- Name: POLICY p_lesson_insert ON "Lesson"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_lesson_insert ON public."Lesson" IS 'PR-RLS-06 coach-self insert: owner, or coach inserting their own lesson (coach_id = current user).';


--
-- Name: Lesson p_lesson_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_lesson_select ON public."Lesson" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))));


--
-- Name: POLICY p_lesson_select ON "Lesson"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_lesson_select ON public."Lesson" IS 'PR-RLS-06 coach-self read: owner, or the lesson owning coach (coach_id = current user).';


--
-- Name: Lesson p_lesson_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_lesson_service_role_all ON public."Lesson" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_lesson_service_role_all ON "Lesson"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_lesson_service_role_all ON public."Lesson" IS 'PR-RLS-06 Primitive A: service_role bypass for server-side jobs and migrations.';


--
-- Name: Lesson p_lesson_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_lesson_update ON public."Lesson" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id())))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))));


--
-- Name: POLICY p_lesson_update ON "Lesson"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_lesson_update ON public."Lesson" IS 'PR-RLS-06 coach-self update: owner, or coach editing their own lesson; WITH CHECK blocks reassigning coach_id away from self.';


--
-- Name: LessonCompletion p_lessoncompletion_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_lessoncompletion_delete ON public."LessonCompletion" FOR DELETE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR app.is_current_coach_of(user_id) OR (EXISTS ( SELECT 1
   FROM public."Lesson" l
  WHERE ((l.id = "LessonCompletion".lesson_id) AND (l.coach_id = app.current_user_id()))))))));


--
-- Name: POLICY p_lessoncompletion_delete ON "LessonCompletion"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_lessoncompletion_delete ON public."LessonCompletion" IS 'PR-RLS-06 lesson-completion delete: owner, the completing user, that user''s current coach, or the lesson''s owning coach.';


--
-- Name: LessonCompletion p_lessoncompletion_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_lessoncompletion_insert ON public."LessonCompletion" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR app.is_current_coach_of(user_id) OR (EXISTS ( SELECT 1
   FROM public."Lesson" l
  WHERE ((l.id = "LessonCompletion".lesson_id) AND (l.coach_id = app.current_user_id()))))))));


--
-- Name: POLICY p_lessoncompletion_insert ON "LessonCompletion"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_lessoncompletion_insert ON public."LessonCompletion" IS 'PR-RLS-06 lesson-completion insert: owner, the completing user, that user''s current coach, or the lesson''s owning coach.';


--
-- Name: LessonCompletion p_lessoncompletion_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_lessoncompletion_select ON public."LessonCompletion" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR app.is_current_coach_of(user_id) OR (EXISTS ( SELECT 1
   FROM public."Lesson" l
  WHERE ((l.id = "LessonCompletion".lesson_id) AND (l.coach_id = app.current_user_id()))))))));


--
-- Name: POLICY p_lessoncompletion_select ON "LessonCompletion"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_lessoncompletion_select ON public."LessonCompletion" IS 'PR-RLS-06 lesson-completion read: owner, the completing user (user_id), that user''s current coach, or the lesson''s owning coach.';


--
-- Name: LessonCompletion p_lessoncompletion_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_lessoncompletion_service_role_all ON public."LessonCompletion" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_lessoncompletion_service_role_all ON "LessonCompletion"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_lessoncompletion_service_role_all ON public."LessonCompletion" IS 'PR-RLS-06 Primitive A: service_role bypass for server-side jobs and migrations.';


--
-- Name: LessonCompletion p_lessoncompletion_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_lessoncompletion_update ON public."LessonCompletion" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR app.is_current_coach_of(user_id) OR (EXISTS ( SELECT 1
   FROM public."Lesson" l
  WHERE ((l.id = "LessonCompletion".lesson_id) AND (l.coach_id = app.current_user_id())))))))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR app.is_current_coach_of(user_id) OR (EXISTS ( SELECT 1
   FROM public."Lesson" l
  WHERE ((l.id = "LessonCompletion".lesson_id) AND (l.coach_id = app.current_user_id()))))))));


--
-- Name: POLICY p_lessoncompletion_update ON "LessonCompletion"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_lessoncompletion_update ON public."LessonCompletion" IS 'PR-RLS-06 lesson-completion update: owner, the completing user, that user''s current coach, or the lesson''s owning coach.';


--
-- Name: MarketplaceAbuseSignal p_marketplace_abuse_signal_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_marketplace_abuse_signal_service_role_all ON public."MarketplaceAbuseSignal" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_marketplace_abuse_signal_service_role_all ON "MarketplaceAbuseSignal"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_marketplace_abuse_signal_service_role_all ON public."MarketplaceAbuseSignal" IS 'Primitive A: service_role bypass. The abuse-signal store is written/read only by the server-side anti-bot gate (TM-6) running as service_role.';


--
-- Name: MarketplaceConnectEvent p_marketplace_connect_event_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_marketplace_connect_event_service_role_all ON public."MarketplaceConnectEvent" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_marketplace_connect_event_service_role_all ON "MarketplaceConnectEvent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_marketplace_connect_event_service_role_all ON public."MarketplaceConnectEvent" IS 'Primitive A: service_role bypass. The Connect-event ledger is written/read only by the server-side TM-14 webhook handler running as service_role.';


--
-- Name: MarketplaceMutationIdempotency p_marketplace_idempotency_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_marketplace_idempotency_service_role_all ON public."MarketplaceMutationIdempotency" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_marketplace_idempotency_service_role_all ON "MarketplaceMutationIdempotency"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_marketplace_idempotency_service_role_all ON public."MarketplaceMutationIdempotency" IS 'Primitive A: service_role bypass. The idempotency ledger is written/read only by the server-side mutation engine (TM-4) running as service_role.';


--
-- Name: MealPlan p_mealplan_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_mealplan_delete ON public."MealPlan" FOR DELETE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (((client_id IS NOT NULL) AND ((client_id = app.current_user_id()) OR app.is_current_coach_of(client_id))) OR (coach_id = app.current_user_id())))));


--
-- Name: POLICY p_mealplan_delete ON "MealPlan"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_mealplan_delete ON public."MealPlan" IS 'PR-RLS-05 client-self-or-coach: only the owner, plan client, that client''s current coach, or the plan coach may delete.';


--
-- Name: MealPlan p_mealplan_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_mealplan_insert ON public."MealPlan" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (((client_id IS NOT NULL) AND ((client_id = app.current_user_id()) OR app.is_current_coach_of(client_id))) OR (coach_id = app.current_user_id())))));


--
-- Name: POLICY p_mealplan_insert ON "MealPlan"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_mealplan_insert ON public."MealPlan" IS 'PR-RLS-05 client-self-or-coach: only the owner, plan client, that client''s current coach, or the plan coach may insert.';


--
-- Name: MealPlan p_mealplan_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_mealplan_select ON public."MealPlan" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (((client_id IS NOT NULL) AND ((client_id = app.current_user_id()) OR app.is_current_coach_of(client_id))) OR (coach_id = app.current_user_id())))));


--
-- Name: POLICY p_mealplan_select ON "MealPlan"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_mealplan_select ON public."MealPlan" IS 'PR-RLS-05 client-self-or-coach: owner, the plan client, that client''s current coach, or the plan coach may read.';


--
-- Name: MealPlan p_mealplan_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_mealplan_service_role_all ON public."MealPlan" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_mealplan_service_role_all ON "MealPlan"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_mealplan_service_role_all ON public."MealPlan" IS 'PR-RLS-05 Primitive A: service_role bypass for server-side jobs and migrations.';


--
-- Name: MealPlan p_mealplan_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_mealplan_update ON public."MealPlan" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (((client_id IS NOT NULL) AND ((client_id = app.current_user_id()) OR app.is_current_coach_of(client_id))) OR (coach_id = app.current_user_id()))))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (((client_id IS NOT NULL) AND ((client_id = app.current_user_id()) OR app.is_current_coach_of(client_id))) OR (coach_id = app.current_user_id())))));


--
-- Name: POLICY p_mealplan_update ON "MealPlan"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_mealplan_update ON public."MealPlan" IS 'PR-RLS-05 client-self-or-coach: only the owner, plan client, that client''s current coach, or the plan coach may update (both row visibility and post-image).';


--
-- Name: MealTemplate p_mealtemplate_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_mealtemplate_delete ON public."MealTemplate" FOR DELETE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))));


--
-- Name: POLICY p_mealtemplate_delete ON "MealTemplate"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_mealtemplate_delete ON public."MealTemplate" IS 'PR-RLS-05 coach-self: only the owner or owning coach may delete their templates.';


--
-- Name: MealTemplate p_mealtemplate_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_mealtemplate_insert ON public."MealTemplate" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))));


--
-- Name: POLICY p_mealtemplate_insert ON "MealTemplate"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_mealtemplate_insert ON public."MealTemplate" IS 'PR-RLS-05 coach-self: only the owner or the coach themselves may create templates under their coach_id.';


--
-- Name: MealTemplate p_mealtemplate_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_mealtemplate_select ON public."MealTemplate" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))));


--
-- Name: POLICY p_mealtemplate_select ON "MealTemplate"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_mealtemplate_select ON public."MealTemplate" IS 'PR-RLS-05 coach-self: owner or the owning coach may read their meal templates.';


--
-- Name: MealTemplate p_mealtemplate_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_mealtemplate_service_role_all ON public."MealTemplate" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_mealtemplate_service_role_all ON "MealTemplate"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_mealtemplate_service_role_all ON public."MealTemplate" IS 'PR-RLS-05 Primitive A: service_role bypass for server-side jobs and migrations.';


--
-- Name: MealTemplate p_mealtemplate_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_mealtemplate_update ON public."MealTemplate" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id())))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))));


--
-- Name: POLICY p_mealtemplate_update ON "MealTemplate"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_mealtemplate_update ON public."MealTemplate" IS 'PR-RLS-05 coach-self: only the owner or owning coach may update; post-image must remain under that coach_id.';


--
-- Name: NotificationDeliveryLog p_notificationdeliverylog_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_notificationdeliverylog_delete ON public."NotificationDeliveryLog" FOR DELETE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()))));


--
-- Name: POLICY p_notificationdeliverylog_delete ON "NotificationDeliveryLog"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_notificationdeliverylog_delete ON public."NotificationDeliveryLog" IS 'PR-RLS-07: owner or self DELETE — a user may only delete their own delivery records.';


--
-- Name: NotificationDeliveryLog p_notificationdeliverylog_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_notificationdeliverylog_insert ON public."NotificationDeliveryLog" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()))));


--
-- Name: POLICY p_notificationdeliverylog_insert ON "NotificationDeliveryLog"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_notificationdeliverylog_insert ON public."NotificationDeliveryLog" IS 'PR-RLS-07: owner or self INSERT — a user may only write rows scoped to themselves.';


--
-- Name: NotificationDeliveryLog p_notificationdeliverylog_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_notificationdeliverylog_select ON public."NotificationDeliveryLog" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()))));


--
-- Name: POLICY p_notificationdeliverylog_select ON "NotificationDeliveryLog"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_notificationdeliverylog_select ON public."NotificationDeliveryLog" IS 'PR-RLS-07: owner or the user themselves may read their delivery records.';


--
-- Name: NotificationDeliveryLog p_notificationdeliverylog_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_notificationdeliverylog_service_role_all ON public."NotificationDeliveryLog" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_notificationdeliverylog_service_role_all ON "NotificationDeliveryLog"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_notificationdeliverylog_service_role_all ON public."NotificationDeliveryLog" IS 'PR-RLS-07: service_role bypass for the notification dispatcher.';


--
-- Name: NotificationDeliveryLog p_notificationdeliverylog_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_notificationdeliverylog_update ON public."NotificationDeliveryLog" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id())))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()))));


--
-- Name: POLICY p_notificationdeliverylog_update ON "NotificationDeliveryLog"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_notificationdeliverylog_update ON public."NotificationDeliveryLog" IS 'PR-RLS-07: owner or self UPDATE — both the existing and the new row must be self-owned.';


--
-- Name: NotificationDigestLog p_notificationdigestlog_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_notificationdigestlog_delete ON public."NotificationDigestLog" FOR DELETE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()))));


--
-- Name: POLICY p_notificationdigestlog_delete ON "NotificationDigestLog"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_notificationdigestlog_delete ON public."NotificationDigestLog" IS 'PR-RLS-07: owner or self DELETE — a user may only delete their own digest records.';


--
-- Name: NotificationDigestLog p_notificationdigestlog_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_notificationdigestlog_insert ON public."NotificationDigestLog" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()))));


--
-- Name: POLICY p_notificationdigestlog_insert ON "NotificationDigestLog"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_notificationdigestlog_insert ON public."NotificationDigestLog" IS 'PR-RLS-07: owner or self INSERT — a user may only write digest rows scoped to themselves.';


--
-- Name: NotificationDigestLog p_notificationdigestlog_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_notificationdigestlog_select ON public."NotificationDigestLog" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()))));


--
-- Name: POLICY p_notificationdigestlog_select ON "NotificationDigestLog"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_notificationdigestlog_select ON public."NotificationDigestLog" IS 'PR-RLS-07: owner or the user themselves may read their digest records.';


--
-- Name: NotificationDigestLog p_notificationdigestlog_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_notificationdigestlog_service_role_all ON public."NotificationDigestLog" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_notificationdigestlog_service_role_all ON "NotificationDigestLog"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_notificationdigestlog_service_role_all ON public."NotificationDigestLog" IS 'PR-RLS-07: service_role bypass for the digest scheduler.';


--
-- Name: NotificationDigestLog p_notificationdigestlog_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_notificationdigestlog_update ON public."NotificationDigestLog" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id())))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()))));


--
-- Name: POLICY p_notificationdigestlog_update ON "NotificationDigestLog"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_notificationdigestlog_update ON public."NotificationDigestLog" IS 'PR-RLS-07: owner or self UPDATE — both the existing and the new row must be self-owned.';


--
-- Name: PartialRefundDecision p_partialrefunddecision_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_partialrefunddecision_select ON public."PartialRefundDecision" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM public."ClientPurchase" cp
  WHERE ((cp.id = "PartialRefundDecision".client_purchase_id) AND (cp.coach_user_id = app.current_user_id())))))));


--
-- Name: POLICY p_partialrefunddecision_select ON "PartialRefundDecision"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_partialrefunddecision_select ON public."PartialRefundDecision" IS 'Coach-of-purchase read: owner, or the coach who owns the parent ClientPurchase (coach_user_id = current user), may SELECT the decision. anon and foreign coaches see zero rows (cross-tenant resolves to not-found).';


--
-- Name: PartialRefundDecision p_partialrefunddecision_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_partialrefunddecision_service_role_all ON public."PartialRefundDecision" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_partialrefunddecision_service_role_all ON "PartialRefundDecision"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_partialrefunddecision_service_role_all ON public."PartialRefundDecision" IS 'Primitive A: service_role bypass for the partial-refund webhook insert path and server-side jobs/migrations.';


--
-- Name: PartialRefundDecision p_partialrefunddecision_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_partialrefunddecision_update ON public."PartialRefundDecision" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM public."ClientPurchase" cp
  WHERE ((cp.id = "PartialRefundDecision".client_purchase_id) AND (cp.coach_user_id = app.current_user_id()))))))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM public."ClientPurchase" cp
  WHERE ((cp.id = "PartialRefundDecision".client_purchase_id) AND (cp.coach_user_id = app.current_user_id())))))));


--
-- Name: POLICY p_partialrefunddecision_update ON "PartialRefundDecision"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_partialrefunddecision_update ON public."PartialRefundDecision" IS 'Coach-of-purchase decide: owner or the owning coach may UPDATE (keep_drops/unassign_drops). CHECK prevents re-pointing a decision at another coach''s purchase. INSERT/DELETE remain service_role-only (Primitive A) for the webhook insert path.';


--
-- Name: PayoutSnapshot p_payoutsnapshot_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_payoutsnapshot_delete ON public."PayoutSnapshot" FOR DELETE USING (app.is_owner());


--
-- Name: POLICY p_payoutsnapshot_delete ON "PayoutSnapshot"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_payoutsnapshot_delete ON public."PayoutSnapshot" IS 'Payout snapshots are server-managed; only service role / owner may delete them.';


--
-- Name: PayoutSnapshot p_payoutsnapshot_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_payoutsnapshot_insert ON public."PayoutSnapshot" FOR INSERT WITH CHECK (app.is_owner());


--
-- Name: POLICY p_payoutsnapshot_insert ON "PayoutSnapshot"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_payoutsnapshot_insert ON public."PayoutSnapshot" IS 'Payout snapshots are server-minted (service role); only owner may insert otherwise.';


--
-- Name: PayoutSnapshot p_payoutsnapshot_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_payoutsnapshot_select ON public."PayoutSnapshot" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_user_id = app.current_user_id()))));


--
-- Name: POLICY p_payoutsnapshot_select ON "PayoutSnapshot"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_payoutsnapshot_select ON public."PayoutSnapshot" IS 'A coach reads only their own payout/balance snapshot; owner may read any.';


--
-- Name: PayoutSnapshot p_payoutsnapshot_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_payoutsnapshot_service_role_all ON public."PayoutSnapshot" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_payoutsnapshot_service_role_all ON "PayoutSnapshot"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_payoutsnapshot_service_role_all ON public."PayoutSnapshot" IS 'Service role bypass: payout snapshots are minted from server-side Stripe balance pulls.';


--
-- Name: PayoutSnapshot p_payoutsnapshot_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_payoutsnapshot_update ON public."PayoutSnapshot" FOR UPDATE USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: POLICY p_payoutsnapshot_update ON "PayoutSnapshot"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_payoutsnapshot_update ON public."PayoutSnapshot" IS 'Payout snapshots are server-refreshed; only service role / owner may update them.';


--
-- Name: Person p_person_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_person_service_role_all ON public."Person" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_person_service_role_all ON "Person"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_person_service_role_all ON public."Person" IS 'service_role bypass: invite-pending roster is written/read only via the server-side reconstruction engine running as service_role.';


--
-- Name: _prisma_migrations p_prisma_migrations_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_prisma_migrations_delete ON public._prisma_migrations FOR DELETE USING (app.is_owner());


--
-- Name: POLICY p_prisma_migrations_delete ON _prisma_migrations; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_prisma_migrations_delete ON public._prisma_migrations IS 'PR-RLS-07: owner-only DELETE for non-owner roles; the Prisma runner (table owner) bypasses via ENABLE-only.';


--
-- Name: _prisma_migrations p_prisma_migrations_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_prisma_migrations_insert ON public._prisma_migrations FOR INSERT WITH CHECK (app.is_owner());


--
-- Name: POLICY p_prisma_migrations_insert ON _prisma_migrations; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_prisma_migrations_insert ON public._prisma_migrations IS 'PR-RLS-07: owner-only INSERT for non-owner roles. NOTE: the table owner (the Prisma migration runner) bypasses this because the table is ENABLE-only (NOT FORCE) — preserving migrate deploy.';


--
-- Name: _prisma_migrations p_prisma_migrations_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_prisma_migrations_select ON public._prisma_migrations FOR SELECT USING (app.is_owner());


--
-- Name: POLICY p_prisma_migrations_select ON _prisma_migrations; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_prisma_migrations_select ON public._prisma_migrations IS 'PR-RLS-07: owner-only SELECT — deployment history is not exposed to tenant users.';


--
-- Name: _prisma_migrations p_prisma_migrations_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_prisma_migrations_service_role_all ON public._prisma_migrations TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_prisma_migrations_service_role_all ON _prisma_migrations; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_prisma_migrations_service_role_all ON public._prisma_migrations IS 'PR-RLS-07: service_role bypass — migration metadata is server-side-only.';


--
-- Name: _prisma_migrations p_prisma_migrations_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_prisma_migrations_update ON public._prisma_migrations FOR UPDATE USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: POLICY p_prisma_migrations_update ON _prisma_migrations; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_prisma_migrations_update ON public._prisma_migrations IS 'PR-RLS-07: owner-only UPDATE for non-owner roles; the Prisma runner (table owner) bypasses via ENABLE-only.';


--
-- Name: PtmPrediction p_ptmprediction_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_ptmprediction_delete ON public."PtmPrediction" FOR DELETE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR app.is_current_coach_of(user_id)))));


--
-- Name: POLICY p_ptmprediction_delete ON "PtmPrediction"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_ptmprediction_delete ON public."PtmPrediction" IS 'PR-RLS-06 user-self-current-coach delete: owner, the user, or the user''s current coach.';


--
-- Name: PtmPrediction p_ptmprediction_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_ptmprediction_insert ON public."PtmPrediction" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR app.is_current_coach_of(user_id)))));


--
-- Name: POLICY p_ptmprediction_insert ON "PtmPrediction"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_ptmprediction_insert ON public."PtmPrediction" IS 'PR-RLS-06 user-self-current-coach insert: owner, the user, or the user''s current coach.';


--
-- Name: PtmPrediction p_ptmprediction_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_ptmprediction_select ON public."PtmPrediction" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR app.is_current_coach_of(user_id)))));


--
-- Name: POLICY p_ptmprediction_select ON "PtmPrediction"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_ptmprediction_select ON public."PtmPrediction" IS 'PR-RLS-06 user-self-current-coach read: owner, the user (user_id), or the user''s current coach.';


--
-- Name: PtmPrediction p_ptmprediction_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_ptmprediction_service_role_all ON public."PtmPrediction" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_ptmprediction_service_role_all ON "PtmPrediction"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_ptmprediction_service_role_all ON public."PtmPrediction" IS 'PR-RLS-06 Primitive A: service_role bypass for server-side jobs and migrations.';


--
-- Name: PtmPrediction p_ptmprediction_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_ptmprediction_update ON public."PtmPrediction" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR app.is_current_coach_of(user_id))))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR app.is_current_coach_of(user_id)))));


--
-- Name: POLICY p_ptmprediction_update ON "PtmPrediction"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_ptmprediction_update ON public."PtmPrediction" IS 'PR-RLS-06 user-self-current-coach update: owner, the user, or the user''s current coach.';


--
-- Name: recent_auth_nonce p_recent_auth_nonce_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_recent_auth_nonce_service_role_all ON public.recent_auth_nonce TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_recent_auth_nonce_service_role_all ON recent_auth_nonce; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_recent_auth_nonce_service_role_all ON public.recent_auth_nonce IS 'Primitive A: service_role bypass (S1-DB-01). Table is reached only by the backend Prisma client.';


--
-- Name: ReconciliationSnapshot p_reconciliationsnapshot_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_reconciliationsnapshot_delete ON public."ReconciliationSnapshot" FOR DELETE USING (app.is_owner());


--
-- Name: POLICY p_reconciliationsnapshot_delete ON "ReconciliationSnapshot"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_reconciliationsnapshot_delete ON public."ReconciliationSnapshot" IS 'Reconciliation snapshots are server-managed; only service role / owner may delete them.';


--
-- Name: ReconciliationSnapshot p_reconciliationsnapshot_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_reconciliationsnapshot_insert ON public."ReconciliationSnapshot" FOR INSERT WITH CHECK (app.is_owner());


--
-- Name: POLICY p_reconciliationsnapshot_insert ON "ReconciliationSnapshot"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_reconciliationsnapshot_insert ON public."ReconciliationSnapshot" IS 'Reconciliation snapshots are server-produced (service role); only owner may insert otherwise.';


--
-- Name: ReconciliationSnapshot p_reconciliationsnapshot_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_reconciliationsnapshot_select ON public."ReconciliationSnapshot" FOR SELECT USING ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."ClientPurchase" cp
  WHERE ((cp.id = "ReconciliationSnapshot".purchase_id) AND ((cp.client_user_id = app.current_user_id()) OR (cp.coach_user_id = app.current_user_id())))))));


--
-- Name: POLICY p_reconciliationsnapshot_select ON "ReconciliationSnapshot"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_reconciliationsnapshot_select ON public."ReconciliationSnapshot" IS 'Read a reconciliation snapshot only as a party (client or coach) to the underlying purchase, or as an owner.';


--
-- Name: ReconciliationSnapshot p_reconciliationsnapshot_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_reconciliationsnapshot_service_role_all ON public."ReconciliationSnapshot" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_reconciliationsnapshot_service_role_all ON "ReconciliationSnapshot"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_reconciliationsnapshot_service_role_all ON public."ReconciliationSnapshot" IS 'Service role bypass: reconciliation snapshots are produced by the server-side reconciliation sweeper.';


--
-- Name: ReconciliationSnapshot p_reconciliationsnapshot_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_reconciliationsnapshot_update ON public."ReconciliationSnapshot" FOR UPDATE USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: POLICY p_reconciliationsnapshot_update ON "ReconciliationSnapshot"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_reconciliationsnapshot_update ON public."ReconciliationSnapshot" IS 'Reconciliation snapshots are server-managed; only service role / owner may update them.';


--
-- Name: RomanMessage p_romanmessage_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_romanmessage_insert ON public."RomanMessage" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()) AND (EXISTS ( SELECT 1
   FROM public."RomanSession" rs
  WHERE ((rs.id = "RomanMessage".session_id) AND (rs.user_id = app.current_user_id())))))));


--
-- Name: POLICY p_romanmessage_insert ON "RomanMessage"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_romanmessage_insert ON public."RomanMessage" IS 'Owner-self write with defence-in-depth: a user may INSERT a message only into their OWN session and only with user_id = self. Forging either the user_id or appending to a foreign session is rejected by the WITH CHECK.';


--
-- Name: RomanMessage p_romanmessage_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_romanmessage_select ON public."RomanMessage" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()) AND (EXISTS ( SELECT 1
   FROM public."RomanSession" rs
  WHERE ((rs.id = "RomanMessage".session_id) AND (rs.user_id = app.current_user_id())))))));


--
-- Name: POLICY p_romanmessage_select ON "RomanMessage"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_romanmessage_select ON public."RomanMessage" IS 'Owner-self read with defence-in-depth: BOTH the denormalised user_id AND the parent session.user_id must equal the caller. A message whose session belongs to another user is invisible even if its user_id column were forged. anon sees zero.';


--
-- Name: RomanMessage p_romanmessage_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_romanmessage_service_role_all ON public."RomanMessage" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_romanmessage_service_role_all ON "RomanMessage"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_romanmessage_service_role_all ON public."RomanMessage" IS 'Primitive A: service_role bypass for server-side jobs/migrations/seeds.';


--
-- Name: RomanSession p_romansession_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_romansession_insert ON public."RomanSession" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()))));


--
-- Name: POLICY p_romansession_insert ON "RomanSession"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_romansession_insert ON public."RomanSession" IS 'Owner-self write: a user may INSERT only sessions they own (user_id = self). A forged user_id is rejected by the WITH CHECK.';


--
-- Name: RomanSession p_romansession_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_romansession_select ON public."RomanSession" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()))));


--
-- Name: POLICY p_romansession_select ON "RomanSession"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_romansession_select ON public."RomanSession" IS 'Owner-self read: a user reads only their own Roman sessions (user_id = self); platform owner reads all. anon (NULL current_user_id) sees zero. Cross-user reads are denied (IDOR).';


--
-- Name: RomanSession p_romansession_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_romansession_service_role_all ON public."RomanSession" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_romansession_service_role_all ON "RomanSession"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_romansession_service_role_all ON public."RomanSession" IS 'Primitive A: service_role bypass for server-side jobs/migrations/seeds.';


--
-- Name: RomanSession p_romansession_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_romansession_update ON public."RomanSession" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id())))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()))));


--
-- Name: POLICY p_romansession_update ON "RomanSession"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_romansession_update ON public."RomanSession" IS 'Owner-self update: covers last_activity_at / message_count / quip+exclamation counters / soft-delete (deleted_at). CHECK prevents re-owning a row to another user_id.';


--
-- Name: RoutineExercise p_routineexercise_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_routineexercise_delete ON public."RoutineExercise" FOR DELETE USING ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."WorkoutRoutine" wr
  WHERE ((wr.id = "RoutineExercise".routine_id) AND (wr.creator_id = app.current_user_id()))))));


--
-- Name: POLICY p_routineexercise_delete ON "RoutineExercise"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_routineexercise_delete ON public."RoutineExercise" IS 'Child-via-routine delete: owner or parent routine creator may DELETE.';


--
-- Name: RoutineExercise p_routineexercise_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_routineexercise_insert ON public."RoutineExercise" FOR INSERT WITH CHECK ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."WorkoutRoutine" wr
  WHERE ((wr.id = "RoutineExercise".routine_id) AND (wr.creator_id = app.current_user_id()))))));


--
-- Name: POLICY p_routineexercise_insert ON "RoutineExercise"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_routineexercise_insert ON public."RoutineExercise" IS 'Child-via-routine write: owner or parent routine creator may INSERT.';


--
-- Name: RoutineExercise p_routineexercise_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_routineexercise_select ON public."RoutineExercise" FOR SELECT USING ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."WorkoutRoutine" wr
  WHERE ((wr.id = "RoutineExercise".routine_id) AND (wr.creator_id = app.current_user_id()))))));


--
-- Name: POLICY p_routineexercise_select ON "RoutineExercise"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_routineexercise_select ON public."RoutineExercise" IS 'Child-via-routine read: owner or the parent WorkoutRoutine creator may SELECT.';


--
-- Name: RoutineExercise p_routineexercise_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_routineexercise_service_role_all ON public."RoutineExercise" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_routineexercise_service_role_all ON "RoutineExercise"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_routineexercise_service_role_all ON public."RoutineExercise" IS 'Primitive A: service_role bypass for server-side jobs/migrations.';


--
-- Name: RoutineExercise p_routineexercise_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_routineexercise_update ON public."RoutineExercise" FOR UPDATE USING ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."WorkoutRoutine" wr
  WHERE ((wr.id = "RoutineExercise".routine_id) AND (wr.creator_id = app.current_user_id())))))) WITH CHECK ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."WorkoutRoutine" wr
  WHERE ((wr.id = "RoutineExercise".routine_id) AND (wr.creator_id = app.current_user_id()))))));


--
-- Name: POLICY p_routineexercise_update ON "RoutineExercise"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_routineexercise_update ON public."RoutineExercise" IS 'Child-via-routine update: owner or parent routine creator may UPDATE; CHECK reverifies the parent after change.';


--
-- Name: ScoutImportCompletion p_scout_import_completion_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_scout_import_completion_service_role_all ON public."ScoutImportCompletion" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_scout_import_completion_service_role_all ON "ScoutImportCompletion"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_scout_import_completion_service_role_all ON public."ScoutImportCompletion" IS 'Primitive A: service_role bypass. The completion ledger is written/read only by the server-side IMPORTER-E handler running as service_role.';


--
-- Name: ScoutImport p_scout_import_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_scout_import_service_role_all ON public."ScoutImport" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_scout_import_service_role_all ON "ScoutImport"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_scout_import_service_role_all ON public."ScoutImport" IS 'Primitive A: service_role bypass. The import lifecycle row is written/read only by the server-side IMPORTER-E handler running as service_role.';


--
-- Name: ScoutIngestEntity p_scout_ingest_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_scout_ingest_service_role_all ON public."ScoutIngestEntity" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_scout_ingest_service_role_all ON "ScoutIngestEntity"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_scout_ingest_service_role_all ON public."ScoutIngestEntity" IS 'service_role bypass: the crawl-envelope receiver writes/reads only via the server-side ingest engine running as service_role.';


--
-- Name: ScoutProgressSnapshot p_scout_progress_snapshot_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_scout_progress_snapshot_service_role_all ON public."ScoutProgressSnapshot" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_scout_progress_snapshot_service_role_all ON "ScoutProgressSnapshot"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_scout_progress_snapshot_service_role_all ON public."ScoutProgressSnapshot" IS 'Primitive A: service_role bypass. Progress snapshots are written/read only by the server-side IMPORTER-E handler running as service_role.';


--
-- Name: ScoutReconstructedEntity p_scout_reconstructed_entity_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_scout_reconstructed_entity_service_role_all ON public."ScoutReconstructedEntity" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_scout_reconstructed_entity_service_role_all ON "ScoutReconstructedEntity"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_scout_reconstructed_entity_service_role_all ON public."ScoutReconstructedEntity" IS 'service_role bypass: canonical reconstructed entities are written/read only via the server-side reconstruction engine running as service_role.';


--
-- Name: ScoutReconstructionLedger p_scout_reconstruction_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_scout_reconstruction_service_role_all ON public."ScoutReconstructionLedger" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_scout_reconstruction_service_role_all ON "ScoutReconstructionLedger"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_scout_reconstruction_service_role_all ON public."ScoutReconstructionLedger" IS 'service_role bypass: the reconciliation ledger is written/read only via the server-side reconstruction engine running as service_role.';


--
-- Name: SessionParticipant p_sessionparticipant_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_sessionparticipant_delete ON public."SessionParticipant" FOR DELETE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM public."CoachingSession" cs
  WHERE ((cs.id = "SessionParticipant".session_id) AND ((cs.coach_id = app.current_user_id()) OR app.is_current_coach_of(cs.client_id) OR ((cs.client_id = app.current_user_id()) AND ("SessionParticipant".user_id = cs.client_id)))))))));


--
-- Name: POLICY p_sessionparticipant_delete ON "SessionParticipant"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_sessionparticipant_delete ON public."SessionParticipant" IS 'PR-RLS-03 session-participant write (Primitive E child-via-parent): DELETE allowed when (a) caller is the session''s owning coach, OR (b) caller is the current coach of the session''s lead client, OR (c) caller is the session''s lead client removing only their own self-participation row (user_id = client_id). Owner/service_role bypass. The self-row predicate user_id = current_user_id() is intentionally absent — prevents IDOR-style deletion of participant rows on inaccessible sessions (Failure #2 / #5).';


--
-- Name: SessionParticipant p_sessionparticipant_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_sessionparticipant_insert ON public."SessionParticipant" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM public."CoachingSession" cs
  WHERE ((cs.id = "SessionParticipant".session_id) AND ((cs.coach_id = app.current_user_id()) OR app.is_current_coach_of(cs.client_id) OR ((cs.client_id = app.current_user_id()) AND ("SessionParticipant".user_id = cs.client_id)))))))));


--
-- Name: POLICY p_sessionparticipant_insert ON "SessionParticipant"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_sessionparticipant_insert ON public."SessionParticipant" IS 'PR-RLS-03 session-participant write (Primitive E child-via-parent): INSERT allowed when (a) caller is the session''s owning coach, OR (b) caller is the current coach of the session''s lead client, OR (c) caller is the session''s lead client adding themselves only (user_id = client_id). Owner/service_role bypass. Self-insert by arbitrary user_id is intentionally disallowed — prevents IDOR-style participation in inaccessible sessions (Failure #2 / #5).';


--
-- Name: SessionParticipant p_sessionparticipant_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_sessionparticipant_select ON public."SessionParticipant" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR (EXISTS ( SELECT 1
   FROM public."CoachingSession" cs
  WHERE ((cs.id = "SessionParticipant".session_id) AND ((cs.coach_id = app.current_user_id()) OR (cs.client_id = app.current_user_id()) OR app.is_current_coach_of(cs.client_id)))))))));


--
-- Name: POLICY p_sessionparticipant_select ON "SessionParticipant"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_sessionparticipant_select ON public."SessionParticipant" IS 'PR-RLS-03 session-participant primitive (Primitive C + E): owner, the participant themselves (user_id self-row), or anyone with access to the parent session (its coach, lead client, or the lead client''s current coach) may read the participant row. The self-row predicate is correct for SELECT only — never for writes.';


--
-- Name: SessionParticipant p_sessionparticipant_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_sessionparticipant_service_role_all ON public."SessionParticipant" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_sessionparticipant_service_role_all ON "SessionParticipant"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_sessionparticipant_service_role_all ON public."SessionParticipant" IS 'PR-RLS-03 Primitive A: service_role full bypass for server-side jobs and migrations.';


--
-- Name: SessionParticipant p_sessionparticipant_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_sessionparticipant_update ON public."SessionParticipant" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM public."CoachingSession" cs
  WHERE ((cs.id = "SessionParticipant".session_id) AND ((cs.coach_id = app.current_user_id()) OR app.is_current_coach_of(cs.client_id) OR ((cs.client_id = app.current_user_id()) AND ("SessionParticipant".user_id = cs.client_id))))))))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM public."CoachingSession" cs
  WHERE ((cs.id = "SessionParticipant".session_id) AND ((cs.coach_id = app.current_user_id()) OR app.is_current_coach_of(cs.client_id) OR ((cs.client_id = app.current_user_id()) AND ("SessionParticipant".user_id = cs.client_id)))))))));


--
-- Name: POLICY p_sessionparticipant_update ON "SessionParticipant"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_sessionparticipant_update ON public."SessionParticipant" IS 'PR-RLS-03 session-participant write (Primitive E child-via-parent): UPDATE allowed (USING + WITH CHECK) when (a) caller is the session''s owning coach, OR (b) caller is the current coach of the session''s lead client, OR (c) caller is the session''s lead client and the row is their own self-participation (user_id = client_id on both the existing and resulting row). Owner/service_role bypass. The self-row predicate user_id = current_user_id() is intentionally absent — prevents IDOR-style modification of participant rows on inaccessible sessions (Failure #2 / #5).';


--
-- Name: SessionType p_sessiontype_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_sessiontype_delete ON public."SessionType" FOR DELETE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))));


--
-- Name: POLICY p_sessiontype_delete ON "SessionType"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_sessiontype_delete ON public."SessionType" IS 'PR-RLS-03 Primitive C write: only the owner or the owning coach may delete the session type.';


--
-- Name: SessionType p_sessiontype_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_sessiontype_insert ON public."SessionType" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))));


--
-- Name: POLICY p_sessiontype_insert ON "SessionType"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_sessiontype_insert ON public."SessionType" IS 'PR-RLS-03 Primitive C write: only the owner or the owning coach (coach_id = caller) may create the session type. coach_id is the sole authorization column, so the row the caller writes is by definition their own — no parent object to circumvent, not the SessionParticipant IDOR class.';


--
-- Name: SessionType p_sessiontype_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_sessiontype_select ON public."SessionType" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))));


--
-- Name: POLICY p_sessiontype_select ON "SessionType"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_sessiontype_select ON public."SessionType" IS 'PR-RLS-03 Primitive C: owner or the owning coach may read the session type.';


--
-- Name: SessionType p_sessiontype_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_sessiontype_service_role_all ON public."SessionType" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_sessiontype_service_role_all ON "SessionType"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_sessiontype_service_role_all ON public."SessionType" IS 'PR-RLS-03 Primitive A: service_role full bypass for server-side jobs and migrations.';


--
-- Name: SessionType p_sessiontype_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_sessiontype_update ON public."SessionType" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id())))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id()))));


--
-- Name: POLICY p_sessiontype_update ON "SessionType"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_sessiontype_update ON public."SessionType" IS 'PR-RLS-03 Primitive C write (USING + WITH CHECK): only the owner or the owning coach may update the session type; WITH CHECK prevents reassigning coach_id to another coach.';


--
-- Name: StripeProcessedEvent p_stripeprocessedevent_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_stripeprocessedevent_delete ON public."StripeProcessedEvent" FOR DELETE USING (app.is_owner());


--
-- Name: POLICY p_stripeprocessedevent_delete ON "StripeProcessedEvent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_stripeprocessedevent_delete ON public."StripeProcessedEvent" IS 'Idempotency ledger rows are service-managed; only service role / owner may delete them.';


--
-- Name: StripeProcessedEvent p_stripeprocessedevent_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_stripeprocessedevent_insert ON public."StripeProcessedEvent" FOR INSERT WITH CHECK (app.is_owner());


--
-- Name: POLICY p_stripeprocessedevent_insert ON "StripeProcessedEvent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_stripeprocessedevent_insert ON public."StripeProcessedEvent" IS 'Idempotency ledger rows are written by webhook handlers (service role); only owner may insert otherwise.';


--
-- Name: StripeProcessedEvent p_stripeprocessedevent_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_stripeprocessedevent_select ON public."StripeProcessedEvent" FOR SELECT USING (app.is_owner());


--
-- Name: POLICY p_stripeprocessedevent_select ON "StripeProcessedEvent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_stripeprocessedevent_select ON public."StripeProcessedEvent" IS 'Webhook event IDs are not tenant data; only service role / owner may read them.';


--
-- Name: StripeProcessedEvent p_stripeprocessedevent_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_stripeprocessedevent_service_role_all ON public."StripeProcessedEvent" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_stripeprocessedevent_service_role_all ON "StripeProcessedEvent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_stripeprocessedevent_service_role_all ON public."StripeProcessedEvent" IS 'Service role bypass: the webhook idempotency ledger is written and read only by webhook handlers.';


--
-- Name: StripeProcessedEvent p_stripeprocessedevent_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_stripeprocessedevent_update ON public."StripeProcessedEvent" FOR UPDATE USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: POLICY p_stripeprocessedevent_update ON "StripeProcessedEvent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_stripeprocessedevent_update ON public."StripeProcessedEvent" IS 'Idempotency ledger rows are service-managed; only service role / owner may update them.';


--
-- Name: TeamAuditEvent p_teamauditevent_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_teamauditevent_delete ON public."TeamAuditEvent" FOR DELETE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((head_coach_id = app.current_user_id()) OR (actor_user_id = app.current_user_id()) OR app.is_current_coach_of(target_client_id)))));


--
-- Name: POLICY p_teamauditevent_delete ON "TeamAuditEvent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_teamauditevent_delete ON public."TeamAuditEvent" IS 'PR-RLS-02: owner, the head coach, the acting user, or the target client''s current coach may delete.';


--
-- Name: TeamAuditEvent p_teamauditevent_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_teamauditevent_insert ON public."TeamAuditEvent" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((head_coach_id = app.current_user_id()) OR (actor_user_id = app.current_user_id()) OR app.is_current_coach_of(target_client_id)))));


--
-- Name: POLICY p_teamauditevent_insert ON "TeamAuditEvent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_teamauditevent_insert ON public."TeamAuditEvent" IS 'PR-RLS-02: owner, the head coach, the acting user, or the target client''s current coach may insert.';


--
-- Name: TeamAuditEvent p_teamauditevent_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_teamauditevent_select ON public."TeamAuditEvent" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((head_coach_id = app.current_user_id()) OR (actor_user_id = app.current_user_id()) OR app.is_current_coach_of(target_client_id)))));


--
-- Name: POLICY p_teamauditevent_select ON "TeamAuditEvent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_teamauditevent_select ON public."TeamAuditEvent" IS 'PR-RLS-02: owner, the head coach, the acting user, or the target client''s current coach may read.';


--
-- Name: TeamAuditEvent p_teamauditevent_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_teamauditevent_service_role_all ON public."TeamAuditEvent" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_teamauditevent_service_role_all ON "TeamAuditEvent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_teamauditevent_service_role_all ON public."TeamAuditEvent" IS 'PR-RLS-02: service_role bypass for server-side jobs and migrations.';


--
-- Name: TeamAuditEvent p_teamauditevent_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_teamauditevent_update ON public."TeamAuditEvent" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((head_coach_id = app.current_user_id()) OR (actor_user_id = app.current_user_id()) OR app.is_current_coach_of(target_client_id))))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((head_coach_id = app.current_user_id()) OR (actor_user_id = app.current_user_id()) OR app.is_current_coach_of(target_client_id)))));


--
-- Name: POLICY p_teamauditevent_update ON "TeamAuditEvent"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_teamauditevent_update ON public."TeamAuditEvent" IS 'PR-RLS-02: owner, the head coach, the acting user, or the target client''s current coach may update.';


--
-- Name: water_logs p_water_logs_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_water_logs_delete ON public.water_logs FOR DELETE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()))));


--
-- Name: POLICY p_water_logs_delete ON water_logs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_water_logs_delete ON public.water_logs IS 'PR-RLS-05 owner-only writes: only the owner operator or the logging user may delete their own hydration log. Coaches have SELECT-only access and may NOT delete client hydration logs.';


--
-- Name: water_logs p_water_logs_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_water_logs_insert ON public.water_logs FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()))));


--
-- Name: POLICY p_water_logs_insert ON water_logs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_water_logs_insert ON public.water_logs IS 'PR-RLS-05 owner-only writes: only the owner operator or the logging user may insert their own hydration log. Coaches have SELECT-only access to client hydration logs and may NOT write them.';


--
-- Name: water_logs p_water_logs_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_water_logs_select ON public.water_logs FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND ((user_id = app.current_user_id()) OR app.is_current_coach_of(user_id)))));


--
-- Name: POLICY p_water_logs_select ON water_logs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_water_logs_select ON public.water_logs IS 'PR-RLS-05 user-self-current-coach-read: owner, the logging user, or that user''s current coach may read hydration logs.';


--
-- Name: water_logs p_water_logs_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_water_logs_service_role_all ON public.water_logs TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_water_logs_service_role_all ON water_logs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_water_logs_service_role_all ON public.water_logs IS 'PR-RLS-05 Primitive A: service_role bypass for server-side jobs and migrations.';


--
-- Name: water_logs p_water_logs_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_water_logs_update ON public.water_logs FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id())))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()))));


--
-- Name: POLICY p_water_logs_update ON water_logs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_water_logs_update ON public.water_logs IS 'PR-RLS-05 owner-only writes: only the owner operator or the logging user may update their own hydration log; post-image must remain under that user_id. Coaches have SELECT-only access and may NOT update client hydration logs.';


--
-- Name: WorkoutPlanRevision p_workoutplanrevision_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_workoutplanrevision_delete ON public."WorkoutPlanRevision" FOR DELETE USING ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."WorkoutPlan" wp
  WHERE ((wp.id = "WorkoutPlanRevision".workout_plan_id) AND ((wp.coach_id = app.current_user_id()) OR app.is_subcoach_on_coach_team(wp.coach_id)))))));


--
-- Name: POLICY p_workoutplanrevision_delete ON "WorkoutPlanRevision"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_workoutplanrevision_delete ON public."WorkoutPlanRevision" IS 'Child-via-plan delete: owner admin or parent-plan coach/sub-coach may DELETE.';


--
-- Name: WorkoutPlanRevision p_workoutplanrevision_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_workoutplanrevision_insert ON public."WorkoutPlanRevision" FOR INSERT WITH CHECK ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."WorkoutPlan" wp
  WHERE ((wp.id = "WorkoutPlanRevision".workout_plan_id) AND ((wp.coach_id = app.current_user_id()) OR app.is_subcoach_on_coach_team(wp.coach_id)))))));


--
-- Name: POLICY p_workoutplanrevision_insert ON "WorkoutPlanRevision"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_workoutplanrevision_insert ON public."WorkoutPlanRevision" IS 'Child-via-plan write: owner admin, the parent plan''s coach, or a sub-coach on that coach''s team may INSERT a revision.';


--
-- Name: WorkoutPlanRevision p_workoutplanrevision_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_workoutplanrevision_select ON public."WorkoutPlanRevision" FOR SELECT USING ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."WorkoutPlan" wp
  WHERE ((wp.id = "WorkoutPlanRevision".workout_plan_id) AND ((wp.coach_id = app.current_user_id()) OR app.is_subcoach_on_coach_team(wp.coach_id)))))));


--
-- Name: POLICY p_workoutplanrevision_select ON "WorkoutPlanRevision"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_workoutplanrevision_select ON public."WorkoutPlanRevision" IS 'Child-via-plan read: owner admin, the parent plan''s coach (coach_id), or a sub-coach on that coach''s team may SELECT plan history.';


--
-- Name: WorkoutPlanRevision p_workoutplanrevision_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_workoutplanrevision_service_role_all ON public."WorkoutPlanRevision" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_workoutplanrevision_service_role_all ON "WorkoutPlanRevision"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_workoutplanrevision_service_role_all ON public."WorkoutPlanRevision" IS 'Primitive A: service_role bypass for server-side jobs/migrations.';


--
-- Name: WorkoutPlanRevision p_workoutplanrevision_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_workoutplanrevision_update ON public."WorkoutPlanRevision" FOR UPDATE USING ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."WorkoutPlan" wp
  WHERE ((wp.id = "WorkoutPlanRevision".workout_plan_id) AND ((wp.coach_id = app.current_user_id()) OR app.is_subcoach_on_coach_team(wp.coach_id))))))) WITH CHECK ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."WorkoutPlan" wp
  WHERE ((wp.id = "WorkoutPlanRevision".workout_plan_id) AND ((wp.coach_id = app.current_user_id()) OR app.is_subcoach_on_coach_team(wp.coach_id)))))));


--
-- Name: POLICY p_workoutplanrevision_update ON "WorkoutPlanRevision"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_workoutplanrevision_update ON public."WorkoutPlanRevision" IS 'Child-via-plan update: owner admin or parent-plan coach/sub-coach may UPDATE; CHECK reverifies the parent plan (revisions are append-only in practice).';


--
-- Name: WorkoutProgram p_workoutprogram_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_workoutprogram_delete ON public."WorkoutProgram" FOR DELETE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (owner_user_id = app.current_user_id()))));


--
-- Name: POLICY p_workoutprogram_delete ON "WorkoutProgram"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_workoutprogram_delete ON public."WorkoutProgram" IS 'Owner-self delete: owner admin or the row owner may DELETE.';


--
-- Name: WorkoutProgram p_workoutprogram_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_workoutprogram_insert ON public."WorkoutProgram" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (owner_user_id = app.current_user_id()))));


--
-- Name: POLICY p_workoutprogram_insert ON "WorkoutProgram"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_workoutprogram_insert ON public."WorkoutProgram" IS 'Owner-self write: only owner admin or the row''s own owner_user_id may INSERT. Forking writes a new owner-stamped row so the fork passes.';


--
-- Name: WorkoutProgram p_workoutprogram_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_workoutprogram_select ON public."WorkoutProgram" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (owner_user_id = app.current_user_id())) OR ((app.current_user_id() IS NOT NULL) AND (visibility = 'tenant_shared'::text) AND (app.is_current_coach_of(coach_id) OR app.is_subcoach_of(coach_id) OR (EXISTS ( SELECT 1
   FROM public."User" u
  WHERE ((u.id = app.current_user_id()) AND ((u.id = "WorkoutProgram".coach_id) OR (u.coach_id = "WorkoutProgram".coach_id)))))))));


--
-- Name: POLICY p_workoutprogram_select ON "WorkoutProgram"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_workoutprogram_select ON public."WorkoutProgram" IS 'Owner-self read with tenant-shared overlay: owner admin, the row owner (owner_user_id), or — for tenant_shared rows — a head coach / sub-coach in the same coach_id tenant may SELECT.';


--
-- Name: WorkoutProgram p_workoutprogram_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_workoutprogram_service_role_all ON public."WorkoutProgram" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_workoutprogram_service_role_all ON "WorkoutProgram"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_workoutprogram_service_role_all ON public."WorkoutProgram" IS 'Primitive A: service_role bypass for server-side jobs/migrations.';


--
-- Name: WorkoutProgram p_workoutprogram_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_workoutprogram_update ON public."WorkoutProgram" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (owner_user_id = app.current_user_id())))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (owner_user_id = app.current_user_id()))));


--
-- Name: POLICY p_workoutprogram_update ON "WorkoutProgram"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_workoutprogram_update ON public."WorkoutProgram" IS 'Owner-self update: owner admin or the row owner may UPDATE; CHECK prevents re-owning the row to another owner_user_id.';


--
-- Name: WorkoutProgramRevision p_workoutprogramrevision_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_workoutprogramrevision_delete ON public."WorkoutProgramRevision" FOR DELETE USING ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."WorkoutProgram" wprg
  WHERE ((wprg.id = "WorkoutProgramRevision".program_id) AND (wprg.owner_user_id = app.current_user_id()))))));


--
-- Name: POLICY p_workoutprogramrevision_delete ON "WorkoutProgramRevision"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_workoutprogramrevision_delete ON public."WorkoutProgramRevision" IS 'Child-via-program delete: owner admin or parent program owner may DELETE.';


--
-- Name: WorkoutProgramRevision p_workoutprogramrevision_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_workoutprogramrevision_insert ON public."WorkoutProgramRevision" FOR INSERT WITH CHECK ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."WorkoutProgram" wprg
  WHERE ((wprg.id = "WorkoutProgramRevision".program_id) AND (wprg.owner_user_id = app.current_user_id()))))));


--
-- Name: POLICY p_workoutprogramrevision_insert ON "WorkoutProgramRevision"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_workoutprogramrevision_insert ON public."WorkoutProgramRevision" IS 'Child-via-program write: owner admin or the parent program owner may INSERT a structure revision.';


--
-- Name: WorkoutProgramRevision p_workoutprogramrevision_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_workoutprogramrevision_select ON public."WorkoutProgramRevision" FOR SELECT USING ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."WorkoutProgram" wprg
  WHERE ((wprg.id = "WorkoutProgramRevision".program_id) AND ((wprg.owner_user_id = app.current_user_id()) OR ((wprg.visibility = 'tenant_shared'::text) AND (app.is_current_coach_of(wprg.coach_id) OR app.is_subcoach_of(wprg.coach_id) OR app.is_subcoach_on_coach_team(wprg.coach_id)))))))));


--
-- Name: POLICY p_workoutprogramrevision_select ON "WorkoutProgramRevision"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_workoutprogramrevision_select ON public."WorkoutProgramRevision" IS 'Child-via-program read: owner admin, the parent program owner, or a same-tenant coach/sub-coach for tenant_shared programs may SELECT structure history.';


--
-- Name: WorkoutProgramRevision p_workoutprogramrevision_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_workoutprogramrevision_service_role_all ON public."WorkoutProgramRevision" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_workoutprogramrevision_service_role_all ON "WorkoutProgramRevision"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_workoutprogramrevision_service_role_all ON public."WorkoutProgramRevision" IS 'Primitive A: service_role bypass for server-side jobs/migrations.';


--
-- Name: WorkoutProgramRevision p_workoutprogramrevision_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_workoutprogramrevision_update ON public."WorkoutProgramRevision" FOR UPDATE USING ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."WorkoutProgram" wprg
  WHERE ((wprg.id = "WorkoutProgramRevision".program_id) AND (wprg.owner_user_id = app.current_user_id())))))) WITH CHECK ((app.is_owner() OR (EXISTS ( SELECT 1
   FROM public."WorkoutProgram" wprg
  WHERE ((wprg.id = "WorkoutProgramRevision".program_id) AND (wprg.owner_user_id = app.current_user_id()))))));


--
-- Name: POLICY p_workoutprogramrevision_update ON "WorkoutProgramRevision"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_workoutprogramrevision_update ON public."WorkoutProgramRevision" IS 'Child-via-program update: owner admin or parent program owner may UPDATE; CHECK reverifies the parent program.';


--
-- Name: WorkoutRoutine p_workoutroutine_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_workoutroutine_delete ON public."WorkoutRoutine" FOR DELETE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (creator_id = app.current_user_id()))));


--
-- Name: POLICY p_workoutroutine_delete ON "WorkoutRoutine"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_workoutroutine_delete ON public."WorkoutRoutine" IS 'Creator-self delete: owner or creator may DELETE.';


--
-- Name: WorkoutRoutine p_workoutroutine_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_workoutroutine_insert ON public."WorkoutRoutine" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (creator_id = app.current_user_id()))));


--
-- Name: POLICY p_workoutroutine_insert ON "WorkoutRoutine"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_workoutroutine_insert ON public."WorkoutRoutine" IS 'Creator-self write: only owner or the row''s own creator_id may INSERT.';


--
-- Name: WorkoutRoutine p_workoutroutine_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_workoutroutine_select ON public."WorkoutRoutine" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (creator_id = app.current_user_id()))));


--
-- Name: POLICY p_workoutroutine_select ON "WorkoutRoutine"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_workoutroutine_select ON public."WorkoutRoutine" IS 'Creator-self read: owner admin or the routine creator (creator_id) may SELECT.';


--
-- Name: WorkoutRoutine p_workoutroutine_service_role_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_workoutroutine_service_role_all ON public."WorkoutRoutine" TO service_role USING (true) WITH CHECK (true);


--
-- Name: POLICY p_workoutroutine_service_role_all ON "WorkoutRoutine"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_workoutroutine_service_role_all ON public."WorkoutRoutine" IS 'Primitive A: service_role bypass for server-side jobs/migrations.';


--
-- Name: WorkoutRoutine p_workoutroutine_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_workoutroutine_update ON public."WorkoutRoutine" FOR UPDATE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (creator_id = app.current_user_id())))) WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (creator_id = app.current_user_id()))));


--
-- Name: POLICY p_workoutroutine_update ON "WorkoutRoutine"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON POLICY p_workoutroutine_update ON public."WorkoutRoutine" IS 'Creator-self update: owner or creator may UPDATE; CHECK prevents re-owning to another creator_id.';


--
-- Name: PaymentFailure payment_failure_coach_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY payment_failure_coach_select ON public."PaymentFailure" FOR SELECT USING (((app.current_user_id() IS NOT NULL) AND (coach_id = app.current_user_id())));


--
-- Name: PaymentFailure payment_failure_owner_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY payment_failure_owner_all ON public."PaymentFailure" USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: recent_auth_nonce; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.recent_auth_nonce ENABLE ROW LEVEL SECURITY;

--
-- Name: secret_rotation_log; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.secret_rotation_log ENABLE ROW LEVEL SECURITY;

--
-- Name: secret_rotation_log secret_rotation_log_owner_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY secret_rotation_log_owner_all ON public.secret_rotation_log USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: SplitLedgerEntry split_ledger_entry_owner_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY split_ledger_entry_owner_all ON public."SplitLedgerEntry" USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: SplitLedgerEntry split_ledger_entry_payee_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY split_ledger_entry_payee_select ON public."SplitLedgerEntry" FOR SELECT USING (((app.current_user_id() IS NOT NULL) AND (payee_user_id = app.current_user_id())));


--
-- Name: SubCoachInvite subcoach_invite_accepter_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY subcoach_invite_accepter_select ON public."SubCoachInvite" FOR SELECT USING (((app.current_user_id() IS NOT NULL) AND (accepted_by_user_id = app.current_user_id())));


--
-- Name: SubCoachInvite subcoach_invite_head_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY subcoach_invite_head_insert ON public."SubCoachInvite" FOR INSERT WITH CHECK (((app.current_user_id() IS NOT NULL) AND (head_coach_id = app.current_user_id()) AND (NOT (EXISTS ( SELECT 1
   FROM public."TeamSubCoachAssignment" active_sub
  WHERE ((active_sub.sub_coach_id = app.current_user_id()) AND (active_sub.archived_at IS NULL)))))));


--
-- Name: SubCoachInvite subcoach_invite_head_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY subcoach_invite_head_update ON public."SubCoachInvite" FOR UPDATE USING (((app.current_user_id() IS NOT NULL) AND (head_coach_id = app.current_user_id()) AND (NOT (EXISTS ( SELECT 1
   FROM public."TeamSubCoachAssignment" active_sub
  WHERE ((active_sub.sub_coach_id = app.current_user_id()) AND (active_sub.archived_at IS NULL))))))) WITH CHECK (((app.current_user_id() IS NOT NULL) AND (head_coach_id = app.current_user_id())));


--
-- Name: SubCoachInvite subcoach_invite_issuer_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY subcoach_invite_issuer_select ON public."SubCoachInvite" FOR SELECT USING (((app.current_user_id() IS NOT NULL) AND (head_coach_id = app.current_user_id())));


--
-- Name: SubCoachInvite subcoach_invite_owner_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY subcoach_invite_owner_all ON public."SubCoachInvite" USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: TeamSubCoachAssignment team_subcoach_assignment_head_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY team_subcoach_assignment_head_update ON public."TeamSubCoachAssignment" FOR UPDATE USING (((app.current_user_id() IS NOT NULL) AND (head_coach_id = app.current_user_id()) AND (NOT (EXISTS ( SELECT 1
   FROM public."TeamSubCoachAssignment" active_sub
  WHERE ((active_sub.sub_coach_id = app.current_user_id()) AND (active_sub.archived_at IS NULL))))))) WITH CHECK (((app.current_user_id() IS NOT NULL) AND (head_coach_id = app.current_user_id())));


--
-- Name: TeamSubCoachAssignment team_subcoach_assignment_head_write; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY team_subcoach_assignment_head_write ON public."TeamSubCoachAssignment" FOR INSERT WITH CHECK (((app.current_user_id() IS NOT NULL) AND (head_coach_id = app.current_user_id()) AND (NOT (EXISTS ( SELECT 1
   FROM public."TeamSubCoachAssignment" active_sub
  WHERE ((active_sub.sub_coach_id = app.current_user_id()) AND (active_sub.archived_at IS NULL)))))));


--
-- Name: TeamSubCoachAssignment team_subcoach_assignment_owner_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY team_subcoach_assignment_owner_all ON public."TeamSubCoachAssignment" USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: TeamSubCoachAssignment team_subcoach_assignment_participant_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY team_subcoach_assignment_participant_select ON public."TeamSubCoachAssignment" FOR SELECT USING (((app.current_user_id() IS NOT NULL) AND ((head_coach_id = app.current_user_id()) OR (sub_coach_id = app.current_user_id()))));


--
-- Name: UserBlock user_block_delete_blocker_or_owner; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY user_block_delete_blocker_or_owner ON public."UserBlock" FOR DELETE USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (blocker_id = app.current_user_id()))));


--
-- Name: UserBlock user_block_insert_blocker_or_owner; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY user_block_insert_blocker_or_owner ON public."UserBlock" FOR INSERT WITH CHECK ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (blocker_id = app.current_user_id()))));


--
-- Name: UserBlock user_block_select_blocker_or_owner; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY user_block_select_blocker_or_owner ON public."UserBlock" FOR SELECT USING ((app.is_owner() OR ((app.current_user_id() IS NOT NULL) AND (blocker_id = app.current_user_id()))));


--
-- Name: UserProfile user_profile_owner_access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY user_profile_owner_access ON public."UserProfile" USING ((user_id = app.current_user_id())) WITH CHECK ((user_id = app.current_user_id()));


--
-- Name: User user_self_access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY user_self_access ON public."User" USING ((id = app.current_user_id())) WITH CHECK ((id = app.current_user_id()));


--
-- Name: water_logs; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.water_logs ENABLE ROW LEVEL SECURITY;

--
-- Name: WearableConnection wc_client_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY wc_client_all ON public."WearableConnection" USING (((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()))) WITH CHECK (((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id())));


--
-- Name: WearableConnection wc_coach_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY wc_coach_select ON public."WearableConnection" FOR SELECT USING (app.is_current_coach_of(user_id));


--
-- Name: WearableConnection wc_owner_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY wc_owner_all ON public."WearableConnection" USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: WeightLog weight_log_owner_access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY weight_log_owner_access ON public."WeightLog" USING ((user_id = app.current_user_id())) WITH CHECK ((user_id = app.current_user_id()));


--
-- Name: WearableInsightCache wic_client_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY wic_client_select ON public."WearableInsightCache" FOR SELECT USING (((app.current_user_id() IS NOT NULL) AND (app.current_user_id() = user_id) AND (side = 'client'::text)));


--
-- Name: WearableInsightCache wic_coach_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY wic_coach_select ON public."WearableInsightCache" FOR SELECT USING (app.is_current_coach_of(user_id));


--
-- Name: WearableInsightCache wic_owner_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY wic_owner_all ON public."WearableInsightCache" USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: WearableMetricDef wmd_public_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY wmd_public_select ON public."WearableMetricDef" FOR SELECT USING (true);


--
-- Name: WorkoutSession workout_session_owner_access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY workout_session_owner_access ON public."WorkoutSession" USING ((user_id = app.current_user_id())) WITH CHECK ((user_id = app.current_user_id()));


--
-- Name: WearableSample ws_client_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY ws_client_all ON public."WearableSample" USING (((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()))) WITH CHECK (((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id())));


--
-- Name: WearableSample ws_coach_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY ws_coach_select ON public."WearableSample" FOR SELECT USING (app.is_current_coach_of(user_id));


--
-- Name: WearableSample ws_owner_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY ws_owner_all ON public."WearableSample" USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- Name: WearableUserMetricPreference wump_client_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY wump_client_all ON public."WearableUserMetricPreference" USING (((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id()))) WITH CHECK (((app.current_user_id() IS NOT NULL) AND (user_id = app.current_user_id())));


--
-- Name: WearableUserMetricPreference wump_coach_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY wump_coach_select ON public."WearableUserMetricPreference" FOR SELECT USING (app.is_current_coach_of(user_id));


--
-- Name: WearableUserMetricPreference wump_owner_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY wump_owner_all ON public."WearableUserMetricPreference" USING (app.is_owner()) WITH CHECK (app.is_owner());


--
-- PostgreSQL database dump complete
--


