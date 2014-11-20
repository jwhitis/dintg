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

ActiveRecord::Schema.define(version: 20141120012434) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "gigs", force: true do |t|
    t.decimal  "pay",        precision: 8, scale: 2
    t.text     "summary"
    t.text     "location"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "gigs", ["user_id"], name: "index_gigs_on_user_id", using: :btree

  create_table "tokens", force: true do |t|
    t.string   "access_token"
    t.string   "refresh_token"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "tokens", ["user_id"], name: "index_tokens_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",               default: "", null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider"
    t.string   "uid"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "calendar_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end