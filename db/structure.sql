CREATE TABLE IF NOT EXISTS "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE IF NOT EXISTS "ahoy_visits" ("id" ulid DEFAULT (ulid()) NOT NULL PRIMARY KEY, "visit_token" varchar, "visitor_token" varchar, "user_id" integer, "ip" varchar, "user_agent" text, "referrer" text, "referring_domain" varchar, "landing_page" text, "browser" varchar, "os" varchar, "device_type" varchar, "country" varchar, "region" varchar, "city" varchar, "latitude" float, "longitude" float, "utm_source" varchar, "utm_medium" varchar, "utm_term" varchar, "utm_content" varchar, "utm_campaign" varchar, "app_version" varchar, "os_version" varchar, "platform" varchar, "started_at" datetime(6));
CREATE INDEX "index_ahoy_visits_on_user_id" ON "ahoy_visits" ("user_id") /*application='JobBoard'*/;
CREATE UNIQUE INDEX "index_ahoy_visits_on_visit_token" ON "ahoy_visits" ("visit_token") /*application='JobBoard'*/;
CREATE INDEX "index_ahoy_visits_on_visitor_token_and_started_at" ON "ahoy_visits" ("visitor_token", "started_at") /*application='JobBoard'*/;
CREATE TABLE IF NOT EXISTS "ahoy_events" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "visit_id" integer, "user_id" integer, "name" varchar, "properties" json, "time" datetime(6));
CREATE INDEX "index_ahoy_events_on_visit_id" ON "ahoy_events" ("visit_id") /*application='JobBoard'*/;
CREATE INDEX "index_ahoy_events_on_user_id" ON "ahoy_events" ("user_id") /*application='JobBoard'*/;
CREATE INDEX "index_ahoy_events_on_name_and_time" ON "ahoy_events" ("name", "time") /*application='JobBoard'*/;
CREATE INDEX "index_ahoy_events_on_properties" ON "ahoy_events" ("properties") /*application='JobBoard'*/;
CREATE TABLE IF NOT EXISTS "employers" ("id" ulid DEFAULT (ulid()) NOT NULL PRIMARY KEY, "email" varchar DEFAULT '' NOT NULL, "encrypted_password" varchar, "reset_password_token" varchar, "reset_password_sent_at" datetime(6), "remember_created_at" datetime(6), "sign_in_count" integer DEFAULT 0 NOT NULL, "current_sign_in_at" datetime(6), "last_sign_in_at" datetime(6), "current_sign_in_ip" varchar, "last_sign_in_ip" varchar, "confirmation_token" varchar, "confirmed_at" datetime(6), "confirmation_sent_at" datetime(6), "unconfirmed_email" varchar, "failed_attempts" integer DEFAULT 0 NOT NULL, "unlock_token" varchar, "locked_at" datetime(6), "display_name" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "login_code" varchar /*application='JobBoard'*/, "login_code_sent_at" datetime /*application='JobBoard'*/);
CREATE UNIQUE INDEX "index_employers_on_email" ON "employers" ("email") /*application='JobBoard'*/;
CREATE UNIQUE INDEX "index_employers_on_reset_password_token" ON "employers" ("reset_password_token") /*application='JobBoard'*/;
CREATE TABLE IF NOT EXISTS "job_offers" ("id" ulid DEFAULT (ulid()) NOT NULL PRIMARY KEY, "title" varchar, "location" varchar, "category" varchar, "apply_with_job_board" boolean, "featured" boolean, "approved" boolean DEFAULT 0 NOT NULL, "employer_id" ulid NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "company_name" varchar /*application='JobBoard'*/, CONSTRAINT "fk_rails_5aaea6c8db"
FOREIGN KEY ("employer_id")
  REFERENCES "employers" ("id")
);
CREATE INDEX "index_job_offers_on_employer_id" ON "job_offers" ("employer_id") /*application='JobBoard'*/;
CREATE TABLE IF NOT EXISTS "active_storage_blobs" ("id" ulid DEFAULT (ulid()) NOT NULL PRIMARY KEY, "key" varchar NOT NULL, "filename" varchar NOT NULL, "content_type" varchar, "metadata" text, "service_name" varchar NOT NULL, "byte_size" bigint NOT NULL, "checksum" varchar, "created_at" datetime(6) NOT NULL);
CREATE UNIQUE INDEX "index_active_storage_blobs_on_key" ON "active_storage_blobs" ("key") /*application='JobBoard'*/;
CREATE TABLE IF NOT EXISTS "active_storage_attachments" ("id" ulid DEFAULT (ulid()) NOT NULL PRIMARY KEY, "name" varchar NOT NULL, "record_type" varchar NOT NULL, "record_id" ulid NOT NULL, "blob_id" ulid NOT NULL, "created_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_c3b3935057"
FOREIGN KEY ("blob_id")
  REFERENCES "active_storage_blobs" ("id")
);
CREATE INDEX "index_active_storage_attachments_on_blob_id" ON "active_storage_attachments" ("blob_id") /*application='JobBoard'*/;
CREATE UNIQUE INDEX "index_active_storage_attachments_uniqueness" ON "active_storage_attachments" ("record_type", "record_id", "name", "blob_id") /*application='JobBoard'*/;
CREATE TABLE IF NOT EXISTS "active_storage_variant_records" ("id" ulid DEFAULT (ulid()) NOT NULL PRIMARY KEY, "blob_id" ulid NOT NULL, "variation_digest" varchar NOT NULL, CONSTRAINT "fk_rails_993965df05"
FOREIGN KEY ("blob_id")
  REFERENCES "active_storage_blobs" ("id")
);
CREATE UNIQUE INDEX "index_active_storage_variant_records_uniqueness" ON "active_storage_variant_records" ("blob_id", "variation_digest") /*application='JobBoard'*/;
CREATE TABLE IF NOT EXISTS "vouchers" ("id" ulid DEFAULT (ulid()) NOT NULL PRIMARY KEY, "code" varchar NOT NULL, "options" json DEFAULT '{}', "enabled_till" datetime(6) DEFAULT '2225-06-04 19:51:52.922862', "type" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "action_text_rich_texts" ("id" ulid DEFAULT (ulid()) NOT NULL PRIMARY KEY, "name" varchar NOT NULL, "body" text, "record_type" varchar NOT NULL, "record_id" ulid NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE UNIQUE INDEX "index_action_text_rich_texts_uniqueness" ON "action_text_rich_texts" ("record_type", "record_id", "name") /*application='JobBoard'*/;
CREATE TABLE IF NOT EXISTS "special_offers" ("id" ulid DEFAULT (ulid()) NOT NULL PRIMARY KEY, "name" varchar NOT NULL, "description" text, "number_of_vouchers" integer NOT NULL, "price" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "order_placements" ("id" ulid DEFAULT (ulid()) NOT NULL PRIMARY KEY, "free_order" boolean DEFAULT 0 NOT NULL, "paid_at" datetime(6), "price" integer, "job_offer_id" ulid, "special_offer_id" ulid, "voucher_code" varchar DEFAULT 'STANDARD' NOT NULL, "ready_to_be_placed" boolean DEFAULT 0, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "stripe_session_id" varchar /*application='JobBoard'*/, CONSTRAINT "fk_rails_de023b5fe1"
FOREIGN KEY ("job_offer_id")
  REFERENCES "job_offers" ("id")
, CONSTRAINT "fk_rails_b0664bf563"
FOREIGN KEY ("special_offer_id")
  REFERENCES "special_offers" ("id")
);
CREATE INDEX "index_order_placements_on_job_offer_id" ON "order_placements" ("job_offer_id") /*application='JobBoard'*/;
CREATE INDEX "index_order_placements_on_special_offer_id" ON "order_placements" ("special_offer_id") /*application='JobBoard'*/;
CREATE TABLE IF NOT EXISTS "billing_details" ("id"  NOT NULL PRIMARY KEY, "employer_id" varchar NOT NULL, "company_name" varchar, "tax_id" varchar, "address" varchar, "city" varchar, "zip" varchar, "country" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_da7d41f7c1"
FOREIGN KEY ("employer_id")
  REFERENCES "employers" ("id")
);
CREATE UNIQUE INDEX "index_billing_details_on_employer_id" ON "billing_details" ("employer_id") /*application='JobBoard'*/;
CREATE UNIQUE INDEX "index_order_placements_on_stripe_session_id" ON "order_placements" ("stripe_session_id") /*application='JobBoard'*/;
INSERT INTO "schema_migrations" (version) VALUES
('20250603121000'),
('20250524120000'),
('20250523130000'),
('20250523120000'),
('20250501135010'),
('20250501135009'),
('20250429215020'),
('20250425092912'),
('20250402155418'),
('20250324161144'),
('20250324161031'),
('20250324123451');

