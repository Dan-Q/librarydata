#!/usr/bin/env ruby
require 'bundler/setup'
require 'sinatra'
require 'sinatra/activerecord'
require 'builder'
require 'active_support/core_ext/hash'

enable :sessions, :logging
set :session_secret, YAML.load(File.read('db/config.yml'))['session_secret']

ActiveRecord::Base.establish_connection(YAML.load(File.read('db/config.yml'))['production'])
set :haml, :format => :html5
set :protection, :except => :frame_options # don't use X-Frame-Options to prevent <iframe>-loading

########      Libraries      ########

Dir.glob(File.join(File.dirname(__FILE__), 'lib', '*.rb')) do |model|
  eval(IO.read(model), binding)
end

########     Data models     ########

Dir.glob(File.join(File.dirname(__FILE__), 'models', '*.rb')) do |model|
  eval(IO.read(model), binding)
end

########    Authentication   ########

before do
  @me = User::find_by_id(session[:user_id]) if session[:user_id]
end

########  Utility Functions  ########

# Given an array of Libraries (or anything else with a "Name"), returns an array of letters (A-Z) represented
# Useful for alphabetically-linked lists of libraries
def letters_for(libraries)
  ('A'..'Z').select{|letter| libraries.any?{|library| (library.try(:name) || library.try(:html) || '')[0,1] == letter}}
end

# Returns the requested format (params[:format]) for the request.
# An array of acceptable formats may be supplied (first parameter).
# A fallback default, usually 'html' can be specified as the second parameter.
def get_format(acceptable_formats = [], default_format = nil)
  format = params[:format] || default_format
  halt 404 if (acceptable_formats.length > 0) && !acceptable_formats.include?(format)
  return format
end

# Rails-style escaping
helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

########        Routes       ########

get '/' do
  redirect '/libraries'
end

get '/libraries.?:format?' do
  format = get_format(%w{xml json html kml csv gmaps js}, 'html')
  @libraries = (Library::all + AlternativeName::all + Site::all).sort_by{|l| l.name}
  if params[:only]
    # can optionally pass ?only=1,2,3,4 to get just those libraries, e.g. to do a multipoint map
    only = params[:only].split(',').collect(&:to_i)
    @libraries = @libraries.select{|l| only.include?(l.id)}
  elsif params[:id]
    # can optionally pass ?id=1 to show that library's page, e.g. for shorter tunnelled URLs (HTML only, no sites)
    # can optionally add &site to show that library's whole site, if applicable
    halt 404 unless @library = Library::find_by_id(params[:id])
    if params[:site] && (@site = @library.site)
      return haml(:site)
    else
      return haml(:library)
    end
  end
  return xml(@libraries.reject{|l| l.is_a?(Site)}, 'libraries.xml') if format == 'xml'
  return json(@libraries.reject{|l| l.is_a?(Site)}, 'libraries.json') if format == 'json'
  return kml(@libraries.select{|l| l.is_a?(Library)}, 'libraries.kml') if format == 'kml'
  return csv(@libraries.select{|l| l.is_a?(Library)}, 'libraries.csv') if format == 'csv'
  return gmaps('/libraries.js') if format == 'gmaps'
  return js(@libraries.select{|l| l.is_a?(Library)}) if format == 'js'
  @letters = letters_for(@libraries)
  @cross_references_as_links = true # makes library-in-site names disappear, alternative names appear as direct links to library
  haml :libraries
end

# multiple libraries (data formats only)
get %r[/libraries/((\d+)(\.\d+)+)(\.(xml|json|kml|csv|gmaps|js))?] do
  ids, junk1, junk2, ext, format = params[:captures]
  halt 404 unless %w{xml json kml csv gmaps js}.include?(format)
  halt 404 unless @libraries = Library::where('id IN (?)', ids.split('.').collect(&:to_i))
  return xml(@libraries.reject{|l| l.is_a?(Site)}, 'libraries.xml') if format == 'xml'
  return json(@libraries.reject{|l| l.is_a?(Site)}, 'libraries.json') if format == 'json'
  return kml(@libraries.select{|l| l.is_a?(Library)}, 'libraries.kml') if format == 'kml'
  return csv(@libraries.select{|l| l.is_a?(Library)}, 'libraries.csv') if format == 'csv'
  return gmaps('/libraries.js') if format == 'gmaps'
  return js(@libraries.select{|l| l.is_a?(Library)}) if format == 'js'
