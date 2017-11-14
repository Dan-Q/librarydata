class TermDate < ActiveRecord::Base
  default_scope { order('start_date') }
  scope :started_in_past, -> { where('start_date <= ?', Date::today) }
  scope :finishes_in_future, -> { where('end_date >= ?', Date::today) }
  scope :starts_in_future, -> { where('start_date > ?', Date::today) }

  def self.current
    @current ||= self.started_in_past.finishes_in_future.first
  end

  def self.next
    @next ||= self.starts_in_future.first
  end

  def self.is_termtime?
    !self.current.nil?
  end

  include JsonFromXml
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= ::Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.term do
      xml.name          self.name
      xml.start_date    self.start_date
      xml.end_date      self.end_date
    end
  end
end
