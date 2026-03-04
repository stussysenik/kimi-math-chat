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

ActiveRecord::Schema[8.1].define(version: 2026_03_04_214755) do
  create_table "conversations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "model_id", default: "moonshotai/kimi-k2-instruct"
    t.string "session_id"
    t.text "system_prompt"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "messages", force: :cascade do |t|
    t.boolean "contains_math", default: false
    t.text "content"
    t.integer "conversation_id", null: false
    t.datetime "created_at", null: false
    t.json "metadata"
    t.integer "role"
    t.boolean "streaming", default: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
  end

  create_table "verifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error_message"
    t.float "execution_time_ms"
    t.text "input_expression"
    t.integer "message_id", null: false
    t.text "result"
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.string "verifier"
    t.index ["message_id"], name: "index_verifications_on_message_id"
  end

  add_foreign_key "messages", "conversations"
  add_foreign_key "verifications", "messages"
end
