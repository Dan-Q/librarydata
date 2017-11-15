require "erb"
include ERB::Util
include FileUtils

# "BodSomething" static site renderer
module PageRenderer
  # Given a library, compiles that library's static HTML files (preview mode)
  def self.build(library, library_binding)
    # Tidy the deploy folder
    mkdir_p(path = "public/libraries/#{library.id}/preview")
    rm_f("#{path}/*")
    # Compile templates
    render 'index.html', library, library_binding, path
  end

  # Given a library, deploys that library's last complete build
  def self.deploy(library)
    mkdir_p(path = "public/libraries/#{library.id}/live")
    rm_f("#{path}/*")
    cp_r("public/libraries/#{library.id}/preview/*", path)
  end

  # Builds all libraries preview sites
  def self.build_all
    Library::all.each(&:build_static_pages)
  end

  # Deploys all libraries live sites
  def self.deploy_all
    Library::all.each(&:deploy_static_pages)
  end

  protected

  def self.render(template_name, library, library_binding, path, output_filename = nil)
    # Get header and footer for this content type, if available
    super_template_name = template_name.split('.')[1..-1].join('.') # suffix, i.e. index.html.erb becomes html.erb
    header_template_file_name = File.join('templates', "header.#{super_template_name}.erb")
    footer_template_file_name = File.join('templates', "footer.#{super_template_name}.erb")
    header = File::exists?(header_template_file_name) ? ERB.new(File.read(header_template_file_name)).result(library_binding) : ''
    footer = File::exists?(footer_template_file_name) ? ERB.new(File.read(footer_template_file_name)).result(library_binding) : ''
    # Get content and render to file specified by output_filename, or same as template_name if not specified
    template_file = File.join('templates', "#{template_name}.erb")
    template = ERB.new(File.read(template_file))
    output_filename ||= template_name
    File.open(File.join(path, output_filename), 'w') do |f|
      f.print header
      f.print template.result(library_binding)
      f.print footer
    end
  end
end
