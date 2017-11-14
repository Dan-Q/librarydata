class Site < ActiveRecord::Base
  has_many :libraries
  
  def library_links_html
    self.libraries.collect{|l| "<a href=\"#L#{l.id}\">#{Rack::Utils::escape_html(l.name)}</a>"}.join('; ')
  end
  
  def library_edit_links_html
    self.libraries.collect{|l| "<a href=\"/libraries/#{l.id}/edit\">#{Rack::Utils::escape_html(l.name)}</a>"}.join('; ')
  end
  
  def alternative_names_html
    results = []
    individual_library_results = self.libraries.collect{|l| l.alternative_names_html(:plain_results => true)}
    unless (also_known_as_or_contains = individual_library_results.collect{|lr| lr[0]}.reject{|lr| lr.empty?}.join(', ')).blank?
      results << "is also known as or contains: #{also_known_as_or_contains}"
    end
    unless (supercedes = individual_library_results.collect{|lr| lr[1]}.reject{|lr| lr.empty?}.join(', ')).blank?
      results <<  "supercedes: #{supercedes}"
    end
    unless (formerly_known_as = individual_library_results.collect{|lr| lr[2]}.reject{|lr| lr.empty?}.join(', ')).blank?
      results <<  "was formerly known as: #{formerly_known_as}"
    end
    results.empty? ? '' : "This library #{results.join('. It ')}."
  end
end
