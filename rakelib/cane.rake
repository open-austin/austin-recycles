require File.expand_path('rakelib/settings.rb', Rake.application.original_dir)

# Cane https://github.com/square/cane
# Quality metrics
# Fails your build if code quality thresholds are not met.
#
# rake quality             # Run cane to check quality metrics
#
# Note that the coverage.rake's simplecov task generates the covered_percent file used here.
#
# Uses these settings:
# * Settings[:coverage_dirs]
# * Settings[:source_dirs]
# * Settings[:coverage_output_dir]
#
# add to your .gemspec:
#   gem.add_development_dependency('cane')

begin
  require 'cane/rake_task'

  desc 'Run cane to check quality metrics'
  Cane::RakeTask.new(:quality) do |cane|
    cane.abc_glob = "{#{Settings[:coverage_dirs].join(',')}}/**/*.rb"
    cane.abc_max = 10
    cane.add_threshold "#{Settings[:coverage_output_dir]}/covered_percent", :>=, 90
    cane.no_style = false
    cane.doc_glob = "{#{Settings[:source_dirs].join(',')}}/**/*.rb"
    cane.style_glob = "{#{Settings[:source_dirs].join(',')}}/**/*.rb"
    #cane.abc_exclude = %w(Foo::Bar.some_method)
  end
rescue LoadError
  warn 'cane not available, quality task not provided.'
end
