# Exact blob accounting: reuse (PR293 verbatim) vs authored (this session)

## Reused verbatim from PR293 (003a9774083812a465fbc78a99aaba5ca16ccfa5) — blob hash identical, zero re-authoring
- `src/screens/coach/import-journey/ImportOfferCard.tsx` blob `f20456f6fefd5e3476d88ad7657a2f0421f35d22` vs PR293 blob `f20456f6fefd5e3476d88ad7657a2f0421f35d22` — MATCH
- `src/screens/coach/import-journey/ImportSetupView.tsx` blob `23584782bcc0f1ee5a31fde06f501c135f98269c` vs PR293 blob `23584782bcc0f1ee5a31fde06f501c135f98269c` — MATCH
- `src/screens/coach/import-journey/README.md` blob `c30fc3555e2ff6e475db280aac08ab1940fb5b7b` vs PR293 blob `c30fc3555e2ff6e475db280aac08ab1940fb5b7b` — MATCH
- `src/screens/coach/import-journey/__tests__/ImportJourney.navigation.test.tsx` blob `04c9a42b36b049a9d7a845319e7d26c1fe75ca34` vs PR293 blob `04c9a42b36b049a9d7a845319e7d26c1fe75ca34` — MATCH
- `src/screens/coach/import-journey/__tests__/ImportOfferCard.test.tsx` blob `cbaa44c663b8065ed3dd555081844ec434985012` vs PR293 blob `cbaa44c663b8065ed3dd555081844ec434985012` — MATCH
- `src/screens/coach/import-journey/__tests__/ImportSetupView.test.tsx` blob `9255cf736625e5a5fb7fcac173ba331d9b7d6a49` vs PR293 blob `9255cf736625e5a5fb7fcac173ba331d9b7d6a49` — MATCH
- `src/screens/coach/import-journey/__tests__/importJourneyCopy.test.ts` blob `904c7e0504f638944df11159f0762069c3243264` vs PR293 blob `904c7e0504f638944df11159f0762069c3243264` — MATCH
- `src/screens/coach/import-journey/__tests__/sideEffectGuards.cjs` blob `834b6a18a28b75259ce772ceda763a9c91a7408b` vs PR293 blob `834b6a18a28b75259ce772ceda763a9c91a7408b` — MATCH
- `src/screens/coach/import-journey/i18n/en.json` blob `7768128eaba7d42a78220b7ca31454655e81fe74` vs PR293 blob `7768128eaba7d42a78220b7ca31454655e81fe74` — MATCH
- `src/screens/coach/import-journey/importJourneyCopy.ts` blob `4c09b1b8251b3fd1ea85528e9d5d9f2381743178` vs PR293 blob `4c09b1b8251b3fd1ea85528e9d5d9f2381743178` — MATCH
- `src/screens/coach/import-journey/importJourneyUI.tsx` blob `3f1fb60e553ff54d1b97c61734d71efe2a069286` vs PR293 blob `3f1fb60e553ff54d1b97c61734d71efe2a069286` — MATCH

## Authored/modified this session (not donor-verbatim)
- `src/screens/coach/SettingsScreen.tsx` new blob `c8bcb5f106d49aeef10d5b56c9106cdf0323052f` (one-line label edit; diff below)
diff --git a/src/screens/coach/SettingsScreen.tsx b/src/screens/coach/SettingsScreen.tsx
index 77c5749..c8bcb5f 100644
--- a/src/screens/coach/SettingsScreen.tsx
+++ b/src/screens/coach/SettingsScreen.tsx
@@ -365,7 +365,7 @@ export default function SettingsScreen() {
               testID="settings-import-data"
             >
               <Ionicons name="cloud-download-outline" size={20} color={colors.textSecondary} />
-              <Text style={styles.rowLabel}>Import Data</Text>
+              <Text style={styles.rowLabel}>Import my records</Text>
               <Ionicons name="chevron-forward" size={16} color={colors.textMuted} />
             </TouchableOpacity>
             <View style={styles.divider} />
