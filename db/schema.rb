# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_10_20_000008) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
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
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "candidate_supports", force: :cascade do |t|
    t.bigint "user_id", null: false, comment: "Supporter"
    t.bigint "cliq_id", null: false
    t.bigint "candidate_user_id", null: false
    t.bigint "post_id", null: false, comment: "Moderation post representing the candidacy"
    t.decimal "weight", precision: 8, scale: 2, default: "1.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["candidate_user_id"], name: "index_candidate_supports_on_candidate_user_id"
    t.index ["cliq_id", "candidate_user_id"], name: "index_candidate_supports_on_cliq_id_and_candidate_user_id"
    t.index ["cliq_id"], name: "index_candidate_supports_on_cliq_id"
    t.index ["post_id"], name: "index_candidate_supports_on_post_id"
    t.index ["user_id", "cliq_id", "candidate_user_id"], name: "index_candidate_supports_on_unique_supports", unique: true
    t.index ["user_id"], name: "index_candidate_supports_on_user_id"
  end

  create_table "cliqs", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.bigint "parent_cliq_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.integer "rank", default: 0, null: false, comment: "Enum: 0=unranked,1=bronze,2=silver,3=gold"
    t.datetime "ranked_at"
    t.jsonb "rank_metadata", default: {}, null: false
    t.index ["name", "parent_cliq_id"], name: "index_cliqs_on_name_and_parent_cliq_id", unique: true
    t.index ["parent_cliq_id"], name: "index_cliqs_on_parent_cliq_id"
    t.index ["rank"], name: "index_cliqs_on_rank"
    t.index ["ranked_at"], name: "index_cliqs_on_ranked_at"
    t.index ["slug"], name: "index_cliqs_on_slug", unique: true
  end

  create_table "direct_message_conversations", force: :cascade do |t|
    t.bigint "user_a_id", null: false
    t.bigint "user_b_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_a_id", "user_b_id"], name: "index_direct_message_conversations_on_participants", unique: true
    t.index ["user_a_id"], name: "index_direct_message_conversations_on_user_a_id"
    t.index ["user_b_id"], name: "index_direct_message_conversations_on_user_b_id"
  end

  create_table "direct_messages", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.bigint "sender_id", null: false
    t.bigint "recipient_id", null: false
    t.text "body", null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_direct_messages_on_conversation_id"
    t.index ["recipient_id", "read_at"], name: "index_direct_messages_on_recipient_id_and_read_at"
    t.index ["recipient_id"], name: "index_direct_messages_on_recipient_id"
    t.index ["sender_id"], name: "index_direct_messages_on_sender_id"
  end

  create_table "followed_users", force: :cascade do |t|
    t.bigint "follower_id", null: false
    t.bigint "followed_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["followed_id"], name: "index_followed_users_on_followed_id"
    t.index ["follower_id", "followed_id"], name: "index_followed_users_on_follower_id_and_followed_id", unique: true
    t.index ["follower_id"], name: "index_followed_users_on_follower_id"
  end

  create_table "moderation_actions", force: :cascade do |t|
    t.bigint "actor_id", null: false
    t.bigint "cliq_id", null: false
    t.string "action_type", null: false
    t.string "subject_type", null: false
    t.bigint "subject_id", null: false
    t.bigint "report_id"
    t.text "notes"
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action_type"], name: "index_moderation_actions_on_action_type"
    t.index ["actor_id"], name: "index_moderation_actions_on_actor_id"
    t.index ["cliq_id"], name: "index_moderation_actions_on_cliq_id"
    t.index ["report_id"], name: "index_moderation_actions_on_report_id"
    t.index ["subject_type", "subject_id"], name: "index_moderation_actions_on_subject"
  end

  create_table "moderation_delegations", force: :cascade do |t|
    t.bigint "delegator_id", null: false
    t.bigint "delegatee_id", null: false
    t.bigint "cliq_id", null: false
    t.datetime "granted_at", null: false
    t.datetime "revoked_at"
    t.boolean "active", default: true, null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cliq_id"], name: "index_moderation_delegations_on_cliq_id"
    t.index ["delegatee_id", "cliq_id"], name: "index_mod_delegations_on_delegatee_cliq"
    t.index ["delegatee_id"], name: "index_moderation_delegations_on_delegatee_id"
    t.index ["delegator_id", "cliq_id"], name: "index_mod_delegations_on_delegator_cliq", unique: true
    t.index ["delegator_id"], name: "index_moderation_delegations_on_delegator_id"
  end

  create_table "moderator_roles", force: :cascade do |t|
    t.bigint "cliq_id", null: false
    t.bigint "user_id", null: false
    t.datetime "started_at", null: false
    t.datetime "ended_at"
    t.integer "seated_supports_count", default: 0, null: false
    t.string "status", default: "active", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cliq_id", "user_id", "ended_at"], name: "index_moderator_roles_on_cliq_user_ended"
    t.index ["cliq_id"], name: "index_moderator_roles_on_cliq_id"
    t.index ["status"], name: "index_moderator_roles_on_status"
    t.index ["user_id"], name: "index_moderator_roles_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "actor_id", null: false
    t.string "notifiable_type", null: false
    t.bigint "notifiable_id", null: false
    t.string "message", null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_notifications_on_actor_id"
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable_type_and_notifiable_id"
    t.index ["user_id", "read_at"], name: "index_notifications_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.string "title"
    t.text "legacy_content"
    t.integer "cliq_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.integer "replies_count", default: 0, null: false
    t.boolean "deleted", default: false, null: false
    t.integer "post_type", default: 0, null: false
    t.float "heat_score", default: 0.0, null: false
    t.datetime "hot_until"
    t.datetime "heat_score_updated_at"
    t.integer "visibility", default: 0, null: false, comment: "Enum tracked in Post.visibility enum"
    t.datetime "moderation_tagged_at"
    t.integer "moderation_supports_count", default: 0, null: false
    t.index ["heat_score"], name: "index_posts_on_heat_score"
    t.index ["hot_until"], name: "index_posts_on_hot_until"
    t.index ["moderation_supports_count"], name: "index_posts_on_moderation_supports_count"
    t.index ["moderation_tagged_at"], name: "index_posts_on_moderation_tagged_at"
    t.index ["post_type"], name: "index_posts_on_post_type"
    t.index ["slug"], name: "index_posts_on_slug", unique: true
    t.index ["visibility"], name: "index_posts_on_visibility"
  end

  create_table "profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "username", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_profiles_on_user_id"
    t.index ["username"], name: "index_profiles_on_username", unique: true
  end

  create_table "replies", force: :cascade do |t|
    t.bigint "post_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "parent_reply_id"
    t.index ["parent_reply_id"], name: "index_replies_on_parent_reply_id"
    t.index ["post_id"], name: "index_replies_on_post_id"
    t.index ["user_id"], name: "index_replies_on_user_id"
  end

  create_table "reports", force: :cascade do |t|
    t.string "reportable_type", null: false
    t.bigint "reportable_id", null: false
    t.bigint "cliq_id", null: false, comment: "Cliq where the content lived at report time"
    t.bigint "reporter_id", null: false
    t.string "reason", null: false
    t.text "note"
    t.string "state", default: "pending", null: false
    t.datetime "escalated_at"
    t.bigint "escalated_to_cliq_id"
    t.datetime "sla_expires_at"
    t.datetime "resolved_at"
    t.bigint "resolved_by_id"
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cliq_id", "state"], name: "index_reports_on_cliq_id_and_state"
    t.index ["cliq_id"], name: "index_reports_on_cliq_id"
    t.index ["escalated_to_cliq_id"], name: "index_reports_on_escalated_to_cliq_id"
    t.index ["reportable_type", "reportable_id"], name: "index_reports_on_reportable"
    t.index ["reporter_id"], name: "index_reports_on_reporter_id"
    t.index ["resolved_by_id"], name: "index_reports_on_resolved_by_id"
    t.index ["sla_expires_at"], name: "index_reports_on_sla_expires_at"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "cliq_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "enabled", default: true, null: false
    t.index ["cliq_id"], name: "index_subscriptions_on_cliq_id"
    t.index ["user_id", "cliq_id"], name: "index_subscriptions_on_user_id_and_cliq_id", unique: true
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "user_moderation_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "account_age_days", default: 0, null: false
    t.integer "activity_score", default: 0, null: false
    t.integer "strike_count", default: 0, null: false
    t.boolean "established", default: false, null: false
    t.datetime "snapshot_at", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_moderation_profiles_on_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "candidate_supports", "cliqs"
  add_foreign_key "candidate_supports", "posts"
  add_foreign_key "candidate_supports", "users"
  add_foreign_key "candidate_supports", "users", column: "candidate_user_id"
  add_foreign_key "cliqs", "cliqs", column: "parent_cliq_id"
  add_foreign_key "direct_message_conversations", "users", column: "user_a_id"
  add_foreign_key "direct_message_conversations", "users", column: "user_b_id"
  add_foreign_key "direct_messages", "direct_message_conversations", column: "conversation_id"
  add_foreign_key "direct_messages", "users", column: "recipient_id"
  add_foreign_key "direct_messages", "users", column: "sender_id"
  add_foreign_key "followed_users", "users", column: "followed_id"
  add_foreign_key "followed_users", "users", column: "follower_id"
  add_foreign_key "moderation_actions", "cliqs"
  add_foreign_key "moderation_actions", "reports"
  add_foreign_key "moderation_actions", "users", column: "actor_id"
  add_foreign_key "moderation_delegations", "cliqs"
  add_foreign_key "moderation_delegations", "users", column: "delegatee_id"
  add_foreign_key "moderation_delegations", "users", column: "delegator_id"
  add_foreign_key "moderator_roles", "cliqs"
  add_foreign_key "moderator_roles", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "notifications", "users", column: "actor_id"
  add_foreign_key "profiles", "users"
  add_foreign_key "replies", "posts"
  add_foreign_key "replies", "replies", column: "parent_reply_id"
  add_foreign_key "replies", "users"
  add_foreign_key "reports", "cliqs"
  add_foreign_key "reports", "cliqs", column: "escalated_to_cliq_id"
  add_foreign_key "reports", "users", column: "reporter_id"
  add_foreign_key "reports", "users", column: "resolved_by_id"
  add_foreign_key "subscriptions", "cliqs"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "user_moderation_profiles", "users"
end
