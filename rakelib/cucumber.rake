# Cumcumber http://cukes.info/
# Behavior Driven Development
#
# rake features            # Run Cucumber features
#
# add to your .gemspec:
#   gem.add_development_dependency('cucumber')

begin
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features, 'Run cucumber features')

  namespace :features do
    desc 'Create feature coverage'
    task :coverage do
      ENV['COVERAGE'] = 'true'
      Rake::Task['features'].execute
    end
  end


  namespace :init do
    desc 'Initialize cucumber feature infrastructure'
    task :features do
      dir = File.expand_path('features/support', Rake.application.original_dir)
      FileUtils.mkdir_p dir unless File.exist? dir
      env_file = File.join(dir, 'env.rb')
      unless File.exist? env_file
        File.open(env_file, 'w') do |f|
          f.puts 'require \'simplecov_helper\' if ENV[\'COVERAGE\'] == \'true\''
          f.puts 'require \'rspec\''
          f.puts "require_relative('../../lib/#{Settings[:app_dir]}')"
        end
      end
    end
  end
rescue LoadError
  warn 'cucumber not available, cucumber task not provided.'
end
