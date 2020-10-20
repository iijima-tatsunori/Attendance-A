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

ActiveRecord::Schema.define(version: 20201008053351) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "finished_plan_at"
    t.string "business_process_content"
    t.string "instructor_confirmation"
    t.string "apploval_confirmation"
    t.string "next_day", default: "0"
    t.string "overtime_hours"
    t.string "overtime_superior_name"
    t.string "overtime_status"
    t.integer "overtime_apploval", default: 1
    t.string "overtime_detail"
    t.string "overtime_check", default: "1"
    t.integer "overtime_superior_id"
    t.integer "superior_id"
    t.string "status"
    t.datetime "month_apply"
    t.integer "month_approval", default: 1
    t.string "month_check", default: "0"
    t.string "superior_name"
    t.string "change_superior_name"
    t.datetime "changed_started_at"
    t.datetime "changed_finished_at"
    t.string "change_next_day", default: "0"
    t.integer "change_superior_id"
    t.string "change_status"
    t.string "change_check", default: "0"
    t.integer "change_approval", default: 1
    t.date "calendar_day"
    t.datetime "approval_date"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "bases", force: :cascade do |t|
    t.integer "base_number"
    t.string "base_name"
    t.string "attendance_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "department"
    t.datetime "basic_time", default: "2020-10-11 23:00:00"
    t.datetime "work_time", default: "2020-10-11 22:30:00"
    t.string "affiliation"
    t.integer "employee_number"
    t.string "uid"
    t.datetime "basic_work_time", default: "2020-10-11 23:00:00"
    t.datetime "designated_work_start_time", default: "2020-10-12 01:00:00"
    t.datetime "designated_work_end_time", default: "2020-10-12 09:00:00"
    t.boolean "superior", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
