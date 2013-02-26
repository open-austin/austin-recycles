require 'singleton'
require File.expand_path('rakelib/extension_string.rb', Rake.application.original_dir)

# Provides support for the rakelib Settings which define the build environment.
# .rake files that need info about the build environment should:
#
#    require File.expand_path('rakelib/settings.rb', Rake.application.original_dir)
#
# This will attempt to initialize the Settings hash with sane values for your project.
# You may override these default settings in your Rakefile using something like:
#
#   Settings[:app_name] = 'My Glorious Application'
#
# see file:settings.rake for setting related rake tasks
class RakeSettings
  include Singleton


  attr_reader :setting_values

  # helper for defining a setting
  # @param [Symbol] key is the setting name
  # @param [Hash] options is the setting options
  # @option options [String] :app_name is the applications name
  # @option options [Array<String>] :source_dirs the directories that may contain source files to be documented
  # @option options [Array<String>] :test_dirs the directories that may contain test code that should not be documented
  # @option options [Array<String>] :coverage_dirs the directories used for code coverage metrics (usually source_dirs + test_dirs)
  # @option options [String] :yard_output_dir relative path to the directory to write yard documentation to
  # @option options [String] :rdoc_output_dir relative path to the directory to write rdoc documentation to
  # @option options [String] :doc_dir relative path to the document directory
  # @option options [String] :coverage_output_dir relative path to the directory to write coverage info to
  # @option options [String] :db_dir relative path to the directory where your database lives
  # @option options [String] :db_config_file relative path to the database config file
  # @option options [String] :db_migration_dir relative path to the directory where the database migration files belong
  # @option options [String] :sloc_report relative path to file that contains the sloccount report for Jenkins
  # @option options [String] :sloc_report_raw relative path to file that contains the raw sloccount report
  def setting(key, options={})
    @setting_values ||= {}
    @setting_descriptions ||= {}
    @setting_values[key] ||= options[:value]
    @setting_descriptions[key] ||= options[:description]
  end

  # shorthand for using Settings[key] to access Settings.settings_values[key]
  # @param [Symbol] key the setting name
  # @return [Object] the value for the setting
  def [](key)
    @setting_values[key]
  end

  # shorthand for using Settings[key]=value instead of Settings.settings_values[key]=value
  # @param [Symbol] key the setting name
  # @param [Object] value the value for the setting
  # @return [Object] the new value for the setting
  def []=(key,value)
    @setting_values[key] = value
  end

  def initialize
    setting :app_name, :value => File.basename(File.dirname(File.dirname(__FILE__))).camel_case,
            :description => '[String] the application name'

    setting :app_dir, :value => File.basename(File.dirname(File.dirname(__FILE__))),
            :description => '[String] the project directory'

    setting :source_dirs, :value => %w{ lib app controller model }.select{|dir| File.exist? dir},
            :description => '[Array<String>] the directories that may contain source files to be documented'

    setting :test_dirs, :value => %w{ features spec }.select{|dir| File.exist? dir},
            :description => '[Array<String>] the directories that may contain test code that should not be documented'

    setting :coverage_dirs, :value => %w{ lib app controller model features spec }.select{|dir| File.exist? dir},
            :description => '[Array<String>] the directories used for code coverage metrics (usually source_dirs + test_dirs)'

    setting :yard_output_dir, :value => 'doc/ydoc',
            :description => '[String] relative path to the directory to write yard documentation to'

    setting :rdoc_output_dir, :value => 'doc/rdoc',
            :description => '[String] relative path to the directory to write rdoc documentation to'

    setting :doc_dir, :value => 'doc',
            :description => '[String] relative path to the document directory'

    setting :coverage_output_dir, :value => 'doc/coverage',
            :description => '[String] relative path to the directory to write coverage info to'

    setting :bin_dir, :value => 'bin',
            :description => '[String] relative path to the directory for scripts'

    setting :db_dir, :value => 'db',
            :description => '[String] relative path to the directory where your database lives'

    setting :db_config_file, :value => 'db/config.rb',
            :description => '[String] relative path to the database config file'

    setting :db_migration_dir, :value => 'db/migrations',
            :description => '[String] relative path to the directory where the database migration files belong'

    setting :sloc_report, :value => 'doc/sloc.txt',
            :description => '[String] relative path to file that contains the sloccount report for Jenkins'

    setting :sloc_report_raw, :value => 'doc/sloc.raw.txt',
            :description => '[String] relative path to file that contains the raw sloccount report'
  end

  # @return [String] the Settings help message
  def help
    return <<-END_SETTINGS_HELP
The Settings hash is shared among the rake tasks and key/value pairs may be overridden in the Rakefile.
For example, override the application name from the Rakefile:

  Settings[:app_name] = 'my glorious application'

Keys => values are:
#{@setting_descriptions.map{|key, value| "  #{sprintf('%20s', ':' + key.to_s)} => #{value}"}.join("\n")}
    END_SETTINGS_HELP
  end
end

# The environment settings for the rake tasks.  Normally accessed like a Hash.
Settings = RakeSettings.instance
