helpers do
  include Rack::Utils
  alias_method :h, :escape_html

  # Escapes carriage returns and single and double quotes for JavaScript segments.
  #
  # Also available through the alias j(). This is particularly helpful in JavaScript
  # responses, like:
  #
  #   $('some_element').replaceWith('<%=j render 'some/element_template' %>');
  #
  # Adapted from Rails
  JS_ESCAPE_MAP = {
    '\\'    => '\\\\',
    '</'    => '<\/',
    "\r\n"  => '\n',
    "\n"    => '\n',
    "\r"    => '\n',
    '"'     => '\\"',
    "'"     => "\\'"
  }
  JS_ESCAPE_MAP["\342\200\250".force_encoding(Encoding::UTF_8).encode!] = '&#x2028;'
  JS_ESCAPE_MAP["\342\200\251".force_encoding(Encoding::UTF_8).encode!] = '&#x2029;'
  def j(javascript)
    (javascript || '').gsub(/(\\|<\/|\r\n|\342\200\250|\342\200\251|[\n\r"'])/u) {|match| JS_ESCAPE_MAP[match] }
  end

  def status_403(return_to = nil)
    @return_to = return_to
    haml :login
  end

  def no_quotes(string)
    string.gsub('"', "'")
  end

  def library_edit_field_input(field, value = '', type = 'text', options = {})
    options = {:style => '', :class => '', :options => []}.merge(options)
    if type == 'textarea'
      "<textarea name=\"library[#{field}]\" id=\"#{field}\" class=\"ui-widget-content ui-corner-all #{options[:class]}\" style=\"#{options[:style]}\" />#{h(value)}</textarea>"
    elsif type == 'select'
      "<select name=\"library[#{field}]\" id=\"#{field}\" class=\"ui-widget-content ui-corner-all #{options[:class]}\" style=\"#{options[:style]}\">" +
        options[:options].collect{|o| "<option value=\"#{o[1]}\"#{' selected="selected"' if (value.to_s == o[1].to_s)}>#{o[0]}</option>"}.join +
      "</select>"
    else
      "<input type=\"#{type}\" name=\"library[#{field}]\" id=\"#{field}\" value=\"#{h(value)}\" class=\"ui-widget-content ui-corner-all #{options[:class]}\" style=\"#{options[:style]}\" />"
    end
  end

  def library_edit_field(library, field, label, options = {})
    options = {:tip => '', :type => 'text', :style => '', :class => '', :prefix => '', :additional_fields => []}.merge(options)
    result =  '<p class="field">'
    result += "<label for=\"#{field}\">#{label}:</label>"
    unless options[:prefix].blank?
      result += "<span class=\"input prefix\">#{options[:prefix]}</span>"
    end
    result += library_edit_field_input(field, library.attributes[field], options[:type], options)
    unless options[:additional_fields].empty?
      options[:additional_fields].each do |additional_field|
        result += library_edit_field_input(additional_field, library.attributes[additional_field], options[:type], options)
      end
    end
    unless options[:tip].blank?
      result += "<small>#{h(options[:tip])}</small>"
    end
    result += '</p>'
  end
end
