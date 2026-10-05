-- Move user identity fully into PostgreSQL auth.
ALTER TABLE "properties" DROP CONSTRAINT IF EXISTS "properties_broker_uid_fkey";

ALTER TABLE "users" RENAME COLUMN "uid" TO "id";
ALTER TABLE "users" ADD COLUMN "password_hash" TEXT;
ALTER TABLE "users" ADD COLUMN "last_login_at" TIMESTAMP(3);

UPDATE "users"
SET "password_hash" = 'pending-migration-password-hash'
WHERE "password_hash" IS NULL;

ALTER TABLE "users" ALTER COLUMN "password_hash" SET NOT NULL;

ALTER TABLE "properties" RENAME COLUMN "broker_uid" TO "broker_id";

ALTER TABLE "properties"
ADD CONSTRAINT "properties_broker_id_fkey"
FOREIGN KEY ("broker_id") REFERENCES "users"("id")
ON DELETE SET NULL ON UPDATE CASCADE;
