# Adds Directory Entry editing permissions

class AddDirectoryAdminPermission < ActiveRecord::Migration[5.1]
  def up
    add_column :users, :is_staff_directory_admin, :boolean, null: false, default: false
  end

  def down
    # Drop all tables
    remove_column :users, :is_staff_directory_admin
  end
end
