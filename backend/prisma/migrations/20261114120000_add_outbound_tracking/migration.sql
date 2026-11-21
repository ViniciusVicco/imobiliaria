CREATE TABLE "outbound_clicks" (
  "id" TEXT NOT NULL,
  "target_url" TEXT NOT NULL,
  "source" TEXT NOT NULL,
  "user_id" TEXT,
  "user_role" "UserRole",
  "property_id" TEXT,
  "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "outbound_clicks_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "outbound_leads" (
  "id" TEXT NOT NULL,
  "click_id" TEXT NOT NULL,
  "user_id" TEXT,
  "property_id" TEXT,
  "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "outbound_leads_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "outbound_leads_click_id_key" ON "outbound_leads"("click_id");
CREATE INDEX "outbound_clicks_created_at_id_idx" ON "outbound_clicks"("created_at", "id");
CREATE INDEX "outbound_clicks_user_id_created_at_idx" ON "outbound_clicks"("user_id", "created_at");
CREATE INDEX "outbound_clicks_property_id_created_at_idx" ON "outbound_clicks"("property_id", "created_at");
CREATE INDEX "outbound_leads_created_at_idx" ON "outbound_leads"("created_at");
CREATE INDEX "outbound_leads_user_id_created_at_idx" ON "outbound_leads"("user_id", "created_at");
CREATE INDEX "outbound_leads_property_id_created_at_idx" ON "outbound_leads"("property_id", "created_at");
ALTER TABLE "outbound_clicks" ADD CONSTRAINT "outbound_clicks_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "outbound_clicks" ADD CONSTRAINT "outbound_clicks_property_id_fkey" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "outbound_leads" ADD CONSTRAINT "outbound_leads_click_id_fkey" FOREIGN KEY ("click_id") REFERENCES "outbound_clicks"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "outbound_leads" ADD CONSTRAINT "outbound_leads_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "outbound_leads" ADD CONSTRAINT "outbound_leads_property_id_fkey" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE SET NULL ON UPDATE CASCADE;
