ALTER TYPE "PropertyStatus" ADD VALUE IF NOT EXISTS 'pending_review';

CREATE TYPE "MediaStatus" AS ENUM ('active', 'pending_delete');

ALTER TABLE "property_media"
ADD COLUMN "public_url" TEXT,
ADD COLUMN "storage_key" TEXT,
ADD COLUMN "status" "MediaStatus" NOT NULL DEFAULT 'active',
ADD COLUMN "mime_type" TEXT,
ADD COLUMN "size_bytes" INTEGER,
ADD COLUMN "uploaded_by" TEXT,
ADD COLUMN "pending_delete_at" TIMESTAMP(3),
ADD COLUMN "deleted_at" TIMESTAMP(3);

UPDATE "property_media"
SET
  "public_url" = "url",
  "storage_key" = "url"
WHERE "public_url" IS NULL;

DROP INDEX IF EXISTS "property_media_property_id_sort_order_idx";
CREATE INDEX "property_media_property_id_status_sort_order_idx"
ON "property_media"("property_id", "status", "sort_order");
CREATE INDEX "property_media_pending_delete_at_idx"
ON "property_media"("pending_delete_at");
