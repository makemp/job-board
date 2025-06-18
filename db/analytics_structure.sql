CREATE TABLE IF NOT EXISTS "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE IF NOT EXISTS "ahoy_visits" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "visit_token" varchar, "visitor_token" varchar, "ip" varchar, "user_agent" text, "referrer" text, "referring_domain" varchar, "landing_page" text, "browser" varchar, "os" varchar, "device_type" varchar, "country" varchar, "region" varchar, "city" varchar, "latitude" float, "longitude" float, "utm_source" varchar, "utm_medium" varchar, "utm_term" varchar, "utm_content" varchar, "utm_campaign" varchar, "app_version" varchar, "os_version" varchar, "platform" varchar, "started_at" datetime(6));
CREATE UNIQUE INDEX "index_ahoy_visits_on_visit_token" ON "ahoy_visits" ("visit_token") /*application='JobBoard'*/;
CREATE INDEX "index_ahoy_visits_on_visitor_token_and_started_at" ON "ahoy_visits" ("visitor_token", "started_at") /*application='JobBoard'*/;
CREATE TABLE IF NOT EXISTS "ahoy_events" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "visit_id" integer, "name" varchar, "properties" json, "time" datetime(6));
CREATE INDEX "index_ahoy_events_on_visit_id" ON "ahoy_events" ("visit_id") /*application='JobBoard'*/;
CREATE INDEX "index_ahoy_events_on_name_and_time" ON "ahoy_events" ("name", "time") /*application='JobBoard'*/;
CREATE INDEX "index_ahoy_events_on_properties" ON "ahoy_events" ("properties") /*application='JobBoard'*/;
INSERT INTO "schema_migrations" (version) VALUES
('20250324123451');

