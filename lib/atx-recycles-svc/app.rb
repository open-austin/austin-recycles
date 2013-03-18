require_relative './collection-route.rb'

module ATXRecyclesSvc
  
  class App

    DATABASE = File.dirname(__FILE__) + '/data/collection_routes.db'

    def initialize(options = {})
      @db = Sequel.spatialite(DATABASE)
      @finders = []
      ATXRecyclesSvc::CollectionRoute::TYPES.each do |type|
        @finders << ATXRecyclesSvc::CollectionRoute.new(@db, type)
      end
    end
    
    
    def search(lat, lng)
      origin = FindIt::Location.new(lat, lng, :DEG)      
      {
        :origin => origin.to_h,
        :routes => @finders.map {|f| f.search(origin)}.reject {|a| a.nil?}
      }
    end
 
  end

end
