require 'fileutils'

class Import < ActiveRecord::Migration[5.1]
  TABLES = %w{alternative_names  library_courses    opening_hours  subjects
             colleges            library_subjects   sites          term_dates
             courses             library_users      social_links   users
             libraries           non_library_links  staffs}

  def up
    # export tables from sqlite
    FileUtils::mkdir('db/import') unless File::directory?('db/import')
    TABLES.each do |table|
      `echo -e ".mode csv\n.output db/import/#{table}.csv\nSELECT * FROM #{table};" | sqlite3 db/librarydata.db`
      `sed -Ei 's/[\\r\\n]+/,/g' db/import/#{table}.csv` # append a comma to each line; solves some import problems
    end
    # create new schema
    unless table_exists? :alternative_names
      create_table :alternative_names do |t|
        t.string :name
        t.integer :library_id
        t.integer :type_of_alternative_name
        t.boolean :show_in_group
      end
    end
    unless table_exists? :library_courses
      create_table :library_courses do |t|
        t.integer :library_id
        t.integer :course_id
      end
    end
    unless table_exists? :opening_hours
      create_table :opening_hours do |t|
        t.integer :library_id
        t.string :period
        t.integer :wday
        t.string :open
        t.string :close
      end
    end
    unless table_exists? :subjects
      create_table :subjects do |t|
        t.string :subject
      end
    end
    unless table_exists? :colleges
      create_table :colleges do |t|
        t.string :name
        t.integer :library_id
      end
    end
    unless table_exists? :library_subjects
      create_table :library_subjects do |t|
        t.integer :subject_id
        t.integer :library_id
      end
    end
    unless table_exists? :sites
      create_table :sites do |t|
        t.string :name
      end
    end
    unless table_exists? :term_dates
      create_table :term_dates do |t|
        t.string :name
        t.date :start_date
        t.date :end_date
      end
    end
    unless table_exists? :courses
      create_table :courses do |t|
        t.string :name
      end
    end
    unless table_exists? :library_users
      create_table :library_users do |t|
        t.integer :library_id
        t.integer :user_id
      end
    end
    unless table_exists? :social_links
      create_table :social_links do |t|
        t.integer :library_id
        t.string :network
        t.string :url
        t.integer :position
      end
    end
    unless table_exists? :users
      create_table :users do |t|
        t.string :username
        t.string :temporary_password
        t.string :hashed_password
        t.boolean :is_admin
      end
    end
    unless table_exists? :libraries
      create_table :libraries do |t|
        t.string :name
        t.boolean :name_overrides_olis 
        t.integer :name_order 
        t.boolean :name_is_site_name
        t.integer :calculate_library_institution_name 
        t.integer :map_key_includes_this_name 
        t.string :map_p_vtype
        t.integer :map_p_vnumber 
        t.string :map_p_vsquare
        t.integer :map_normal_blob_number 
        t.decimal :map_normal_blob_x, precision: 5, scale: 2
        t.decimal :map_normal_blob_y, precision: 5, scale: 2
        t.string :map_normal_off_map_dir
        t.string :address1
        t.string :address2
        t.string :address3
        t.string :town_city
        t.string :post_code
        t.string :telephone
        t.string :fax
        t.string :email
        t.string :website
        t.string :map_reference
        t.integer :library_type 
        t.text :library_type_notes, limit: 1024
        t.text :subject_notes, limit: 1024
        t.integer :ug_access 
        t.integer :ug_borrowing 
        t.text :ug_notes, limit: 1024
        t.integer :pg_access 
        t.integer :pg_borrowing 
        t.text :pg_notes, limit: 1024
        t.integer :academic_access 
        t.integer :academic_borrowing 
        t.text :academic_notes, limit: 1024
        t.integer :other_access 
        t.integer :other_borrowing 
        t.text :other_notes, limit: 1024
        t.text :term_hours, limit: 1024
        t.text :vacation_hours, limit: 1024
        t.text :closed_periods, limit: 1024
        t.text :hours_notes, limit: 1024
        t.text :extra_notes, limit: 1024
        t.string :admin_name
        t.string :admin_email
        t.integer :last_update 
        t.string :last_modified_user
        t.text :facebook
        t.text :twitter
        t.text :blog
        t.text :library_thing
        t.text :delicious
        t.integer :scheduled_for_deletion 
        t.integer :site_id 
        t.decimal :lat, precision: 20, scale: 16
        t.decimal :lng, precision: 20, scale: 16
        t.boolean :not_on_web_site
        t.string :library_group
        t.integer :oxpoints_id
      end
    end
    unless table_exists? :non_library_links
      create_table :non_library_links do |t|
        t.text :html, limit: 4096
      end
    end
    unless table_exists? :staffs
      create_table :staffs do |t|
        t.integer :library_id
        t.string :job_title
        t.string :name_of_person
        t.integer :list_order
      end
    end
    # import data
    TABLES.each do |table|
      execute "LOAD DATA LOCAL INFILE '#{Dir::pwd}/db/import/#{table}.csv' INTO TABLE #{table}
                 FIELDS TERMINATED BY ','
                 ENCLOSED BY '\"'
                 LINES TERMINATED BY '\n'
              "
    end
  end

  def down
    # Drop all tables
    drop_table :alternative_names if table_exists? :alternative_names
    drop_table :library_courses if table_exists? :library_courses
    drop_table :opening_hours if table_exists? :opening_hours
    drop_table :subjects if table_exists? :subjects
    drop_table :colleges if table_exists? :colleges
    drop_table :library_subjects if table_exists? :library_subjects
    drop_table :sites if table_exists? :sites
    drop_table :term_dates if table_exists? :term_dates
    drop_table :courses if table_exists? :courses
    drop_table :library_users if table_exists? :library_users
    drop_table :social_links if table_exists? :social_links
    drop_table :users if table_exists? :users
    drop_table :libraries if table_exists? :libraries
    drop_table :non_library_links if table_exists? :non_library_links
    drop_table :staffs if table_exists? :staffs
  end
end
