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

ActiveRecord::Schema.define(version: 20171114185355) do

  create_table "alternative_names", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "name"
    t.integer "library_id"
    t.integer "type_of_alternative_name"
    t.boolean "show_in_group"
  end

  create_table "colleges", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "name"
    t.integer "library_id"
  end

  create_table "courses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "name"
  end

  create_table "libraries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "name"
    t.boolean "name_overrides_olis"
    t.integer "name_order"
    t.boolean "name_is_site_name"
    t.integer "calculate_library_institution_name"
    t.integer "map_key_includes_this_name"
    t.string "map_p_vtype"
    t.integer "map_p_vnumber"
    t.string "map_p_vsquare"
    t.integer "map_normal_blob_number"
    t.decimal "map_normal_blob_x", precision: 5, scale: 2
    t.decimal "map_normal_blob_y", precision: 5, scale: 2
    t.string "map_normal_off_map_dir"
    t.string "address1"
    t.string "address2"
    t.string "address3"
    t.string "town_city"
    t.string "post_code"
    t.string "telephone"
    t.string "fax"
    t.string "email"
    t.string "website"
    t.string "map_reference"
    t.integer "library_type"
    t.text "library_type_notes"
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
    t.integer "last_update"
    t.string "last_modified_user"
    t.text "facebook"
    t.text "twitter"
    t.text "blog"
    t.text "library_thing"
    t.text "delicious"
    t.integer "scheduled_for_deletion"
    t.integer "site_id"
    t.decimal "lat", precision: 20, scale: 16
    t.decimal "lng", precision: 20, scale: 16
    t.boolean "not_on_web_site"
    t.string "library_group"
    t.integer "oxpoints_id"
  end

  create_table "library_courses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "library_id"
    t.integer "course_id"
  end

  create_table "library_subjects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "subject_id"
    t.integer "library_id"
  end

  create_table "library_users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "library_id"
    t.integer "user_id"
  end

  create_table "non_library_links", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.text "html"
  end

  create_table "opening_hours", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "library_id"
    t.string "period"
    t.integer "wday"
    t.string "open"
    t.string "close"
  end

  create_table "sites", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "name"
  end

  create_table "social_links", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "library_id"
    t.string "network"
    t.string "url"
    t.integer "position"
  end

  create_table "staffs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "library_id"
    t.string "job_title"
    t.string "name_of_person"
    t.integer "list_order"
  end

  create_table "subjects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "subject"
  end

  create_table "term_dates", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "name"
    t.date "start_date"
    t.date "end_date"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "username"
    t.string "temporary_password"
    t.string "hashed_password"
    t.boolean "is_admin"
  end

end
