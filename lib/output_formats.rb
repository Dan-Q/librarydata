require 'csv'

DEFAULT_LATITUDE = 51.758
DEFAULT_LONGITUDE = -1.255

def xml(data, filename)
  headers 'Content-Type' => 'application/xml',
          'Content-Disposition' => "inline; filename=\"#{filename}\""
  data.to_xml
end

def json(data, filename)
  headers 'Content-Type' => 'application/json',
          'Content-Disposition' => "inline; filename=\"#{filename}\""
  data.to_json
end

def kml(libraries, filename)
  headers 'Content-Type' => 'application/vnd.google-earth.kml+xml',
          'Content-Disposition' => "inline; filename=\"#{filename}\""
  @libraries = [libraries] unless libraries.is_a?(Array)
  haml :kml, :layout => false
end

def gmaps(js_url)
  @js_url = js_url
  haml :gmaps
end

def js(libraries, lat = DEFAULT_LATITUDE, lng = DEFAULT_LONGITUDE, zoom = 12)
  headers 'Content-Type' => 'text/javascript'
  @libraries, @lat, @lng, @zoom = libraries, lat, lng, zoom
  erb :js
end

def csv(data, filename)
  headers 'Content-Type' => 'text/csv',
          'Content-Disposition' => "inline; filename=\"#{filename}\""
  return 'No data' if data.empty?
  CSV.generate do |csv|
    keys = data.first.attributes.keys
    csv << keys
    data.each do |row|
      csv << keys.collect{|key| row[key]}
    end
  end
end
