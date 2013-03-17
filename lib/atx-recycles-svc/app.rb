require 'atx-recycles-svc/collection-route'
require 'findit-support'

module ATXRecyclesSvc
  
  class App

    DATABASE = File.dirname(__FILE__) + '/data/collection_routes.db'

    def initialize(options = {})
  
      @database = ENV["ATX_RECYCLES_DATABASE"] || DATABASE
      
      @db = Sequel.spatialite(@database, :spatialite => ENV["SPATIALITE"])
      
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
      origin = FindIt::Location.new(lat, lng, :DEG)      
      {
        :origin => origin.to_h,
        :routes => @find_classes.map {|klass| klass.send(:search, origin)}.reject {|a| a.nil?}
      }
    end
 
  end

end
