class LibrarySubject < ActiveRecord::Base
  belongs_to :library
  belongs_to :subject
end
