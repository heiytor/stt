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

ActiveRecord::Schema[8.0].define(version: 2025_10_15_220148) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "endorsements", id: :binary, force: :cascade do |t|
    t.binary "policy_id", null: false
    t.date "data_emissao", null: false
    t.string "tipo", null: false
    t.bigint "importancia_segurada"
    t.date "inicio_vigencia"
    t.date "fim_vigencia"
    t.binary "cancelled_endorsement_id"
    t.binary "cancelled_by_endorsement_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cancelled_by_endorsement_id"], name: "index_endorsements_on_cancelled_by_endorsement_id"
    t.index ["cancelled_endorsement_id"], name: "index_endorsements_on_cancelled_endorsement_id"
    t.index ["policy_id"], name: "index_endorsements_on_policy_id"
  end

  create_table "policies", id: :binary, force: :cascade do |t|
    t.string "numero", null: false
    t.date "data_emissao", null: false
    t.date "inicio_vigencia", null: false
    t.date "fim_vigencia", null: false
    t.bigint "importancia_segurada", null: false
    t.bigint "lmg", null: false
    t.string "status", default: "ATIVA", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "endorsements", "endorsements", column: "cancelled_by_endorsement_id"
  add_foreign_key "endorsements", "endorsements", column: "cancelled_endorsement_id"
  add_foreign_key "endorsements", "policies"
end
