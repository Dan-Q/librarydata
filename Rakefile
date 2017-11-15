# Rails-like migrations
require 'standalone_migrations'
StandaloneMigrations::Tasks.load_tasks

# LibraryData
desc "Runs the LibraryData application server (via rerun)"
task :run do
  sh 'rerun', '--clear', './librarydata.rb'
end

desc "Provides access to a console interface"
task :console do
  sh 'irb', '-r', './librarydata.rb'
end

namespace :renderer do
  desc "Builds previews of all library sites."
  task :build do
    require './librarydata.rb'
    PageRenderer::build_all
  end

  desc "Deploys last previews of all library sites."
  task :deploy do
    require './librarydata.rb'
    PageRenderer::deploy_all
  end
end
