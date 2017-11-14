class EncryptPasswords < ActiveRecord::Migration[5.1]
  def up
    require './models/user.rb'
    print "Encrypting passwords: "
    User.where('temporary_password IS NOT NULL AND temporary_password <> ?', '').all.each do |user|
      print '.'
      user.password = user.temporary_password
      user.save
    end
    print "\n"
  end

  def down
    # Do nothing
  end
end
