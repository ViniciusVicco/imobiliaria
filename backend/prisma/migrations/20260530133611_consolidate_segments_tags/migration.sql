-- Consolidate property segments into residential/commercial and introduce visual tags.
ALTER TABLE "properties"
ADD COLUMN "tag_slugs" TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[];

CREATE TABLE "property_tags" (
  "slug" TEXT NOT NULL,
  "label" TEXT NOT NULL,
  "description" TEXT NOT NULL,
  "is_active" BOOLEAN NOT NULL DEFAULT true,
  "sort_order" INTEGER NOT NULL DEFAULT 0,

  CONSTRAINT "property_tags_pkey" PRIMARY KEY ("slug")
);

CREATE INDEX "property_tags_is_active_sort_order_idx"
ON "property_tags"("is_active", "sort_order");

CREATE INDEX "properties_tag_slugs_idx"
ON "properties" USING GIN ("tag_slugs");

UPDATE "properties"
SET "segment" = 'residential',
    "tag_slugs" = ARRAY['na-planta', 'entrada-reduzida']::TEXT[]
WHERE "id" = 'prop_003';

UPDATE "properties"
SET "segment" = 'commercial',
    "tag_slugs" = ARRAY['alta-rentabilidade']::TEXT[]
WHERE "id" = 'prop_008';

UPDATE "properties"
SET "segment" = 'residential',
    "tag_slugs" = ARRAY['na-planta', 'alta-rentabilidade']::TEXT[]
WHERE "id" = 'prop_009';

ALTER TYPE "PropertySegment" RENAME TO "PropertySegment_old";
CREATE TYPE "PropertySegment" AS ENUM ('residential', 'commercial');

ALTER TABLE "properties"
ALTER COLUMN "segment" TYPE "PropertySegment"
USING ("segment"::TEXT::"PropertySegment");

DROP TYPE "PropertySegment_old";
