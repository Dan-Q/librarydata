class Course < ActiveRecord::Base
  has_many :library_courses, :dependent => :destroy
  has_many :libraries, :through => :library_courses

  default_scope { order('name') }
end
