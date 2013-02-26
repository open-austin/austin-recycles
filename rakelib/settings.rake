# Helper tasks for showing the project build settings.
#
# rake settings:help       # Display info about the Settings hash
# rake settings:show       # Show the project's settings
#

require File.expand_path('rakelib/settings.rb', Rake.application.original_dir)
require File.expand_path('rakelib/gemspec_file.rb', Rake.application.original_dir)


namespace :settings do
  desc 'Show the project\'s settings'
  task :show do
    puts Settings.setting_values.map{ |key, value| "  #{sprintf('%20s', ':' + key.to_s)} => #{value}" }.join("\n")
  end

  desc 'Display info about the Settings hash'
  task :help do
    puts Settings.help
  end
end
