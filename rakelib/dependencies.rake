# This rakefile is used to support gem dependencies.
#
# rake init:gemfile        # replace Gemfile with Gemfile.init
# rake init:gemspec        # replace rakelib.gemspec with rakelib.gemspec.init
# rake update:gemfile      # Update the Gemfile with dependencies from rakelib/*.rake files
# rake update:gemspec      # Update the /Users/roy/Projects/github/mine/rakelib/rakelib.gemspec file with dependencies from rakelib/*.rake files
#
# The basic pattern is for the .rake files to document in the comments which development gems they need
# as either a "gem(...)" or as a "gem.add_development_dependency(...)".  The update tasks then scan all the
# rakelib/*.rake files extracting these gem commands from the comments.  The duplicates are then removed from
# this set of gems and finally the development gem commands in either GemFile or *.gemspec are replaced.
#
# Note, it is ok for a rake file to just have comments to specify which gems to include.

require 'fileutils'
require File.expand_path('rakelib/settings.rb', Rake.application.original_dir)
require File.expand_path('rakelib/gemspec_file.rb', Rake.application.original_dir)

@gemspec = Dir["#{Rake.application.original_dir}/*.gemspec"].first

namespace :update do
  unless @gemspec.nil?
    desc "Update the #@gemspec file with dependencies from rakelib/*.rake files"
    task :gemspec do
      add_dependency = []
      add_development_dependency = []
      Dir["#{Rake.application.original_dir}/rakelib/*.rake"].each do |fn|
        IO.readlines(fn).each do |line|
          #   gem.add_development_dependency('cane')
          if line =~ %r{^\s*#\s*(gem\.add_dependency.*)$}
            add_dependency << $1
          end
          if line =~ %r{^\s*#\s*(gem\.add_development_dependency.*)$}
            add_development_dependency << $1
          end
        end
      end
      gemspec_file = GemspecFile.new
      gemspec_file.load(@gemspec)
      gemspec_file.gems = add_dependency.uniq.sort
      gemspec_file.dev_gems = add_development_dependency.uniq.sort
      gemspec_file.save
    end
  end
end

namespace :init do
  desc "replace #{File.basename(@gemspec)} with #{File.basename(@gemspec)}.init"
  task :gemspec do
    initial_gem_file = File.expand_path(File.basename(@gemspec) + '.init', Rake.application.original_dir)
    if File.exist? initial_gem_file
      gem_file = File.expand_path(File.basename(@gemspec), Rake.application.original_dir)
      File.delete gem_file if File.exist? gem_file
      FileUtils.cp initial_gem_file, gem_file
    end
  end
end