end

# single library or site
# can optionally pass ?site=no to suppress site information
get %r[/libraries/(\d+)(\.(xml|json|html|kml|gmaps|js|mobile))?] do
  id, ext, format = params[:captures]; format ||= 'html'
  halt 404 unless %w{xml json html kml gmaps js mobile}.include?(format)
  halt 404 unless @library = Library::find_by_id(id)
  return gmaps("/libraries/#{@library.id}.js") if format == 'gmaps'
  if (@site = @library.site) && (params[:site] != 'no')
    return js(@site.libraries, @library.lat, @library.lng, 16) if format == 'js'
    haml :site
  else
    return xml(@library, "#{@library.name}.xml") if format == 'xml'
    return json(@library, "#{@library.name}.json") if format == 'json'
    return kml(@library, "#{@library.name}.kml") if format == 'kml'
    return js([@library], @library.lat, @library.lng, 17) if format == 'js'
    @show_social_networks = @library.social_links.any?
    return haml(:library_mobile) if format == 'mobile'
    haml :library
  end
end

get '/libraries/:id/edit' do
  id = params[:id]
  halt 404 unless @library = Library::find_by_id(id)
  return status_403("/libraries/#{@library.id}/edit") unless @me
  halt 403 unless @me.can_edit?(@library)
  haml :edit
end

post '/libraries/:id/edit' do
  id = params[:id]
  halt(404, "Library ##{id} not found.") unless @library = Library::find_by_id(id)
  halt(403, "Not logged in.") unless @me
  halt(403, "Not allowed to edit #{@library.name}.") unless @me.can_edit?(@library)
  # bulk update normal params
  @library.update_attributes(params[:library])
  # subjects:
  params[:subject].each do |subject_id, value|
    if value == '0'
      if subject = @library.library_subjects.find_by_subject_id(subject_id.to_i)
        subject.destroy
      end
    elsif value == '1'
      @library.library_subjects.find_or_create_by(subject_id: subject_id.to_i)
    end
  end
  # courses:
  if params[:course]
    params[:course].each do |course_id, value|
      if value == '0'
        if course = @library.library_courses.find_by_course_id(course_id.to_i)
          course.destroy
        end
      elsif value == '1'
        @library.library_courses.find_or_create_by(course_id: course_id.to_i)
      end
    end
  end
  # social links:
  @library.social_links.destroy_all
  (params[:social_link] || {})['network'].count.times do |i|
    network, url = params[:social_link]['network'][i], params[:social_link]['url'][i]
    @library.social_links.create(:network => network, :url => url, :position => (i + 1)) unless network.blank? || url.blank?
  end
  # staff:
  @library.staffs.destroy_all
  (params[:staff] || {})['job_title'].count.times do |i|
    job_title, name_of_person = params[:staff]['job_title'][i], params[:staff]['name_of_person'][i]
    @library.staffs.create(:job_title => job_title, :name_of_person => name_of_person, :list_order => (i + 1)) unless job_title.blank? || name_of_person.blank?
  end
  redirect to("/libraries/#{@library.id}/edit")
end

get '/libraries/:id/social.?:format?' do
  format = get_format(%w{html js}, 'html')
  halt 404 unless @library = Library::find_by_id(params[:id])
  @social_links = @library.social_links.all
  if format == 'js'
    headers 'Content-Type' => 'text/javascript'
    "document.write('#{j(haml(:social, :layout => false))}');"
  else
    haml :social, :layout => false
  end
end

get '/opening-hours.?:format?' do
  format = get_format([], 'html')
  redirect to("/libraries.#{format}") and return unless format == 'html'
  @term, @next = TermDate::current, TermDate::next
  @libraries = Library::with_opening_hours.all
  @letters = letters_for(@libraries)
  haml :opening_hours
end

