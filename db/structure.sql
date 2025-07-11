CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE IF NOT EXISTS "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "users" ("id" ulid DEFAULT (ulid()) NOT NULL PRIMARY KEY, "email" varchar, "encrypted_password" varchar, "reset_password_token" varchar, "reset_password_sent_at" datetime(6), "remember_created_at" datetime(6), "sign_in_count" integer DEFAULT 0 NOT NULL, "current_sign_in_at" datetime(6), "last_sign_in_at" datetime(6), "current_sign_in_ip" varchar, "last_sign_in_ip" varchar, "confirmation_token" varchar, "confirmed_at" datetime(6), "confirmation_sent_at" datetime(6), "unconfirmed_email" varchar, "failed_attempts" integer DEFAULT 0 NOT NULL, "unlock_token" varchar, "locked_at" datetime(6), "company_name" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "stripe_customer_id" varchar, "type" varchar, "closed_at" datetime(6), "login_code" varchar /*application='JobBoard'*/, "login_code_sent_at" datetime /*application='JobBoard'*/);
CREATE UNIQUE INDEX "index_users_on_email" ON "users" ("email") /*application='JobBoard'*/;
CREATE UNIQUE INDEX "index_users_on_reset_password_token" ON "users" ("reset_password_token") /*application='JobBoard'*/;
CREATE TABLE IF NOT EXISTS "job_offers" ("id" ulid DEFAULT (ulid()) NOT NULL PRIMARY KEY, "title" varchar, "location" varchar, "category" varchar, "application_type" varchar, "application_destination" varchar, "expired_on" datetime(6), "expired_manually" datetime(6), "featured" boolean, "approved" boolean DEFAULT 0 NOT NULL, "terms_and_conditions" boolean DEFAULT 0, "type" varchar, "employer_id" ulid NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "company_name" varchar /*application='JobBoard'*/, CONSTRAINT "fk_rails_5aaea6c8db"
FOREIGN KEY ("employer_id")
  REFERENCES "users" ("id")
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
CREATE TABLE IF NOT EXISTS "vouchers" ("id" ulid DEFAULT (ulid()) NOT NULL PRIMARY KEY, "code" varchar NOT NULL, "options" json DEFAULT '{}', "enabled_till" datetime(6) DEFAULT '2225-07-11 21:32:42.786175', "type" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "action_text_rich_texts" ("id" ulid DEFAULT (ulid()) NOT NULL PRIMARY KEY, "name" varchar NOT NULL, "body" text, "record_type" varchar NOT NULL, "record_id" ulid NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE UNIQUE INDEX "index_action_text_rich_texts_uniqueness" ON "action_text_rich_texts" ("record_type", "record_id", "name") /*application='JobBoard'*/;
CREATE TABLE IF NOT EXISTS "special_offers" ("id" ulid DEFAULT (ulid()) NOT NULL PRIMARY KEY, "name" varchar NOT NULL, "description" text, "number_of_vouchers" integer NOT NULL, "price" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "order_placements" ("id" ulid DEFAULT (ulid()) NOT NULL PRIMARY KEY, "free_order" boolean DEFAULT 0 NOT NULL, "paid_on" datetime(6), "price" integer, "job_offer_id" ulid, "special_offer_id" ulid, "voucher_code" varchar DEFAULT 'STANDARD' NOT NULL, "ready_to_be_placed" boolean DEFAULT 0, "job_offer_form_params" json DEFAULT '{}', "stripe_payload" json DEFAULT '{}', "session_token" varchar, "payment_broadcasted" boolean DEFAULT 0, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "stripe_session_id" varchar /*application='JobBoard'*/, CONSTRAINT "fk_rails_de023b5fe1"
FOREIGN KEY ("job_offer_id")
  REFERENCES "job_offers" ("id")
, CONSTRAINT "fk_rails_b0664bf563"
FOREIGN KEY ("special_offer_id")
  REFERENCES "special_offers" ("id")
);
CREATE INDEX "index_order_placements_on_job_offer_id" ON "order_placements" ("job_offer_id") /*application='JobBoard'*/;
CREATE INDEX "index_order_placements_on_special_offer_id" ON "order_placements" ("special_offer_id") /*application='JobBoard'*/;
CREATE UNIQUE INDEX "index_order_placements_on_stripe_session_id" ON "order_placements" ("stripe_session_id") /*application='JobBoard'*/;
CREATE TABLE IF NOT EXISTS "job_offer_actions" ("id" ulid DEFAULT (ulid()) NOT NULL PRIMARY KEY, "action_type" varchar, "valid_till" datetime(6) NOT NULL, "job_offer_id" ulid NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_69aade34a8"
FOREIGN KEY ("job_offer_id")
  REFERENCES "job_offers" ("id")
);
CREATE INDEX "index_job_offer_actions_on_job_offer_id" ON "job_offer_actions" ("job_offer_id") /*application='JobBoard'*/;
CREATE TABLE IF NOT EXISTS "job_offer_applications" ("id" ulid DEFAULT (ulid()) NOT NULL PRIMARY KEY, "job_offer_id" ulid NOT NULL, "comments" text NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_590de0688f"
FOREIGN KEY ("job_offer_id")
  REFERENCES "job_offers" ("id")
);
CREATE INDEX "index_job_offer_applications_on_job_offer_id" ON "job_offer_applications" ("job_offer_id") /*application='JobBoard'*/;
CREATE INDEX "idx_job_offers_expired_on" ON "job_offers" ("expired_on") /*application='JobBoard'*/;
CREATE INDEX "idx_job_offer_actions_covering" ON "job_offer_actions" ("action_type", "job_offer_id", "valid_till") WHERE action_type IN ('created', 'extended') /*application='JobBoard'*/;
INSERT INTO "schema_migrations" (version) VALUES
('20250705000001'),
('20250704213534'),
('20250704213433'),
('20250603121000'),
('20250524120000'),
('20250523120000'),
('20250501135010'),
('20250501135009'),
('20250429215020'),
('20250425092912'),
('20250402155418'),
('20250324161144'),
('20250324161031');

