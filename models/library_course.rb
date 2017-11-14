class LibraryCourse < ActiveRecord::Base
  belongs_to :course
  belongs_to :library
end