get '/group/:group/list.?:format?' do
  format = get_format(%w{xml json html kml gmaps js}, 'html')
  @group = params[:group]
  if @group != 'other'
    @libraries = Library::where('library_group = ?', @group).all
  else
    @libraries = Library::where("library_group IS NULL OR library_group = ''").all
  end
  if @libraries.length > 0
    @libraries += AlternativeName::where("library_id IN (#{@libraries.collect(&:id).join(',')}) AND show_in_group = 1").all
  end
  if (site_libs = @libraries.select{|l| l.is_a?(Library) && l.site_id?}).length > 0
    @libraries += Site::where("id IN (#{site_libs.collect(&:site_id).join(',')})").all
  end
  @libraries = @libraries.sort_by{|l| l.name}
  return xml(@libraries.reject{|l| l.is_a?(Site)}, "#{@group}.xml") if format == 'xml'
  return json(@libraries.reject{|l| l.is_a?(Site)}, "#{@group}.json") if format == 'json'
  return kml(@libraries.select{|l| l.is_a?(Library)}, "#{@group}.kml") if format == 'kml'
  return gmaps("/group/#{@group}/list.js") if format == 'gmaps'
  return js(@libraries.select{|l| l.is_a?(Library)}, DEFAULT_LATITUDE, DEFAULT_LONGITUDE, 13) if format == 'js'
  @letters = letters_for(@libraries)
  @cross_references_as_links = true # makes library-in-site names disappear, alternative names appear as direct links to library
  haml :group
end

get '/term-dates.?:format?' do
  format = get_format(%w{xml json html}, 'html')
  @terms = TermDate::finishes_in_future.all
  return xml(@terms, 'term-dates.xml') if format == 'xml'
  return json(@terms, 'term-dates.json') if format == 'json'
  haml :term_dates  
end

get '/users/:username' do
  username = params[:username]
  halt 404 unless @user = User::find_by_username(username)
  return status_403("/users/#{@user.username}") unless @me
  halt 403 unless (@user == @me || @me.is_admin?)
  haml :user
end

post '/users/:username/change_password' do
  username = params[:username]
  halt 404 unless @user = User::find_by_username(username)
  halt 403 unless @user == @me || (@me && @me.is_admin?)
  if params[:password1] == params[:password2] && !params[:password1].blank?
    @user.password = params[:password1]
    @user.save
    "Password has been changed. <a href=\"/users/#{@user.username}\">Go back</a>."
  else
    "Password was not changed. <a href=\"/users/#{@user.username}\">Try again?</a>."
  end
end

get '/courses/:id' do
  halt 404 unless @course = Course::find_by_id(params[:id])
  return status_403("/courses/#{@course.id}") unless @me
  halt 403 unless @me.is_admin?
  haml :course
end

post '/courses/:id' do
  halt 404 unless @course = Course::find_by_id(params[:id])
  halt 403 unless @me && @me.is_admin?
  @course.update_attributes(params[:course])
  # libraries:
  if params[:library]
    params[:library].each do |library_id, value|
      if value == '0'
        if library = @course.library_courses.find_by_library_id(library_id.to_i)
          library.destroy
        end
      elsif value == '1'
        @course.library_courses.find_or_create_by(library_id: library_id.to_i)
      end
    end
  end
  redirect to("/users/#{@me.username}#courses")
end

post '/courses/:id/delete' do
  halt 403 unless @me && @me.is_admin?
  halt 404 unless @course = Course::find_by_id(params[:id])
  @course.destroy
  redirect to("/users/#{@me.username}#courses")
end

get '/courses.?:format?' do
  format = get_format(%w{html csv}, 'html')
  return status_403("/courses.#{format}") unless @me
  halt 403 unless @me.is_admin?
  @courses = Course::all
  return csv(@courses, 'courses.csv') if format == 'csv'
  redirect to("/users/#{@me.username}#courses")
end

post '/courses' do
  halt 403 unless @me && @me.is_admin?
  Course::create(params[:course])
  redirect to("/users/#{@me.username}#courses")
end

get '/undergrad' do
  @colleges = College::includes(:library).all
  @courses = Course::includes(:libraries).all
  haml :undergrad
end

get '/social' do
  redirect to('/') unless @me && @me.is_admin?
  @non_library_links = NonLibraryLink::order(:html).all
  haml :social_edit
end

