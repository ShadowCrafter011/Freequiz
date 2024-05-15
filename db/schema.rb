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

ActiveRecord::Schema[7.1].define(version: 2024_05_15_144402) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "bug_reports", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.string "platform"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.string "url"
    t.string "user_agent"
    t.string "created_from"
    t.text "steps"
    t.string "ip"
    t.string "request_method"
    t.string "media_type"
    t.string "post_parameters"
    t.index ["user_id"], name: "index_bug_reports_on_user_id"
  end

  create_table "languages", force: :cascade do |t|
    t.string "name"
    t.string "locale"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "quizzes", force: :cascade do |t|
    t.string "uuid", null: false
    t.text "description"
    t.string "visibility"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "from"
    t.bigint "to"
    t.string "title"
    t.integer "translations_count", default: 0
    t.index ["user_id"], name: "index_quizzes_on_user_id"
    t.index ["uuid"], name: "index_quizzes_on_uuid", unique: true
  end

  create_table "scores", force: :cascade do |t|
    t.integer "cards"
    t.integer "learn"
    t.integer "write"
    t.bigint "quiz_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_id"], name: "index_scores_on_quiz_id"
    t.index ["user_id"], name: "index_scores_on_user_id"
  end

  create_table "settings", force: :cascade do |t|
    t.boolean "dark_mode"
    t.boolean "show_email"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "locale", default: "de"
    t.index ["user_id"], name: "index_settings_on_user_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.float "amount"
    t.text "description"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "removed", default: false
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "translations", force: :cascade do |t|
    t.string "word"
    t.string "translation"
    t.bigint "quiz_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_id"], name: "index_translations_on_quiz_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "username"
    t.string "password"
    t.string "role"
    t.boolean "agb"
    t.string "unconfirmed_email"
    t.boolean "confirmed"
    t.datetime "confirmed_at"
    t.integer "sign_in_count"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "bug_reports", "users"
  add_foreign_key "quizzes", "users"
  add_foreign_key "scores", "quizzes"
  add_foreign_key "scores", "users"
  add_foreign_key "settings", "users"
  add_foreign_key "transactions", "users"
  add_foreign_key "translations", "quizzes"
end
