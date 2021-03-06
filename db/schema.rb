# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_02_02_213322) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "abuse_report_subjects", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "abuse_report_id"
    t.uuid "account_id"
    t.uuid "project_id"
    t.uuid "issue_id"
    t.index ["abuse_report_id"], name: "index_abuse_report_subjects_on_abuse_report_id"
    t.index ["account_id"], name: "index_abuse_report_subjects_on_account_id"
    t.index ["issue_id"], name: "index_abuse_report_subjects_on_issue_id"
    t.index ["project_id"], name: "index_abuse_report_subjects_on_project_id"
  end

  create_table "abuse_reports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id"
    t.text "description"
    t.string "aasm_state"
    t.integer "report_number"
    t.text "admin_note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_abuse_reports_on_account_id"
  end

  create_table "account_issues", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id"
    t.string "issue_encrypted_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_account_issues_on_account_id"
  end

  create_table "account_project_blocks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "project_id"
    t.uuid "account_id"
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_account_project_blocks_on_account_id"
    t.index ["project_id"], name: "index_account_project_blocks_on_project_id"
  end

  create_table "accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "email", default: "", null: false
    t.string "temp_2fa_code"
    t.boolean "email_confirmed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "normalized_email"
    t.string "hashed_email"
    t.string "notification_encrypted_ids", default: [], array: true
    t.boolean "is_admin", default: false
    t.boolean "is_flagged", default: false
    t.text "flagged_reason"
    t.datetime "flagged_at"
    t.boolean "flag_requested", default: false
    t.text "flag_requested_reason"
    t.index ["confirmation_token"], name: "index_accounts_on_confirmation_token", unique: true
    t.index ["email"], name: "index_accounts_on_email", unique: true
    t.index ["normalized_email"], name: "index_accounts_on_normalized_email", unique: true
    t.index ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_accounts_on_unlock_token", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "contact_messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "message"
    t.text "sender_ip"
    t.string "sender_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "issue_comments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "text"
    t.string "commenter_encrypted_id"
    t.boolean "visible_to_reporter", default: false
    t.uuid "issue_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "visible_to_respondent", default: false
    t.boolean "visible_only_to_moderators", default: false
    t.index ["issue_id"], name: "index_issue_comments_on_issue_id"
  end

  create_table "issue_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "event"
    t.string "actor_encrypted_id"
    t.uuid "issue_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["issue_id"], name: "index_issue_events_on_issue_id"
  end

  create_table "issue_invitations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "issue_encrypted_id"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "issue_severity_levels", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "scope", default: "project", null: false
    t.string "label", null: false
    t.integer "severity", null: false
    t.text "example", null: false
    t.text "consequence", null: false
    t.uuid "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_issue_severity_levels_on_project_id"
  end

  create_table "issues", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "description"
    t.string "reporter_encrypted_id"
    t.integer "issue_number"
    t.string "project_encrypted_id"
    t.string "aasm_state"
    t.text "urls", default: [], array: true
    t.boolean "is_spam", default: false
    t.boolean "is_abusive", default: false
    t.datetime "acknowledged_at"
    t.datetime "closed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "respondent_summary"
    t.text "respondent_encrypted_id"
    t.text "resolution_text"
    t.datetime "resolved_at"
    t.uuid "issue_severity_level_id"
    t.index ["issue_severity_level_id"], name: "index_issues_on_issue_severity_level_id"
  end

  create_table "notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "project_id"
    t.uuid "issue_id"
    t.uuid "issue_comment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["issue_comment_id"], name: "index_notifications_on_issue_comment_id"
    t.index ["issue_id"], name: "index_notifications_on_issue_id"
    t.index ["project_id"], name: "index_notifications_on_project_id"
  end

  create_table "project_issues", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "project_id"
    t.string "issue_encrypted_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_issues_on_project_id"
  end

  create_table "project_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "paused_at"
    t.integer "rate_per_day", default: 5
    t.boolean "require_3rd_party_auth", default: false
    t.integer "minimum_3rd_party_auth_age_in_days", default: 30
    t.boolean "allow_anonymous_issues", default: false
    t.boolean "publish_stats", default: true
    t.boolean "include_in_directory", default: false
    t.uuid "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_settings_on_project_id"
  end

  create_table "projects", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "url", null: false
    t.string "coc_url", null: false
    t.text "description", null: false
    t.uuid "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "has_confirmed_settings", default: false
    t.datetime "confirmed_at"
    t.boolean "is_flagged", default: false
    t.text "flagged_reason"
    t.datetime "flagged_at"
    t.index ["account_id"], name: "index_projects_on_account_id"
    t.index ["slug"], name: "index_projects_on_slug", unique: true
  end

  create_table "respondent_templates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "project_id"
    t.text "text"
    t.boolean "is_beacon_default", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_respondent_templates_on_project_id"
  end

  create_table "suspicious_activity_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "controller"
    t.string "action"
    t.string "ip_address"
    t.text "params"
    t.uuid "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_suspicious_activity_logs_on_account_id"
  end

  add_foreign_key "abuse_report_subjects", "abuse_reports"
  add_foreign_key "abuse_report_subjects", "accounts"
  add_foreign_key "abuse_report_subjects", "issues"
  add_foreign_key "abuse_report_subjects", "projects"
  add_foreign_key "abuse_reports", "accounts"
  add_foreign_key "account_issues", "accounts"
  add_foreign_key "account_project_blocks", "accounts"
  add_foreign_key "account_project_blocks", "projects"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "issue_comments", "issues"
  add_foreign_key "issue_events", "issues"
  add_foreign_key "issue_severity_levels", "projects"
  add_foreign_key "issues", "issue_severity_levels"
  add_foreign_key "notifications", "issue_comments"
  add_foreign_key "notifications", "issues"
  add_foreign_key "notifications", "projects"
  add_foreign_key "project_issues", "projects"
  add_foreign_key "project_settings", "projects"
  add_foreign_key "projects", "accounts"
  add_foreign_key "respondent_templates", "projects"
  add_foreign_key "suspicious_activity_logs", "accounts"
end
