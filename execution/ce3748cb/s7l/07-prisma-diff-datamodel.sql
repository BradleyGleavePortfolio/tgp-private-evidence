-- AlterTable
ALTER TABLE "ScoutImport" ADD COLUMN     "accepted_start_at" TIMESTAMP(3),
ADD COLUMN     "deadline_at" TIMESTAMP(3),
ADD COLUMN     "execution_epoch" INTEGER NOT NULL DEFAULT 1,
ADD COLUMN     "fence_reason" TEXT,
ADD COLUMN     "fenced_at" TIMESTAMP(3),
ADD COLUMN     "import_intent_id" UUID,
ADD COLUMN     "last_observed_at" TIMESTAMP(3),
ADD COLUMN     "mode" TEXT NOT NULL DEFAULT 'legacy',
ADD COLUMN     "phase" TEXT,
ADD COLUMN     "reason_code" TEXT;

-- CreateIndex
CREATE UNIQUE INDEX "ScoutImport_import_intent_id_key" ON "ScoutImport"("import_intent_id");

-- AddForeignKey
ALTER TABLE "ScoutImport" ADD CONSTRAINT "ScoutImport_import_intent_id_coach_id_fkey" FOREIGN KEY ("import_intent_id", "coach_id") REFERENCES "ImportIntent"("id", "coach_id") ON DELETE RESTRICT ON UPDATE CASCADE;

