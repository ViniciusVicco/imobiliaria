CREATE TYPE "RevisionStatus" AS ENUM ('pending', 'approved', 'rejected', 'superseded');
CREATE TYPE "AdminNotificationType" AS ENUM ('new_submission', 'resubmission');
CREATE TYPE "NotificationEmailStatus" AS ENUM ('pending', 'sent', 'failed');

CREATE TABLE "property_revisions" (
  "id" TEXT NOT NULL,
  "property_id" TEXT NOT NULL,
  "submitted_by" TEXT NOT NULL,
  "reviewed_by" TEXT,
  "snapshot" JSONB NOT NULL,
  "status" "RevisionStatus" NOT NULL DEFAULT 'pending',
  "note" TEXT,
  "submitted_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "reviewed_at" TIMESTAMP(3),
  CONSTRAINT "property_revisions_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "property_status_history" (
  "id" TEXT NOT NULL,
  "property_id" TEXT NOT NULL,
  "actor_id" TEXT NOT NULL,
  "from_status" "PropertyStatus",
  "to_status" "PropertyStatus" NOT NULL,
  "note" TEXT,
  "source" TEXT NOT NULL DEFAULT 'manual',
  "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "property_status_history_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "admin_notifications" (
  "id" TEXT NOT NULL,
  "admin_id" TEXT NOT NULL,
  "property_id" TEXT NOT NULL,
  "revision_id" TEXT,
  "type" "AdminNotificationType" NOT NULL,
  "title" TEXT NOT NULL,
  "message" TEXT NOT NULL,
  "is_read" BOOLEAN NOT NULL DEFAULT false,
  "email_status" "NotificationEmailStatus" NOT NULL DEFAULT 'pending',
  "email_error" TEXT,
  "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "read_at" TIMESTAMP(3),
  CONSTRAINT "admin_notifications_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "property_revisions_property_id_status_submitted_at_idx" ON "property_revisions"("property_id", "status", "submitted_at");
CREATE INDEX "property_status_history_property_id_created_at_idx" ON "property_status_history"("property_id", "created_at");
CREATE INDEX "admin_notifications_admin_id_is_read_created_at_idx" ON "admin_notifications"("admin_id", "is_read", "created_at");
CREATE INDEX "admin_notifications_revision_id_idx" ON "admin_notifications"("revision_id");

ALTER TABLE "property_revisions" ADD CONSTRAINT "property_revisions_property_id_fkey" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "property_revisions" ADD CONSTRAINT "property_revisions_submitted_by_fkey" FOREIGN KEY ("submitted_by") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "property_revisions" ADD CONSTRAINT "property_revisions_reviewed_by_fkey" FOREIGN KEY ("reviewed_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "property_status_history" ADD CONSTRAINT "property_status_history_property_id_fkey" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "property_status_history" ADD CONSTRAINT "property_status_history_actor_id_fkey" FOREIGN KEY ("actor_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "admin_notifications" ADD CONSTRAINT "admin_notifications_admin_id_fkey" FOREIGN KEY ("admin_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "admin_notifications" ADD CONSTRAINT "admin_notifications_property_id_fkey" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "admin_notifications" ADD CONSTRAINT "admin_notifications_revision_id_fkey" FOREIGN KEY ("revision_id") REFERENCES "property_revisions"("id") ON DELETE SET NULL ON UPDATE CASCADE;
