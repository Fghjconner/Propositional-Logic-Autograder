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

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
ActiveRecord::Schema.define(version: 20180206223123) do

  create_table "input_mappings", force: :cascade do |t|
    t.string "outbound"
    t.string "mapping"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
=======
ActiveRecord::Schema.define(version: 20180222003745) do
>>>>>>> induction
=======
ActiveRecord::Schema.define(version: 20180223180708) do
>>>>>>> induction
=======
ActiveRecord::Schema.define(version: 20180223234930) do
>>>>>>> induction

  create_table "latex_mappings", force: :cascade do |t|
    t.string "latex"
    t.string "mapping"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
=======
ActiveRecord::Schema.define(version: 20180109072627) do
>>>>>>> induction

  create_table "practice_problems", force: :cascade do |t|
    t.string "problem_uid"
    t.string "premises"
    t.string "conclusion"
    t.string "category_uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_uid"], name: "index_practice_problems_on_category_uid"
    t.index ["problem_uid"], name: "index_practice_problems_on_problem_uid"
  end

  create_table "problem_categories", force: :cascade do |t|
    t.string "category_uid"
    t.string "category_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category_description"
    t.index ["category_uid"], name: "index_problem_categories_on_category_uid"
  end

  create_table "profile_problem_junctions", force: :cascade do |t|
    t.string "profile_uid"
    t.string "problem_uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_uid"], name: "index_profile_problem_junctions_on_profile_uid"
  end

  create_table "users", force: :cascade do |t|
    t.string "provider"
    t.string "uid"
    t.string "name"
    t.string "email"
    t.string "oauth_token"
    t.datetime "oauth_expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_seen"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "correct"
    t.integer "num_correct"
    t.integer "num_attempt"
    t.string "section"
    t.string "image"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
