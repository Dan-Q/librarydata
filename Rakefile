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
