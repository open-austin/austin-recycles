#require 'atx-recycles-svc'

module ATXRecyclesSvc

  class CollectionRouteFactory
    
    VALID_TYPES = [:RECYCLE, :BRUSH, :BULKY, :GARBAGE, :YARD_TRIMMING]          
      
    def self.create(db, type)
      
      unless VALID_TYPES.include?(type)
        raise "unknown facility type \"#{type}\""            
      end
      
      klass = Class.new(AbstractCollectionRoute)
      klass.instance_variable_set(:@db, db)
      klass.instance_variable_set(:@type, type)
      klass.instance_variable_set(:@table, "#{type.downcase}_collection_routes".to_sym)          
      klass      
    end # initialize
    
  end # class CollectionRouteFactory
  
  #
  # Abstract class derived from ATXRecyclesSvc::BaseFeature to represent a variety
  # of features found in the City of Austin "facilities" GIS dataset.
  #
  class AbstractCollectionRoute
    
    @db = nil      
    @type = nil  
    @table = nil   
    
    def self.search(origin)  
        
      route = @db[@table] \
        .filter{ST_Contains(:Geometry, ST_Transform(MakePoint(origin.lng, origin.lat, 4326), 2277))} \
        .fetch_one       
        
      return nil unless route      
      
      ret = {
        :type => @type,
        :route => route[:ROUTE_NAME].strip.upcase,
      }
      
      service = {}            
      service[:day] = route[:SERVICE_DA].to_s.strip.upcase if route[:SERVICE_DA]
      service[:week] = route[:SERVICE_WE].to_s.strip.upcase if route[:SERVICE_WE]
      service[:nextservdate] = Date.jd(route[:NEXT_SERVI]).strftime("%m/%d/%Y") if route[:NEXT_SERVI]
      ret[:service] = service unless service.empty?
      
      ret
      
    end # self.find
    
  end # class AbstractCollectionRoute

end # module ATXRecyclesSvc
