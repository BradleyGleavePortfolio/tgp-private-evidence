const fs = require("fs");
const path = require("path");
const {
  Document, Packer, Paragraph, TextRun, HeadingLevel, Footer, PageNumber,
  FootnoteReferenceRun, ExternalHyperlink, PageBreak
} = require("docx");
const out = __dirname;
const root = "/home/user/workspace/";
const source = root + "initialization/recovered/s1-r4-56fb/";
const checkpoint = root + "tgp-private-evidence/2026-09-21/remediation/s1-r4/checkpoint2-56fb0d22/";
const migration = source + "prisma/migrations/20261224000000_rls_close_public_exposure/";
const footnotes = {};
let seq = 0;
function p(text, refs=[]) {
  const children=[new TextRun(text)];
  for (const [label, filename] of refs) {
    const n=++seq;
    const url="file://"+filename;
    footnotes[n]={children:[new Paragraph({
      spacing:{after:30},
      children:[new TextRun({text:label+" — ",size:18}),
        new ExternalHyperlink({link:url,children:[new TextRun({text:url,size:18,style:"Hyperlink"})]})]
    })]};
    children.push(new FootnoteReferenceRun(n));
  }
  return new Paragraph({spacing:{after:115,line:265},children});
}
const h=(s)=>new Paragraph({heading:HeadingLevel.HEADING_1,children:[new TextRun(s)]});
const sub=(s)=>new Paragraph({heading:HeadingLevel.HEADING_2,children:[new TextRun(s)]});
const br=()=>new Paragraph({children:[new PageBreak()]});
const body=[
  new Paragraph({children:[new TextRun({text:"S1 R4 · Independent review A",bold:true,size:36})],spacing:{after:140}}),
  p("Frozen revision 1 · S1-R4-SOURCE-FOLLOWUP · T4 · Private evidence"),
  h("SOURCE assessment"),
  p("ACCEPTED FOR THE NARROW SOURCE FOLLOW-UP. Effective TRUNCATE omission is source-fixed; the quoted-diagnostic defect and associated standalone pre-seed ordering observation are source-closed. No new material source blocker was found in this dispatched scope. This is not final changed-candidate closure or a generic CLEAN.",[
    ["Exact identity, comparisons, hashes and archived observations",out+"/STATIC_EVIDENCE.json"]
  ]),
  p("DYNAMIC ATTESTATION PENDING — NOT SIGNED. Real PG17.6 TRUNCATE discriminator and final combined S1/S2 proof remain outstanding. No merge, release, activation, deployed-privilege or live-role clearance is given."),
  sub("Exact candidate and independence"),
  p("Repository: growth-project-backend. Head: 56fb0d227558c86fe824f9fb1bc15e222411504f. Tree: 79ebf1750ca0e49e511666bafcfaf967f0ba39cc. Public base: c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7. Repair ancestry: b7d7fe59 → 41f4d6a9 → 56fb0d22. Source was clean before and after inspection; author and committer on both repair commits match the required Bradley identity.",[
    ["Read-only Git observations",out+"/STATIC_EVIDENCE.json"]
  ]),
  p("I did not build this candidate or read/request the current peer B report or conclusions. I read A’s prior S1 R3 lens first, then the completed A coupled review only as relevant history. Requested model: inherited parent model. Concrete runtime model/version and reasoning setting are not exposed; no identity or settings are inferred."),
  p("Read G01–G22, current private root state and companion, synchronized dispatch register, the entire S1/S3 brief, both execution/routing doctrines and the cited S1 checkpoint. T4 follows privilege/RLS and destructive-fixture/recovery consequences; T1 privilege boundedness fails. The owner’s Fable 5 builder amendment is preserved, not treated as this reviewer’s identity.",[
    ["Mandate and bounded acceptance criteria",root+"execution/S1_S3_CONTINUATION_BRIEF.md"]
  ]),
  p("Performed only source/evidence reads, Git object/diff inspection and file-hash/log-count checks. No candidate edits, test or syntax-test reruns, installation, DB connection, fixture lifecycle, remote call or publication occurred. Audit-created outputs are confined to reviewer A’s assigned directory; platform skill materialization is not a source edit."),
  br(),
  h("Stable finding dispositions"),
  sub("S1-R3-A-01 — source fixed; behavior pending"),
  p("Verifier lines 122–151 add TRUNCATE to has_table_privilege for anon and authenticated on the existing relation set. This is an effective-rights query rather than a direct-ACL filter: intended coverage includes PUBLIC and inherited effective membership rights. service_role’s required CRUD set is unchanged at 155–164; REFERENCES/TRIGGER remain expressly excluded. This does not inventory arbitrary SET ROLE reachability, and no membership-edge dynamic control is present.",[
    ["Verifier, lines 122–164 and 225–234",migration+"verify.sql"]
  ]),
  p("The planned discriminator is meaningful: pinned b7 predecessor succeeds on protected state and falsely succeeds after isolated anon/PUBLIC TRUNCATE drift; current verifier must fail with the specified exposure count and quoted role/privilege messages. C1 and C3 exercise the current psql and real Prisma routes; C2 exercises psql. Predecessor is psql-only. Rollback-only anon TRUNCATE probes distinguish denial from destructive capability, then verify preserved rows and restored positive state.",[
    ["Shared controls, lines 70–161",source+"test/db/_support/s1-truncate-controls.sh"]
  ]),
  sub("S1-R4-A-01 — source closed; message proof applicable"),
  p("Quoted fixed-string needles now agree with format('%I: %s still holds %s') and with both actual B1 diagnostic fragments. C1/C2 retain exposure counts and reject the other role; C3 requires both quoted-role problems. The original B1 log’s hash is 948249c7b4f3597ac3c225e45a7f9d6aa51b07f63f4ca4fb1bded933a10f8ca7; both fragments occur verbatim at line 40. No diagnostic condition was weakened.",[
    ["Original B1 C3 diagnostic, line 40",root+"tgp-private-evidence/2026-09-21/remediation/s2-composition/b1-failed/20260922T000811Z/harness/C3.release.log"]
  ]),
  p("Associated pre-seed observation: standalone checks at 95–111 now precede PRECOND_FAIL at 117 and refusal at 119–120. INSERT and shared controls exist only in the success branch at 121–130; SEEDED_BY_US stays zero on refusal, preventing cleanup DELETE at 134–137. Thus accumulated precondition failure issues no INSERT/GRANT/REVOKE/DELETE. Final verifier is read-only. This is source reasoning, not newly executed refusal proof.",[
    ["Standalone discriminator, lines 95–142",source+"test/db/s1-r4-truncate-discriminator.sh"]
  ]),
  p("Scope caveat: shared C0 seeded/FK/privilege checks are accumulating assertions after entry, not a universal pre-write refusal gate for every fixture defect. The closure above concerns the concrete prior standalone precondition-before-seed bug; it must not be advertised as a general-purpose safe runner."),
  br(),
  h("Retained evidence applicability"),
  p("Checkpoint manifests independently match 22/22 and 23/23 entries without self-inclusion. Restored current verifier, controls, discriminator and message spec match archived copies. The frozen-head offline log records clean56fb/tree79eb, 24 PASS / 0 FAIL, exit0, with current controls/verifier hashes. The earlier 24/0 log is explicitly41f4 plus three dirty entries, not a clean predecessor run.",[
    ["Hash and input-attribution record",out+"/STATIC_EVIDENCE.json"]
  ]),
  p("The 17 PASS / 7 FAIL, exit1 negative log is a modified-controls copy with head=n/a and controls hash e60f9523…a6d95, not the pristine41f4 script. Mutant bytes are not separately retained in this checkpoint; their attribution rests on the preserved log, not an independently recovered mutant. The evidence discriminates quoted-message predicates only; it proves neither DB behavior nor pre-seed refusal. Both original B1 fragments were independently checked against the real log.",[
    ["Preserved negative-control observation",checkpoint+"runs/offline-20260922T002622Z/message-spec-NEGATIVE-unquoted-needles.log"]
  ]),
  p("Migration/down/guard/bootstrap/package inputs remain equal to b7; verifier changed, and the full harness gains §4b. The old89/0 PG17.6/Prisma6.19.3 run remains attributable historical evidence for unchanged bounded migration, late-failure atomicity, same-session RESET/ROLLBACK and recovery behavior—not a56fb run or proof of the new grant/probe/restore sequence. B1’s real diagnostic is useful, but its aggregate failed and the discriminator was NOTRUN.",[
    ["Historical exact-b7 proof",root+"tgp-private-evidence/2026-09-20/remediation/s1-r3/revision-1/proof-run-04-head-b7d7fe5.log"]
  ]),
  sub("Guard and recovery remain conditional"),
  p("S1-R2-A-01/-02 and S1-A-03 retain their prior bounded closures. Unchanged guard checks loopback, port/name/confirmation, bounded server metadata, fixed marker/root and role flags before mutation. It identifies a fixture family, not exclusive current ownership. Caller lock assertion and alternate lock path are not independent authorization; no signal-time SQL grant restoration is provided. Fresh parent authorization, actual canonical-lock ownership and verified child cleanup/disposable lifecycle are required.",[
    ["Guard, lines 61–187",source+"test/db/_support/s1-target-guard.sh"]
  ]),
  p("S1-A-01/-02/-05 show no relevant source regression. Down deliberately restores exposure, not containment. S1 transactional direct reapply remains only the proven S1 recovery path; direct revokes do not clear PUBLIC or other-role inherited grants, so new effective-grant drift needs owner-authorized correction and re-verification. No backup/PITR or generic migration recovery claim follows.",[
    ["Migration, lines 144, 200 and 317–338",migration+"migration.sql"]
  ]),
  br(),
  h("DYNAMIC ATTESTATION PENDING"),
  p("S1-R3-A-E01 remains open. Smallest next evidence: one parent-authorized, serialized exact-successor composition packet, not duplicate reviewer DB runs. This report grants no execution slot."),
  sub("Required before additive final applicability attestation"),
  p("1. Freeze the integrated head/tree and relevant S1 hashes; preserve b7 history and pinned predecessor hash. Bind dependency/toolchain, fixture, wrapper and cleanup identities. Repair/authorize the runner separately; do not inherit a historical slot."),
  p("2. Supply real PG17.6 164-parent replay plus candidate165 and actual release-entry-point positive, missing-verifier refusal, catalog drift, late migration failure and recovery exits. Preserve failed attempts; no ledger-only baseline or aggregate-pass substitution."),
  p("3. Supply the targeted protected/direct-anon/direct-authenticated/PUBLIC-only TRUNCATE sequence with predecessor false-green, current classified failures, real Prisma C1/C3 exits, restored positives and rollback-only preserved-row evidence. Source-predicted totals47/48 or full131 are expectations, not observations."),
  p("4. Preserve child exits, no surviving mutation workers, fixture stop/cleanup and canonical lock ownership through completion. Review final relevant bytes and actual proof in an additive attestation; never retrospectively modify this frozen revision.",[
    ["Current source integration requirements (56fb update supersedes older embedded plan)",checkpoint+"INTEGRATION_FOR_S2.md"]
  ]),
  sub("Explicitly unsigned conclusions"),
  p("S1-R3-A-01 behavioral closure; final S1 changed-candidate acceptance; successful complete S1/S2 composition; actual effective deployed privileges or runtime containment; serving-role/caller compatibility; hosted grant/owner facts; PG15 compatibility; backup/restore readiness; global topology or future-object safety; merge/release/activation and customer import acceptance."),
  p("S1-A-04/-06 remain external applicability holds. S1-A-07 remains bounded: verifier still drops child namespace/OID before public-name lookup and merely requires at least one attached child, not complete detached/nested/cross-schema topology. SQL-role tests are not HTTP/JWT or deployed-app-client proof. Unchanged source preserves only relevant historical inputs, never overall safety.",[
    ["Prior A scope and retained stable limits",root+"tgp-private-evidence/2026-09-21/audits/s1-r3/a/REPORT.md"]
  ]),
  p("Disposition owner and private publisher: parent. No majority-vote reconciliation or current-peer conclusion informed this independent frozen assessment.")
];
const doc=new Document({
  creator:"Independent reviewer A",
  title:"S1 R4 — Independent reviewer A — Frozen revision 1",
  description:"Narrow source assessment; dynamic attestation pending",
  styles:{
    default:{document:{run:{font:"Arial",size:21,color:"28251D"}}},
    paragraphStyles:[
      {id:"Heading1",name:"Heading 1",basedOn:"Normal",next:"Normal",quickFormat:true,run:{font:"Arial",size:28,bold:true},paragraph:{spacing:{before:160,after:140},outlineLevel:0}},
      {id:"Heading2",name:"Heading 2",basedOn:"Normal",next:"Normal",quickFormat:true,run:{font:"Arial",size:23,bold:true},paragraph:{spacing:{before:100,after:100},outlineLevel:1}},
      {id:"FootnoteText",name:"footnote text",basedOn:"Normal",run:{font:"Arial",size:18},paragraph:{spacing:{line:210}}}
    ]
  },
  footnotes,
  sections:[{
    properties:{page:{size:{width:12240,height:15840},margin:{top:850,right:1000,bottom:850,left:1000}}},
    footers:{default:new Footer({children:[new Paragraph({children:[new TextRun({text:"S1 R4 · A · revision 1 · Dynamic attestation pending   |   ",size:18}),new TextRun({children:[PageNumber.CURRENT],size:18})]})]})},
    children:body
  }]
});
Packer.toBuffer(doc).then(buf=>fs.writeFileSync(path.join(out,"REPORT.docx"),buf));
