class LibraryUser < ActiveRecord::Base
  belongs_to :library
  belongs_to :user
  
  validates :user, :uniqueness => { :scope => :library }
end
