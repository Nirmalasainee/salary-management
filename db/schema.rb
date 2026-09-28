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

ActiveRecord::Schema[8.0].define(version: 2026_09_28_072832) do
  create_table "countries", force: :cascade do |t|
    t.string "name", null: false
    t.string "currency_code", limit: 3, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_countries_on_name", unique: true
  end

  create_table "departments", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_departments_on_name", unique: true
  end

  create_table "employees", force: :cascade do |t|
    t.string "employee_number", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.integer "country_id", null: false
    t.integer "department_id", null: false
    t.integer "job_level_id", null: false
    t.integer "manager_id"
    t.date "hire_date", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id", "status"], name: "index_employees_on_country_id_and_status"
    t.index ["country_id"], name: "index_employees_on_country_id"
    t.index ["department_id", "status"], name: "index_employees_on_department_id_and_status"
    t.index ["department_id"], name: "index_employees_on_department_id"
    t.index ["email"], name: "index_employees_on_email", unique: true
    t.index ["employee_number"], name: "index_employees_on_employee_number", unique: true
    t.index ["job_level_id"], name: "index_employees_on_job_level_id"
    t.index ["manager_id"], name: "index_employees_on_manager_id"
  end

  create_table "job_levels", force: :cascade do |t|
    t.string "name", null: false
    t.integer "rank", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rank"], name: "index_job_levels_on_rank", unique: true
  end

  add_foreign_key "employees", "countries"
  add_foreign_key "employees", "departments"
  add_foreign_key "employees", "employees", column: "manager_id"
  add_foreign_key "employees", "job_levels"
end
