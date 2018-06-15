# (Staff) Directory entry

class DirectoryEntry < ActiveRecord::Base
  serialize :email_addresses, JSON
  serialize :phone_numbers, JSON
  serialize :addresses, JSON
  serialize :workplaces, JSON
end
