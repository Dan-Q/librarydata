class AlternativeName < ActiveRecord::Base
  belongs_to :library

  # Types of Alternative Name: 1 = also known as or contains, 2 = was formerly known as, 3 = (just a cross reference), 4 = supercedes
  # New option "also listed as" (5) supports 2012-2013 redevelopment
  ALSO_KNOWN_AS_OR_CONTAINS = 1
  WAS_FORMERLY_KNOWN_AS     = 2
  CROSS_REFERENCE           = 3
  SUPERCEDES                = 4
  ALSO_LISTED_AS            = 5

  default_scope { where('type_of_alternative_name = 5') }

  include JsonFromXml
  def to_xml(options = {})
    require 'builder'
    options[:indent] ||= 2
    xml = options[:builder] ||= ::Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.alternative_name do
      xml.id            self.id
      xml.library_id    self.library_id
      xml.type          self.type_of_alternative_name
    end
  end
end
