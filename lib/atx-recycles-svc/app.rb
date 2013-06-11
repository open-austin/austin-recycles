require 'findit-support'
require 'atx-recycles-svc/collection-route'

module ATXRecyclesSvc
  
  class App

    DATABASE = File.dirname(__FILE__) + '/data/collection_routes.db'

    def initialize(options = {})
      @db = Sequel.spatialite(DATABASE)
      @finders = {}
      ATXRecyclesSvc::CollectionRoute::TYPES.each do |type|
        @finders[type] = ATXRecyclesSvc::CollectionRoute.new(@db, type)
      end
    end
    
    
    def search(lat, lng)
      origin = FindIt::Location.new(lat, lng, :DEG) 
      routes = {}
      @finders.each do |type, finder|
        a = finder.search(origin)
        routes[type.to_s.downcase.to_sym] = a if a
      end
      {
        :origin => origin.to_h,
        :routes => routes,
      }
    end
 
  end

end
