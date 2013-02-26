# Database migration tasks when using Sequel http://sequel.rubyforge.org/

# Expects your project's db/config.rb to define Database::DB_MODES as an array of symbols for the various
# database modes (ex: [:dev, :live, :test])
#
# Also expects your project's db/config.rb to provide a #uri(mode) method that takes the mode and returns
# a database uri String.

require File.expand_path('rakelib/settings.rb', Rake.application.original_dir)
# Uses these settings:
# * Settings[:db_migrations_dir]
# * Settings[:db_config_file]

#
# There is an example db/config.rb as part of the rakelib project.

# rake db:migrate[mode]    # Run database migrations where mode is: dev, live, test
# rake db:reset[mode]      # Reset the database then run the migrations
# rake db:zap[mode]        # Zap the database my running all the down migrations

# add to your .gemspec:
#   gem.add_dependency('sequel')

begin
  require File.expand_path(Settings[:db_config_file], Rake.application.original_dir)
  namespace 'db' do
    desc "Run database migrations where mode is: #{Database::DB_MODES.join(', ')}"
    task :migrate, :mode do |t, args|
      cmd = "sequel -m #{Settings[:db_migrations_dir]} #{Database.url(mode(args[:mode]))}"
      puts cmd
      puts `#{cmd}`
    end

    desc 'Zap the database my running all the down migrations'
    task :zap, [:mode] do |t, args|
      cmd = "sequel -m #{Settings[:db_migrations_dir]} -M 0 #{Database.url(mode(args[:mode]))}"
      puts cmd
      puts `#{cmd}`
    end

    desc 'Reset the database then run the migrations'
    task :reset, [:mode] => [:zap, :migrate]
  end

  def mode(arg)
    mode = arg.to_s
    if mode.nil? || mode.strip.empty?
      mode = 'dev'
    end
    mode.to_sym
  end

rescue LoadError => ex
  warn "#{Settings[:db_config_file]} not available (#{ex.to_s}), sequel migration tasks not provided."
end
