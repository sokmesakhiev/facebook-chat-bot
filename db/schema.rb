# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20190725074646) do

  create_table "aggregations", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.decimal  "score_from",             precision: 10
    t.decimal  "score_to",               precision: 10
    t.string   "result",     limit: 255
    t.integer  "bot_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bots", force: :cascade do |t|
    t.string   "name",                       limit: 255
    t.integer  "user_id",                    limit: 4
    t.string   "facebook_page_id",           limit: 255
    t.string   "facebook_page_access_token", limit: 255
    t.string   "google_access_token",        limit: 255
    t.datetime "google_token_expires_at"
    t.string   "google_refresh_token",       limit: 255
    t.string   "google_spreadsheet_key",     limit: 255
    t.string   "google_spreadsheet_title",   limit: 255
    t.boolean  "published",                                default: false
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.string   "restart_msg",                limit: 255
    t.text     "greeting_msg",               limit: 65535
  end

  create_table "choices", force: :cascade do |t|
    t.integer  "question_id", limit: 4
    t.string   "name",        limit: 255
    t.string   "label",       limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "questions", force: :cascade do |t|
    t.integer  "bot_id",      limit: 4
    t.string   "type",        limit: 255
    t.string   "select_name", limit: 255
    t.string   "name",        limit: 255
    t.text     "label",       limit: 65535
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "media_image", limit: 255
    t.text     "description", limit: 65535
    t.boolean  "required",                  default: false
    t.string   "uuid",        limit: 255
    t.text     "relevants",   limit: 65535
  end

  add_index "questions", ["bot_id", "name"], name: "index_questions_on_bot_id_and_name", unique: true, using: :btree

  create_table "respondents", force: :cascade do |t|
    t.string   "user_session_id",     limit: 255
    t.integer  "current_question_id", limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "bot_id",              limit: 4
    t.integer  "version",             limit: 4
    t.string   "state",               limit: 255
  end

  create_table "surveys", force: :cascade do |t|
    t.integer  "question_id",   limit: 4
    t.string   "value",         limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "respondent_id", limit: 4
  end

  add_index "surveys", ["question_id", "respondent_id"], name: "index_surveys_on_question_id_and_respondent_id", unique: true, using: :btree
  add_index "surveys", ["respondent_id"], name: "index_surveys_on_respondent_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "provider",               limit: 255
    t.string   "uid",                    limit: 255
    t.string   "name",                   limit: 255
    t.string   "oauth_token",            limit: 255
    t.datetime "oauth_expires_at"
    t.boolean  "published",                          default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                  limit: 255, default: "",   null: false
    t.string   "encrypted_password",     limit: 255, default: "",   null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,    null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "role",                   limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
