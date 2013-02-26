require File.expand_path('rakelib/settings.rb', Rake.application.original_dir)

# Simple Coverage tasks for ruby 1.9+ https://github.com/colszowka/simplecov
#
# This will run coverage as part of rspec and cucumber features.
#
# Note that the simplecov task provides the covered_percent file used by cane.rake's quality task.
#
# Uses these settings:
#
# * Settings[:coverage_dir]
#
# add to your .gemspec:
#   gem.add_development_dependency('simplecov')  unless RUBY_VERSION =~ %r{^1\.8\.}
#   gem.add_development_dependency('simplecov-rcov')  unless RUBY_VERSION =~ %r{^1\.8\.}

namespace :init do
  desc 'initialize simplecov helper'
  task :simplecov do
    simplecov_helper = File.expand_path('simplecov_helper.rb', Rake.application.original_dir)
    File.open(simplecov_helper, 'w') do |f|
      f.puts <<-END_HELPER
require 'simplecov'
require 'simplecov-rcov'

def coverage_directory
  dir = File.expand_path('#{Settings[:coverage_output_dir]}', '#{Rake.application.original_dir}')
  FileUtils.mkdir_p dir
  dir
end

class SimpleCov::Formatter::MergedFormatter
  def format(result)
    SimpleCov::Formatter::HTMLFormatter.new.format(result)
    SimpleCov::Formatter::RcovFormatter.new.format(result)
    File.open("\#{coverage_directory}/covered_percent", "w") do |f|
      f.puts result.source_files.covered_percent.to_f
    end
  end
end

SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter
SimpleCov.configure do
  coverage_dir '#{Settings[:coverage_output_dir]}'
  root '#{Rake.application.original_dir}'
end

SimpleCov.start do
  add_filter '/spec/'
#  add_filter '/config/'
#  add_filter '/lib/'
#
#  add_group 'Controllers',  'lib/gung_ho/controller'
#  add_group 'Models',       'lib/gung_ho/model'
#  add_group 'Helpers',      'lib/gung_ho/helper'
#  add_group 'Views',        'lib/gung_ho/view'
#  add_group 'Configs',      'lib/gung_ho/config'
end

#SimpleCov.start
      END_HELPER
    end
  end
end
