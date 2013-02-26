require 'sequel'
#require "logger"

module ATXRecyclesSvc
  module Database    
      
    @log = Logger.new($stderr)
    
    # Connect to the sqlite3 database with spatialite extensions.
    #
    # Parameters:
    # * database -- Full pathname to the database.
    # * opts
    #
    # Options:
    # * :spatialite -- Full pathname to the spatialite library, e.g. "/usr/lib/ibspatialite.so.3".
    # * :log -- Either true (construct a log object for database logging), false (do not setup
    #   database logging), or a Logger instance to use. Default is "false".
    # * :log_level -- Level at which to log database messages. Default is ":debug".
    #
    def self.connect(database, opts = {})
      @log.debug("connect: entered, database=#{database}")
      #noinspection RubyResolve
      raise Errno::ENOENT, database unless File.exist?(database)
      
      case opts[:log]
      when Logger
        log = opts[:log]
      when true
        log = @log
      when false, nil
        log = nil
      else
        raise "bad :log value \"#{opts[:log]}\""
      end
      
      db = Sequel.sqlite(database, :after_connect => proc {|db| db.enable_load_extension(true)})
      if log
        db.logger = log
        db.sql_log_level = opts[:log_level] || :debug
      end
      
      db.get{load_extension(opts[:spatialite] || 'libspatialite.so')}
      # will raise an error if spatialite not loaded
      ver = db.get{spatialite_version{}}

      @log.debug("connect: done, loaded spatialite extensions, ver #{ver}")
      db      
    end
    
    
    # Run the "shp2pgsql" command on a shape file and load the output.
    def load_shapefile(table, shapefile, srid, codepage = 'CP1252')
      self.log.debug("load_shapefile: entered, table=\"#{table}\", shapefile=\"#{shapefile}\", srid=\"#{srid}\", codepage=\"#{codepage}\"")   
      cmdv = ['spatialite_tool', '-i',
              '-shp', shapefile,
              '-d', self.name,
              '-t', table,
              '-c', codepage,
              '-s', srid,
      ]
      unless system(cmdv)
        raise "system() failed: #{$?}"
      end
      self.log.debug('load_shapefile: done')
    end

    
  end # module Database
end # module ATXRecyclesSvc

module Sequel
  class Dataset
    
    def fetch_one
      results = self.limit(2).all
      case results.length
      when 0
        nil
      when 1
        results[0]
      else
        raise "query returned too many rows (#{self})"
      end
    end
    
  end # class Dataset  
end # moduel Sequel