get '/social/list' do
  @items = (Library::all.reject{|l|l.social_links.reject{|sl|sl.network == 'rss'}.count == 0} + NonLibraryLink::all).collect{|i|
    if i.is_a?(NonLibraryLink)
      i.html
    elsif i.is_a?(Library)
      social_links = i.social_links.reject{|sl|sl.network == 'rss'}.sort_by(&:network).collect{|sl| sl.auto_link(nil, {:class => '', :title => ''}, true)}.join(' | ')
      if (i.Name == 'Bodleian Library - New Library') || (i.Name == 'Bodleian Library - Weston Library')
        "Bodleian Libraries #{social_links}"
      elsif (i.Name == 'Bodleian Library - Old Library') || (i.Name == 'Bodleian Library - Radcliffe Camera')
        nil
      else
        "#{i.Name} #{social_links}"
      end
    end
  }.reject(&:nil?).sort_by{|i|i.upcase}
  @letters = (['#']+('A'..'Z').to_a).select{|letter| @items.any?{|i| i[0,1].upcase == letter || (letter == '#' && i[0,1] =~ /^\d/)}}
  haml :social_output
end

post '/social' do
  redirect to('/') unless @me && @me.is_admin? && params['non_library_link']
  NonLibraryLink::order(:html).all.each do |non_library_link|
    if(non_library_link_params = params['non_library_link'][non_library_link.id.to_s])
      if(non_library_link_params['html'] != non_library_link.html)
        non_library_link.html = non_library_link_params['html']
        non_library_link.save
      end
      if(non_library_link_params['delete'].to_i == 1)
        non_library_link.destroy
      end
    end
  end
  redirect to('/social')
end

post '/social/add' do
  redirect to('/') unless @me && @me.is_admin? && params['non_library_link']
  if(non_library_link_params = params['non_library_link'])
    NonLibraryLink::create(:html => non_library_link_params['html'])
  end
  redirect to('/social')
end

get '/manage' do
  redirect to('/') unless @me && @me.is_admin?
  @users = User::order(:username).all
  @termdates = TermDate.all
  haml :manage
end

post '/manage/users' do
  redirect to('/') unless @me && @me.is_admin? && params['user']
  User::order(:username).all.each do |user|
    if(user_params = params['user'][user.id.to_s])
      user.username = user_params['username']
      user.temporary_password = user_params['temporary_password']
      current_libstring = (user.is_admin? ? 'super' : user.libraries.collect(&:id).join(','))
      if(user_params['library_ids'] != current_libstring)
        user.library_users.destroy_all
        if user_params['library_ids'] == 'super'
          user.is_admin = true
        else
          user.is_admin = false
          user_params['library_ids'].split(',').each do |lid|
            user.library_users.create(:library_id => lid)
          end
        end
      end
      user.save if user.changed?
      if(user_params['delete'].to_i == 1)
        user.destroy
      end
    end
  end
  redirect to('/manage')
end

post '/manage/users/add' do
  redirect to('/') unless @me && @me.is_admin? && params['user']
  if(user_params = params['user'])
    user = User::create(:username => user_params['username'], :temporary_password => user_params['password'])
    if user_params['library_ids'] == 'super'
      user.is_admin = true
      user.save
    else
      user_params['library_ids'].split(',').each do |lid|
        user.library_users.create(:library_id => lid)
      end
    end
  end
  redirect to('/manage')
end

post '/manage/termdates' do
  redirect to('/') unless @me && @me.is_admin? && params['termdate']
  TermDate::all.each do |termdate|
    if(termdate_params = params['termdate'][termdate.id.to_s])
      termdate.name = termdate_params['name']
      termdate.start_date = termdate_params['start_date']
      termdate.end_date = termdate_params['end_date']
      termdate.save if termdate.changed?
      termdate.destroy if(termdate_params['delete'].to_i == 1)
    end
  end
  redirect to('/manage#tab_termdates')
end

get '/login' do
  haml :login
end

post '/login' do
  if user = User::login(params[:username], params[:password])
    session[:user_id] = user.id
    redirect to(params[:return_to] || "/users/#{user.username}")
  else
    @errors = 'Bad username/password combination.'
    haml :login
  end
end

get '/logout' do
  session[:user_id] = nil
  redirect to('/')
end
