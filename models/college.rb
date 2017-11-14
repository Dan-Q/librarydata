class College < ActiveRecord::Base
  belongs_to :library

  default_scope { order('name') }
end
