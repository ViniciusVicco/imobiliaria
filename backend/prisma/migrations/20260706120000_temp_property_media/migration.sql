ALTER TABLE "property_media"
ALTER COLUMN "property_id" DROP NOT NULL,
ADD COLUMN IF NOT EXISTS "upload_session_id" TEXT;

CREATE INDEX IF NOT EXISTS "property_media_uploaded_by_upload_session_id_created_at_idx"
ON "property_media"("uploaded_by", "upload_session_id", "created_at");
