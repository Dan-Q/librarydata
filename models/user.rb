require 'bcrypt'

class User < ActiveRecord::Base
  include BCrypt

  has_many :library_users, dependent: :destroy
  has_many :libraries, through: :library_users
  
  validates :username, uniqueness: true

  def self.login(username, password)
    return false unless user = find_by_username(username)
    return user if user.password == password
    return user if user.temporary_password == password
    false
  end
  
  def password
    @password ||= Password.new(hashed_password)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.hashed_password = @password
    self.temporary_password = nil
  end

  def can_edit?(the_library)
    is_admin? || libraries.include?(the_library)
  end
  
  def editable_libaries
    (is_admin? ? Library : libraries)
  end
end
