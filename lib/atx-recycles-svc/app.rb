require 'logger'
#require 'atx-recycles-svc'
#require 'atx-recycles-svc/collection-route'


module ATXRecyclesSvc
  

  class App
    
    DATABASE = File.dirname(__FILE__) + '/data/collection_routes.db'
    LIBSPATIALITE = '/usr/lib/libspatialite.so.3'

    def initialize(options = {})
  
      @log = Logger.new($stderr)
      @log.level = Logger::DEBUG    

      @database = options[:database] || DATABASE
      @libspatialite = options[:libspatialite]  || LIBSPATIALITE
      
      @db = ATXRecyclesSvc::Database.connect(@database, :spatialite => @libspatialite, :log => @log)
      
      # List of classes that implement features (derived from ATXRecyclesSvc::BaseFeature).
      @find_classes = [
        ATXRecyclesSvc::CollectionRouteFactory.create(@db, :GARBAGE),
        ATXRecyclesSvc::CollectionRouteFactory.create(@db, :RECYCLE),
        ATXRecyclesSvc::CollectionRouteFactory.create(@db, :BRUSH),
        ATXRecyclesSvc::CollectionRouteFactory.create(@db, :BULKY),
        ATXRecyclesSvc::CollectionRouteFactory.create(@db, :YARD_TRIMMING),
      ]  
      
    end
    
    
    def search(lat, lng)
      origin = ATXRecyclesSvc::Location.new(lat, lng, :DEG)  
      
      {
        :origin => origin.to_h,
        :routes => @find_classes.map {|klass| klass.send(:search, origin)}.reject {|a| a.nil?}
      }
    end
 
  end # module App
end # module ATXRecyclesSvc
