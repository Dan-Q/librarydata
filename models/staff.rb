class Staff < ActiveRecord::Base
  belongs_to :library
  
  default_scope { order('list_order') }
end
