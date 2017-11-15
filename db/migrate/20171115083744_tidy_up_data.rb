class TidyUpData < ActiveRecord::Migration[5.1]
  TABLES = %w{alternative_names  library_courses    opening_hours  subjects
             colleges            library_subjects   sites          term_dates
             courses             library_users      social_links   users
             libraries           non_library_links  staffs}

  def up
    # Add (and populate where possible) timestamps
    TABLES.each do |table|
      add_column table, :created_at, :datetime
      add_column table, :updated_at, :datetime
    end

    # Combine address fields
    add_column :libraries, :address, :text, limit: 1024, after: :address3
    execute 'UPDATE libraries SET address=TRIM(REPLACE(CONCAT(address1, "\n", address2, "\n", address3), "\n\n", "\n"))'

    # Drop records scheduled for deletion or otherwise unusable
    execute 'DELETE FROM libraries WHERE scheduled_for_deletion = 1 OR not_on_web_site = 1'
    execute 'DELETE FROM alternative_names WHERE library_id IN (SELECT id FROM libraries WHERE calculate_library_institution_name = 2)'

    # Convert integers that should be booleans
    change_column :libraries, :scheduled_for_deletion, :boolean, null: false, default: false

    # Drop meaningless/obsolete columns
    remove_columns :libraries, :name_overrides_olis, :name_order, :name_is_site_name,
                               :map_key_includes_this_name, :map_p_vtype, :map_p_vnumber, :map_p_vsquare, :map_normal_blob_number,
                               :map_normal_blob_x, :map_normal_blob_y, :map_normal_off_map_dir, :map_reference,
                               :address1, :address2, :address3,
                               :library_type, :library_type_notes,
                               :last_update, :last_modified_user,
                               :facebook, :twitter, :blog, :library_thing, :delicious,
                               :not_on_web_site, :calculate_library_institution_name

    # Trim excess whitespace from text field content
    changes = %w{subject_notes ug_notes pg_notes academic_notes other_notes term_hours vacation_hours closed_periods hours_notes extra_notes}.map do |field|
      "#{field}=TRIM(#{field})"
    end
    execute "UPDATE libraries SET #{changes.join(',')}"

    # Nullify 'zero is nothing' etc. fields
    execute "UPDATE colleges SET library_id = NULL where library_id = 0"
  end

  def down
    # Do nothing
    raise "Unable to reverse the Tidy Up Data migration."
  end
end
