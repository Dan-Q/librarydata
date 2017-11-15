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

  def self.render(template_name, library, library_binding, path)
    template_file = File.join('templates', "#{template_name}.erb")
    template = ERB.new(File.read(template_file))
    File.open(File.join(path, template_name), 'w') do |f|
      f.puts template.result(library_binding)
    end
  end
end
