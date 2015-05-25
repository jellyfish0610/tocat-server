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

ActiveRecord::Schema.define(version: 20150525165213) do

  create_table "accounts", force: :cascade do |t|
    t.string   "account_type",     limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "accountable_id",   limit: 4,   null: false
    t.string   "accountable_type", limit: 255, null: false
  end

  add_index "accounts", ["accountable_id"], name: "index_accounts_on_accountable_id", using: :btree

  create_table "invoices", force: :cascade do |t|
    t.string   "client",      limit: 255
    t.string   "external_id", limit: 255
    t.boolean  "paid",        limit: 1,   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "order_id",    limit: 255
  end

  add_index "invoices", ["client"], name: "index_invoices_on_client", using: :btree
  add_index "invoices", ["order_id"], name: "index_invoices_on_order_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.string   "name",               limit: 255,                                            null: false
    t.text     "description",        limit: 65535
    t.boolean  "paid",               limit: 1,                              default: false
    t.integer  "team_id",            limit: 4,                                              null: false
    t.integer  "invoice_id",         limit: 4
    t.decimal  "invoiced_budget",                  precision: 10, scale: 2,                 null: false
    t.decimal  "allocatable_budget",               precision: 10, scale: 2,                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id",          limit: 4
    t.decimal  "free_budget",                      precision: 10, scale: 2,                 null: false
    t.boolean  "completed",          limit: 1,                              default: false
  end

  add_index "orders", ["team_id"], name: "index_orders_on_team_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "selfcheckreports", force: :cascade do |t|
    t.text     "messages",   limit: 65535, null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "task_orders", force: :cascade do |t|
    t.integer  "task_id",    limit: 4,                          null: false
    t.integer  "order_id",   limit: 4,                          null: false
    t.decimal  "budget",               precision: 10, scale: 2, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tasks", force: :cascade do |t|
    t.string   "external_id", limit: 255,                                         null: false
    t.integer  "user_id",     limit: 4
    t.boolean  "accepted",    limit: 1,                           default: false
    t.boolean  "paid",        limit: 1,                           default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "budget",                  precision: 8, scale: 2, default: 0.0
  end

  add_index "tasks", ["external_id"], name: "index_tasks_on_external_id", using: :btree
  add_index "tasks", ["user_id"], name: "index_tasks_on_user_id", using: :btree

  create_table "teams", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "timesheets", force: :cascade do |t|
    t.integer  "sp_id",           limit: 4, null: false
    t.integer  "user_id",         limit: 4, null: false
    t.datetime "start_timestamp",           null: false
    t.datetime "end_timestamp",             null: false
    t.integer  "in_day",          limit: 4, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.decimal  "total",                  precision: 10, scale: 2, null: false
    t.string   "comment",    limit: 255,                          null: false
    t.integer  "account_id", limit: 4,                            null: false
    t.integer  "user_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "transactions", ["comment"], name: "index_transactions_on_comment", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",       limit: 255,                         null: false
    t.string   "login",      limit: 255,                         null: false
    t.integer  "team_id",    limit: 4,                           null: false
    t.decimal  "daily_rate",             precision: 5, scale: 2, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role_id",    limit: 4,                           null: false
  end

end
