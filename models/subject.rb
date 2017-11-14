class Subject < ActiveRecord::Base
  has_many :library_subjects, :dependent => :destroy
  has_many :libraries, :through => :library_subjects

  default_scope { order('subject') }
end
