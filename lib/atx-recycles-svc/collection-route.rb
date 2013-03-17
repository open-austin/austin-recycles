require "ice_cube"

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
    
    include IceCube

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

      days = {
        "SUNDAY" => 0,
        "MONDAY" => 1,
        "TUESDAY" => 2,
        "WEDNESDAY" => 3,
        "THURSDAY" => 4,
        "FRIDAY" => 5,
        "SATURDAY" => 6
      }

      if route[:SERVICE_WE].to_s.strip.upcase == "A"
        start_date = DateTime.new(2012,12,31)
      elsif route[:SERVICE_WE].to_s.strip.upcase == "B"
        start_date = DateTime.new(2013,01,07)
      end

      if start_date
        day_num = days[route[:SERVICE_DA].to_s.strip.upcase]
        # using ice_cube gem for scheduling:
        schedule = Schedule.new(start_date)
        schedule.add_recurrence_rule Rule.weekly(2).day(day_num)
        recycle_date = schedule.next_occurrence
        puts "NEXT OCCURRENCE: #{recycle_date}"
      end
      
      service = {}            
      service[:day] = route[:SERVICE_DA].to_s.strip.upcase if route[:SERVICE_DA]
      service[:week] = route[:SERVICE_WE].to_s.strip.upcase if route[:SERVICE_WE]
      service[:nextrecycle] = recycle_date.strftime("%m/%d/%Y") if recycle_date
      service[:nextservdate] = Date.jd(route[:NEXT_SERVI]).strftime("%m/%d/%Y") if route[:NEXT_SERVI]
      ret[:service] = service unless service.empty?
      
      ret
      
    end # self.find
    
  end # class AbstractCollectionRoute

end # module ATXRecyclesSvc
