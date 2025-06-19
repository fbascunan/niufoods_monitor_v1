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

ActiveRecord::Schema[7.1].define(version: 2025_06_19_204634) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "devices", force: :cascade do |t|
    t.bigint "restaurant_id", null: false
    t.string "device_type", null: false
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_check_in_at"
    t.string "name"
    t.string "model"
    t.string "serial_number"
    t.index ["id"], name: "index_devices_on_id"
    t.index ["restaurant_id"], name: "index_devices_on_restaurant_id"
    t.index ["serial_number"], name: "index_devices_on_serial_number"
    t.index ["status"], name: "index_devices_on_status"
  end

  create_table "maintenance_logs", force: :cascade do |t|
    t.bigint "device_id", null: false
    t.datetime "performed_at", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "pending"
    t.index ["device_id", "performed_at"], name: "index_maintenance_logs_on_device_id_and_performed_at", order: { performed_at: :desc }
    t.index ["device_id"], name: "index_maintenance_logs_on_device_id"
    t.index ["performed_at"], name: "index_maintenance_logs_on_performed_at", order: :desc
  end

  create_table "restaurants", force: :cascade do |t|
    t.string "name", null: false
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "location"
    t.string "address"
    t.string "phone"
    t.string "email"
    t.string "timezone"
    t.index ["name"], name: "index_restaurants_on_name", unique: true
    t.index ["status"], name: "index_restaurants_on_status"
  end

  add_foreign_key "devices", "restaurants"
  add_foreign_key "maintenance_logs", "devices"
end
