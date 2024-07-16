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

ActiveRecord::Schema[7.0].define(version: 2024_10_25_223137) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "addresses", force: :cascade do |t|
    t.string "addressable_type"
    t.bigint "addressable_id"
    t.string "city"
    t.string "country"
    t.integer "postal_code"
    t.string "state"
    t.boolean "is_default"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable"
  end

  create_table "allowlisted_jwts", force: :cascade do |t|
    t.string "jti", null: false
    t.string "aud"
    t.datetime "exp", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_allowlisted_jwts_on_jti", unique: true
    t.index ["user_id"], name: "index_allowlisted_jwts_on_user_id"
  end

  create_table "blocks", force: :cascade do |t|
    t.bigint "blocker_id", null: false
    t.bigint "blocked_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blocked_id"], name: "index_blocks_on_blocked_id"
    t.index ["blocker_id", "blocked_id"], name: "index_blocks_on_blocker_id_and_blocked_id", unique: true
    t.index ["blocker_id"], name: "index_blocks_on_blocker_id"
  end

  create_table "blog_app_articles", force: :cascade do |t|
    t.string "title"
    t.text "subtitle"
    t.datetime "published_at"
    t.bigint "user_id", null: false
    t.datetime "deleted_at"
    t.integer "status", default: 0, null: false
    t.jsonb "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_blog_app_articles_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "body"
    t.bigint "user_id", null: false
    t.bigint "parent_id"
    t.string "commentable_type", null: false
    t.bigint "commentable_id", null: false
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable"
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
    t.index ["parent_id"], name: "index_comments_on_parent_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "contact_app_contacts", force: :cascade do |t|
    t.integer "user_id"
    t.string "firstname"
    t.string "lastname"
    t.string "email"
    t.string "phone"
    t.string "address"
    t.date "birth_date"
    t.integer "status", default: 0, null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contacts", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone_number"
    t.integer "user_id"
    t.datetime "deleted_at"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_contacts_on_user_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.integer "sender_id"
    t.integer "recipient_id"
    t.datetime "sender_deleted_at"
    t.datetime "recipient_deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_ai", default: false
  end

  create_table "email_records", force: :cascade do |t|
    t.string "email"
    t.string "shareable_type"
    t.bigint "shareable_id"
    t.jsonb "additional_info", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email", "shareable_type", "shareable_id"], name: "index_email_records_unique", unique: true
    t.index ["shareable_type", "shareable_id"], name: "index_email_records_on_shareable"
  end

  create_table "favorites", force: :cascade do |t|
    t.string "favoritable_type", null: false
    t.bigint "favoritable_id", null: false
    t.string "favoritor_type", null: false
    t.bigint "favoritor_id", null: false
    t.string "scope", default: "favorite", null: false
    t.boolean "blocked", default: false, null: false
    t.jsonb "data"
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blocked"], name: "index_favorites_on_blocked"
    t.index ["favoritable_id", "favoritable_type"], name: "fk_favoritables"
    t.index ["favoritable_type", "favoritable_id", "favoritor_type", "favoritor_id", "scope"], name: "uniq_favorites__and_favoritables", unique: true
    t.index ["favoritable_type", "favoritable_id"], name: "index_favorites_on_favoritable"
    t.index ["favoritor_id", "favoritor_type"], name: "fk_favorites"
    t.index ["favoritor_type", "favoritor_id"], name: "index_favorites_on_favoritor"
    t.index ["scope"], name: "index_favorites_on_scope"
  end

  create_table "follows", force: :cascade do |t|
    t.bigint "follower_id", null: false
    t.bigint "followed_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["followed_id"], name: "index_follows_on_followed_id"
    t.index ["follower_id", "followed_id"], name: "index_follows_on_follower_id_and_followed_id", unique: true
    t.index ["follower_id"], name: "index_follows_on_follower_id"
  end

  create_table "images", force: :cascade do |t|
    t.string "file"
    t.string "imageable_type", null: false
    t.bigint "imageable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["imageable_type", "imageable_id"], name: "index_images_on_imageable"
  end

  create_table "lock_app_sensitive_infos", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "data_type"
    t.text "data"
    t.string "username"
    t.string "link"
    t.string "email"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_lock_app_sensitive_infos_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.bigint "user_id", null: false
    t.text "body"
    t.datetime "read_at"
    t.datetime "sender_deleted_at"
    t.datetime "recipient_deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "my_finance_app_expenses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "item", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "description"
    t.bigint "tag_id"
    t.integer "currency", default: 0, null: false
    t.datetime "deleted_at"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "subcategory_id"
    t.datetime "spent_at"
    t.index ["tag_id"], name: "index_my_finance_app_expenses_on_tag_id"
    t.index ["user_id"], name: "index_my_finance_app_expenses_on_user_id"
  end

  create_table "my_finance_app_loan_payments", force: :cascade do |t|
    t.bigint "loan_id"
    t.decimal "amount"
    t.datetime "payment_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["loan_id"], name: "index_my_finance_app_loan_payments_on_loan_id"
  end

  create_table "my_finance_app_loans", force: :cascade do |t|
    t.integer "user_id"
    t.date "due_date"
    t.decimal "amount", precision: 15, scale: 2
    t.string "description"
    t.integer "loan_type", default: 0, null: false
    t.string "contact_name"
    t.integer "contact_id"
    t.integer "currency", default: 0, null: false
    t.datetime "deleted_at"
    t.integer "status", default: 0, null: false
    t.bigint "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_my_finance_app_loans_on_contact_id"
    t.index ["tag_id"], name: "index_my_finance_app_loans_on_tag_id"
    t.index ["user_id"], name: "index_my_finance_app_loans_on_user_id"
  end

  create_table "my_finance_loans", force: :cascade do |t|
    t.string "user_name"
    t.date "due_date"
    t.decimal "amount", precision: 15, scale: 2
    t.string "description"
    t.string "loan_type"
    t.integer "contact_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_my_finance_loans_on_contact_id"
  end

  create_table "note_app_notes", force: :cascade do |t|
    t.bigint "owner_id"
    t.integer "status", default: 0, null: false
    t.jsonb "data"
    t.string "title"
    t.text "description"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_note_app_notes_on_owner_id"
  end

  create_table "note_app_reminders", force: :cascade do |t|
    t.bigint "note_id"
    t.bigint "user_id"
    t.datetime "reminder_time"
    t.boolean "is_completed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["note_id"], name: "index_note_app_reminders_on_note_id"
    t.index ["user_id"], name: "index_note_app_reminders_on_user_id"
  end

  create_table "note_app_shares", force: :cascade do |t|
    t.bigint "note_id"
    t.bigint "shared_with_user_id"
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["note_id"], name: "index_note_app_shares_on_note_id"
    t.index ["shared_with_user_id"], name: "index_note_app_shares_on_shared_with_user_id"
  end

  create_table "notes_tags", id: false, force: :cascade do |t|
    t.bigint "note_id"
    t.bigint "tag_id"
    t.index ["note_id"], name: "index_notes_tags_on_note_id"
    t.index ["tag_id"], name: "index_notes_tags_on_tag_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.bigint "tag_id", null: false
    t.string "taggable_type", null: false
    t.bigint "taggable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id", "taggable_id", "taggable_type"], name: "index_taggings_on_tag_id_and_taggable_id_and_taggable_type", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "parent_id"
    t.integer "position"
    t.string "description"
    t.index ["user_id"], name: "index_tags_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.jsonb "tokens"
    t.string "firstname", default: "", null: false
    t.string "lastname", default: "", null: false
    t.date "birth_date"
    t.date "join_date"
    t.string "authentication_token"
    t.string "phone_number", default: "", null: false
    t.string "gender", default: "", null: false
    t.string "job_title", default: "", null: false
    t.string "linkedin", default: "", null: false
    t.integer "access_level", default: 0, null: false
    t.integer "status", default: 1, null: false
    t.string "timezone", default: "Europe/Paris"
    t.string "lang", default: "en"
    t.datetime "locked_at"
    t.integer "strikes_count", default: 0
    t.boolean "agreed_to_terms"
    t.jsonb "applications"
    t.jsonb "data"
    t.integer "current_application", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "country_code"
    t.string "username"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "allowlisted_jwts", "users", on_delete: :cascade
  add_foreign_key "blocks", "users", column: "blocked_id"
  add_foreign_key "blocks", "users", column: "blocker_id"
  add_foreign_key "blog_app_articles", "users"
  add_foreign_key "comments", "comments", column: "parent_id"
  add_foreign_key "comments", "users"
  add_foreign_key "follows", "users", column: "followed_id"
  add_foreign_key "follows", "users", column: "follower_id"
  add_foreign_key "lock_app_sensitive_infos", "users"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users"
  add_foreign_key "my_finance_app_expenses", "tags"
  add_foreign_key "my_finance_app_expenses", "tags", column: "subcategory_id"
  add_foreign_key "my_finance_app_expenses", "users"
  add_foreign_key "my_finance_app_loan_payments", "my_finance_app_loans", column: "loan_id"
  add_foreign_key "my_finance_app_loans", "tags"
  add_foreign_key "note_app_notes", "users", column: "owner_id"
  add_foreign_key "note_app_reminders", "note_app_notes", column: "note_id"
  add_foreign_key "note_app_reminders", "users"
  add_foreign_key "note_app_shares", "note_app_notes", column: "note_id"
  add_foreign_key "note_app_shares", "users", column: "shared_with_user_id"
  add_foreign_key "notes_tags", "note_app_notes", column: "note_id"
  add_foreign_key "taggings", "tags"
  add_foreign_key "tags", "tags", column: "parent_id"
  add_foreign_key "tags", "users"
end
