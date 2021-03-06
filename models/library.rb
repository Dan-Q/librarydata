class Library < ActiveRecord::Base
  belongs_to :site
  has_many :staffs, :dependent => :destroy
  has_many :alternative_names, :dependent => :destroy
  has_many :library_subjects, :dependent => :destroy
  has_many :subjects, :through => :library_subjects
  has_many :library_courses, :dependent => :destroy
  has_many :courses, :through => :library_courses
  has_many :library_users, :dependent => :destroy
  has_many :users, :through => :library_users
  has_many :opening_hours, :dependent => :destroy
  has_many :social_links, :dependent => :destroy
  has_one :college # if it's a college library
  
  default_scope { order('name').where(scheduled_for_deletion: false).includes(:opening_hours) }
  scope :with_opening_hours, -> { where("(vacation_hours IS NOT NULL AND vacation_hours <> '') OR (closed_periods IS NOT NULL AND closed_periods <> '') OR (hours_notes IS NOT NULL AND hours_notes <> '')") }

  after_save :build_static_pages
  # TODO: after_save :deploy_static_pages, if: :some_condition?

  attr_accessor :opening_hours_collection

  def opening_hours_collection=(value)
    %w{Michaelmas Hilary Trinity Christmas Easter Summer}.each do |period|
      7.times do |wday|
        if hours = value[period][wday.to_s]
          oh = self.opening_hours.select{|o| o.period == period && o.wday == wday}.first || self.opening_hours.build(:period => period, :wday => wday)
          oh.open, oh.close = hours['open'], hours['close']
          oh.save
        end
      end
    end
  end

  include JsonFromXml
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= ::Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.library do
      xml.id            self.id
      xml.name          self.name
      if self.site
        xml.site do
          xml.id        self.site.id
          xml.name      self.site.name
        end
      end
      xml.address do
        xml.address1    self.address
        xml.town        self.town_city
        xml.postcode    self.post_code
      end
      xml.telephone     self.telephone
      xml.fax           self.fax
      xml.email         self.email
      xml.web do
        %w{Website Facebook Twitter Blog LibraryThing Delicious}.each do |w|
          xml.website({:category => w}, self.attributes[w]) unless self.attributes[w].blank?
        end
      end
      xml.hours do
        xml.termtime    self.term_hours
        xml.vacation    self.vacation_hours
        xml.closed      self.closed_periods
        xml.notes       self.hours_notes
      end
      xml.policies do
        xml.policy(:for => 'undergraduate') do
          xml.access    self.ug_access
          xml.borrowing self.ug_borrowing
          xml.notes     self.ug_notes
        end
        xml.policy(:for => 'postgraduate') do
          xml.access    self.pg_access
          xml.borrowing self.pg_borrowing
          xml.notes     self.pg_notes
        end
        xml.policy(:for => 'academic') do
          xml.access    self.academic_access
          xml.borrowing self.academic_borrowing
          xml.notes     self.academic_notes
        end
        xml.policy(:for => 'other') do
          xml.access    self.other_access
          xml.borrowing self.other_borrowing
          xml.notes     self.other_notes
        end
      end
      xml.subjects do
      self.subjects.collect{|s| xml.subject({:id => s.id}, s.subject) }
        xml.notes self.subject_notes
      end
      xml.geo do
        xml.lat self.lat
        xml.lng self.lng
      end
    end
  end

  def url(format = nil)
    "/libraries/#{self.id}#{format ? ".#{format}" : ''}"
  end
  
  def address_lines
    [self.name, self.address, self.town_city, self.post_code].reject(&:blank?)
  end
  
  def borrowing_policy_html(category, level)
    return '<img src="/images/borrowing_policies/1.gif" alt="All" width="18" height="18"> all' if attributes["#{category}_#{level}"] == 1
    return '<img src="/images/borrowing_policies/2.gif" alt="Some" width="18" height="18"> some' if attributes["#{category}_#{level}"] == 2
    return '<img src="/images/borrowing_policies/3.gif" alt="None" width="18" height="18"> none' if attributes["#{category}_#{level}"] == 3
  end
  
  def borrowing_policies_html(category)
    result = "<p>Admissions: #{borrowing_policy_html(category, 'access')}. Borrowing: #{borrowing_policy_html(category, 'borrowing')}.</p>"
    result += Rack::Utils::escape_html(attributes["#{category}_notes"]) unless attributes["#{category}_notes"].blank?
    result
  end
  
  # Types of Alternative name: 1 = also known as or contains, 2 = was formerly known as, 3 = (just a cross reference), 4 = supercedes, 5 = [new] also listed as
  def alternative_names_html(options = {})
    results = []
    unless (also_known_as_or_contains = self.alternative_names.where('type_of_alternative_name = ? OR type_of_alternative_name = ?', AlternativeName::ALSO_KNOWN_AS_OR_CONTAINS, AlternativeName::ALSO_LISTED_AS).all.collect{|an|Rack::Utils::escape_html(an.name)}.join(', ')).blank?
      results << "is also known as or contains: #{also_known_as_or_contains}"
    end
    unless (supercedes = self.alternative_names.where('type_of_alternative_name' => AlternativeName::SUPERCEDES).all.collect{|an|Rack::Utils::escape_html(an.name)}.join(', ')).blank?
      results <<  "supercedes: #{supercedes}"
    end
    unless (formerly_known_as = self.alternative_names.where('type_of_alternative_name' => AlternativeName::WAS_FORMERLY_KNOWN_AS).all.collect{|an|Rack::Utils::escape_html(an.name)}.join(', ')).blank?
      results <<  "was formerly known as: #{formerly_known_as}"
    end
    return [also_known_as_or_contains, supercedes, formerly_known_as] if options[:plain_results]
    results.empty? ? '' : "This library #{results.join('. It ')}."
  end
  
  def covers_subject?(subject)
    (@preloaded_subject_list ||= self.subjects.all).include?(subject)
  end

  def covers_course?(course)
    (@preloaded_course_list ||= self.courses.all).include?(course)
  end

  # Builds static website (in preview mode) for this library
  def build_static_pages
    PageRenderer::build(self, binding())
  end

  # Deploys the current static preview to live
  def deploy_static_pages
    PageRenderer::deploy(self)
  end
end
