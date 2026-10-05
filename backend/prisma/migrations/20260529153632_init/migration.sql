-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('admin', 'broker');

-- CreateEnum
CREATE TYPE "PropertySegment" AS ENUM ('residential', 'commercial', 'investments');

-- CreateEnum
CREATE TYPE "PropertyStatus" AS ENUM ('draft', 'published', 'sold', 'inactive');

-- CreateEnum
CREATE TYPE "MediaType" AS ENUM ('image', 'video', 'thumbnail');

-- CreateTable
CREATE TABLE "users" (
    "uid" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "phone" TEXT,
    "role" "UserRole" NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "created_by" TEXT,
    "updated_by" TEXT,

    CONSTRAINT "users_pkey" PRIMARY KEY ("uid")
);

-- CreateTable
CREATE TABLE "brand_content" (
    "id" TEXT NOT NULL,
    "mission" TEXT NOT NULL,
    "about" TEXT NOT NULL,
    "contact_phone" TEXT NOT NULL,
    "contact_email" TEXT NOT NULL,
    "contact_whatsapp" TEXT NOT NULL,
    "video_provider" TEXT NOT NULL,
    "video_title" TEXT NOT NULL,
    "video_thumbnail_url" TEXT NOT NULL,
    "video_url" TEXT NOT NULL,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "brand_content_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "properties" (
    "id" TEXT NOT NULL,
    "broker_uid" TEXT,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "segment" "PropertySegment" NOT NULL,
    "property_type" TEXT NOT NULL,
    "city" TEXT NOT NULL,
    "neighborhood" TEXT NOT NULL,
    "sub_neighborhood" TEXT,
    "cover_url" TEXT NOT NULL,
    "area_m2" INTEGER,
    "bedrooms" INTEGER,
    "bathrooms" INTEGER,
    "garage_spaces" INTEGER,
    "property_age_years" INTEGER,
    "price" INTEGER,
    "status" "PropertyStatus" NOT NULL DEFAULT 'draft',
    "is_featured" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "properties_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "property_media" (
    "id" TEXT NOT NULL,
    "property_id" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "type" "MediaType" NOT NULL,
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "property_media_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE INDEX "properties_status_is_featured_idx" ON "properties"("status", "is_featured");

-- CreateIndex
CREATE INDEX "properties_city_segment_property_type_idx" ON "properties"("city", "segment", "property_type");

-- CreateIndex
CREATE INDEX "properties_neighborhood_idx" ON "properties"("neighborhood");

-- CreateIndex
CREATE INDEX "properties_sub_neighborhood_idx" ON "properties"("sub_neighborhood");

-- CreateIndex
CREATE INDEX "property_media_property_id_sort_order_idx" ON "property_media"("property_id", "sort_order");

-- AddForeignKey
ALTER TABLE "properties" ADD CONSTRAINT "properties_broker_uid_fkey" FOREIGN KEY ("broker_uid") REFERENCES "users"("uid") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "property_media" ADD CONSTRAINT "property_media_property_id_fkey" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE CASCADE ON UPDATE CASCADE;
