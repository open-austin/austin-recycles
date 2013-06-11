require "ice_cube"

module ATXRecyclesSvc

  class CollectionRoute
    
    include IceCube 
       
    TYPES = [:RECYCLE, :BRUSH, :BULKY, :GARBAGE, :YARD_TRIMMING]          
    
    def initialize(db, type, table = nil)
      unless TYPES.include?(type)
        raise "unknown facility type \"#{type}\""            
      end
      
      @db = db
      @type = type
      @table = table || "#{type.downcase}_collection_routes".to_sym
    end    

    START_DATE = DateTime.new(2012,12,31)    
    
    RECYCLING_PICKUP_OFFSET = {
      "A" => 0, # week A -> first week
      "B" => 7, # week B -> second week
    }.freeze
    
    
    def self.day_name_to_num(name)
      case name.strip.downcase
      when /^sun/
        0
      when /^mon/
        1
      when /^tue/
        2
      when /^wed/
        3
      when /^thu/
        4
      when /^fri/
        5
      when /^sat/
        6
      else
        raise "bad day name \"#{name}\""
      end
    end
    
    
    def self.next_service(start_date, day_name, week_increment = 1)
      n = day_name_to_num(day_name)
      # using ice_cube gem for scheduling
      schedule = Schedule.new(start_date)
      schedule.add_recurrence_rule Rule.weekly(week_increment).day(n)
      t = schedule.next_occurrence
      Date.new(t.year, t.month, t.day)      
    end

    
    # FIXME
    def self.holiday_slip(date)
      0
    end
    
    
    def self.status(service_date, service_period, today = Date.today)      
      n = (service_date - today).to_i
      case service_period
      when :DAY
        if n > 1
          :PENDING
        elsif n >= 0
          :ACTIVE
        else
          :PAST
        end   
      when :WEEK
        if n > 6
          :PENDING
        elsif n >= -5
          :ACTIVE
        else
          :PAST
        end
      else
        raise "bad service period \"#{service_period}\""
      end
    end
    
    
    def search(origin)  
        
      route = @db[@table] \
        .filter{ST_Contains(:Geometry, ST_Transform(MakePoint(origin.lng, origin.lat, 4326), 2277))} \
        .fetch_one       
        
      return nil unless route
      
      case @type
      
      when :GARBAGE
        # uses :SERVICE_DA (day of week, e.g. "Wednesday")
        next_service = self.class.next_service(START_DATE, route[:SERVICE_DA])
        service_period = :DAY
          
      when :YARD_TRIMMING
        # uses :AREA_SERVI (day of week, e.g. "Wednesday")
        next_service = self.class.next_service(START_DATE, route[:AREA_SERVI])
        service_period = :DAY
        
      when :RECYCLE
        # uses :SERVICE_DA (day of week, e.g. "Wednesday") and :SERVICE_WE ("A" or "B")
        raise "column :SERVICE_DA undefined" unless route.has_key?(:SERVICE_DA)
        raise "column :SERVICE_WE undefined" unless route.has_key?(:SERVICE_WE)
        start_date_offset = RECYCLING_PICKUP_OFFSET[route[:SERVICE_WE].strip] 
        raise "bad SERVICE_WE value \"#{route[:SERVICE_WE]}\"" unless start_date_offset
        next_service = self.class.next_service(START_DATE + start_date_offset, route[:SERVICE_DA], 2)
        service_period = :DAY

      when :BRUSH, :BULKY
        # uses :NEXT_SERVI (timestamp, e.g. 2456474.5)
        raise "column :NEXT_SERVI undefined" unless route.has_key?(:NEXT_SERVI)
        next_service = Date.jd(route[:NEXT_SERVI])
        service_period = :WEEK

      else
        raise "unknown collection type #{type}"
                
      end  
      
      if service_period == :DAY
        slip_days = self.class.holiday_slip(next_service)
        next_service += slip_days
      else
        slip_days = 0
      end
      
      {
        :type => @type,
        :route => route[:ROUTE_NAME].strip.upcase,
        :next_service =>  {
          :timestamp => next_service.to_time.to_i * 1000,
          :date => next_service.strftime("%m/%d/%Y"),
          :day => next_service.strftime("%a"),
          :slip => slip_days,
          :status => self.class.status(next_service, service_period),
          :period => service_period,
        },
      } 
      
    end # search
    
  end # class CollectionRoute
end # module ATXRecyclesSvc
