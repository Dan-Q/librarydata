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

ActiveRecord::Schema.define(version: 2018_06_15_154702) do

  create_table "alternative_names", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.integer "library_id"
    t.integer "type_of_alternative_name"
    t.boolean "show_in_group"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "colleges", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.integer "library_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "courses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "directory_entries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "surname"
    t.string "forename"
    t.string "known_as"
    t.string "job_title"
    t.text "email_addresses", limit: 16777215
    t.text "phone_numbers", limit: 16777215
    t.text "addresses", limit: 16777215
    t.text "workplaces", limit: 16777215
    t.integer "old_contact_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "libraries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.text "address"
    t.string "town_city"
    t.string "post_code"
    t.string "telephone"
    t.string "fax"
    t.string "email"
    t.string "website"
    t.text "subject_notes"
    t.integer "ug_access"
    t.integer "ug_borrowing"
    t.text "ug_notes"
    t.integer "pg_access"
    t.integer "pg_borrowing"
    t.text "pg_notes"
    t.integer "academic_access"
    t.integer "academic_borrowing"
    t.text "academic_notes"
    t.integer "other_access"
    t.integer "other_borrowing"
    t.text "other_notes"
    t.text "term_hours"
    t.text "vacation_hours"
    t.text "closed_periods"
    t.text "hours_notes"
    t.text "extra_notes"
    t.string "admin_name"
    t.string "admin_email"
    t.boolean "scheduled_for_deletion", default: false, null: false
    t.integer "site_id"
    t.decimal "lat", precision: 20, scale: 16
    t.decimal "lng", precision: 20, scale: 16
    t.string "library_group"
    t.integer "oxpoints_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "library_courses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "library_id"
    t.integer "course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "library_subjects", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "subject_id"
    t.integer "library_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "library_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "library_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "non_library_links", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "html"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "opening_hours", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "library_id"
    t.string "period"
    t.integer "wday"
    t.string "open"
    t.string "close"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sites", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "social_links", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "library_id"
    t.string "network"
    t.string "url"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "staffs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "library_id"
    t.string "job_title"
    t.string "name_of_person"
    t.integer "list_order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subjects", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "subject"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "term_dates", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "username"
    t.string "temporary_password"
    t.string "hashed_password"
    t.boolean "is_admin"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_staff_directory_admin", default: false, null: false
  end

end
