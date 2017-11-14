class User < ActiveRecord::Base
  has_many :library_users, dependent: :destroy
  has_many :libraries, through: :library_users
  
  validates :username, uniqueness: true

  def self.login(username, password)
    find_by_username_and_temporary_password(username, password)
  end
  
  def password=(new_password)
    self.temporary_password = new_password
  end
  
  def can_edit?(the_library)
    is_admin? || libraries.include?(the_library)
  end
  
  def editable_libaries
    (is_admin? ? Library : libraries)
  end
end
