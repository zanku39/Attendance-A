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

ActiveRecord::Schema.define(version: 20200605013135) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "before_started_at"
    t.datetime "before_finished_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "change_started_at"
    t.datetime "change_finished_at"
    t.string "note"
    t.datetime "scheduled_end_time"
    t.boolean "next_day"
    t.boolean "tomorrow"
    t.boolean "day_after"
    t.string "business_outline"
    t.string "confirmation"
    t.string "change_confirmation"
    t.boolean "fix", default: false
    t.string "status"
    t.string "change_status"
    t.date "change_date"
    t.string "month_confirmation"
    t.string "month_status"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "offices", force: :cascade do |t|
    t.integer "base_number"
    t.string "base", default: "拠点A"
    t.string "work", default: "出勤"
    t.string "budget_d"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.integer "employee_number"
    t.string "uid"
    t.string "affiliation"
    t.time "basic_work_time", default: "2000-01-01 23:00:00"
    t.time "designated_work_start_time", default: "2000-01-01 00:00:00"
    t.time "designated_work_end_time", default: "2000-01-01 09:00:00"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "superior", default: false
    t.boolean "admin", default: false
    t.string "password_digest"
    t.string "remember_digest"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
