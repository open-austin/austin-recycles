require "ice_cube"

module AustinRecycles

  # Implements a search for a collection rotue and next delivery date
  # for a specified service.
  class CollectionRoute

    # Start date for calculating recurring schedules.
    START_DATE = Date.new(2012, 12, 31)

    # Recycling pickup is every other week, identified as "A" or "B" week.
    RECYCLING_PICKUP_OFFSET = {
      "A" => 0, # week A -> first week
      "B" => 7, # week B -> second week
    }.freeze

    # Keyed by days on which normal pickup slips due to holiday.
    # Value is number of days pickup slips.
    HOLIDAY_SLIPS = {
      Date.new(2013, 11, 28).jd => 1, # Thanksgiving (Thu)
      Date.new(2013, 11, 29).jd => 1,
      Date.new(2013, 12, 25).jd => 1, # Christmas (Wed)
      Date.new(2013, 12, 26).jd => 1,
      Date.new(2013, 12, 27).jd => 1,
    }.freeze

    # For :BIANNUAL services, the database has the first service date.
    # The second service date is this many days later.
    BIANNUAL_INCREMENT = 27*7

    include IceCube

    # The service types we support.
    TYPES = [:RECYCLE, :BRUSH, :BULKY, :GARBAGE, :YARD_TRIMMING]

    # Parameters:
    # db:: handle for opened Spatialite database
    # type:: a CollectionRoute::TYPES value
    # table:: name of the database table (default is calculate from type)
    def initialize(db, type, table = nil)
      unless TYPES.include?(type)
        raise "unknown facility type \"#{type}\""
      end

      @db = db
      @type = type
      @table = table || "#{type.downcase}_collection_routes".to_sym
    end

    # Given a day name (e.g. "Sunday") return a day-of-week number ("Sunday" => 0)
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

    # Calculate the Date when next service happens for a recurring service.
    #
    # Parameters:
    # start_date:: The base Date used for calculating recurring schedule.
    # day_name:: Day of week the service happens, e.g. "Wednesday"
    # week_increment:: How frequently service occurs. Default is weekly (1).
    #
    def self.next_service(start_date, day_name, week_increment = 1)
      n = day_name_to_num(day_name)
      # set start_time to 9:00AM on start_date
      start_time = start_date.to_time + 9 * 3600
      # set end_time to 5:00PM on start_date
      end_time = start_date.to_time + 17 * 3600
      # using ice_cube gem for scheduling
      schedule = Schedule.new(start_time, :end_time => end_time)
      schedule.add_recurrence_rule Rule.weekly(week_increment).day(n)
      t = schedule.next_occurrence($time_now || Time.now)
      Date.new(t.year, t.month, t.day)
    end


    # Indicate whether a given service date shouldl slip due to holiday.
    # Returns either number of days service should slip, or nil for no slip.
    def self.holiday_slip(date)
      HOLIDAY_SLIPS[date.jd]
    end


    # Calculate a status identifier for the pickup date.
    #
    # Parameters:
    # service_date:: A Date instance when the service will happen
    # service_period:: Either :DAY or :WEEK
    # today:: A Date instance for current date (default is today)
    #
    # Return value:
    # :ACTIVE:: Service is about to happen or is happening now.
    # :PENDING:: Service is upcoming.
    # :PENDING:: Service has already passed.
    #
    def self.status(service_date, service_period, today = nil)
      today ||= ($time_now || Time.now)
      n = (service_date.to_time - today).to_i
      case service_period
      when :DAY
        # mark active if pickup is today or tomorrow
        if n > 1
          :PENDING
        elsif n >= 0
          :ACTIVE
        else
          :PAST
        end
      when :WEEK
        # mark active scheduled to start next week or is happening this week
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


    # Locate a service route and calculate next delivery date for a given location.
    #
    # Parameters:
    # origin:: A FindIt::Location instance.
    #
    # Returns a hash of values.
    #
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
        recurrence = :WEEKLY

      when :YARD_TRIMMING
        # uses :AREA_SERVI (day of week, e.g. "Wednesday")
        next_service = self.class.next_service(START_DATE, route[:AREA_SERVI])
        service_period = :DAY
        recurrence = :WEEKLY

      when :RECYCLE
        # uses :SERVICE_DA (day of week, e.g. "Wednesday") and :SERVICE_WE ("A" or "B")
        raise "column :SERVICE_DA undefined" unless route.has_key?(:SERVICE_DA)
        raise "column :SERVICE_WE undefined" unless route.has_key?(:SERVICE_WE)
        start_date_offset = RECYCLING_PICKUP_OFFSET[route[:SERVICE_WE].strip]
        raise "bad SERVICE_WE value \"#{route[:SERVICE_WE]}\"" unless start_date_offset
        next_service = self.class.next_service(START_DATE + start_date_offset, route[:SERVICE_DA], 2)
        service_period = :DAY
        recurrence = :BIWEEKLY

      when :BRUSH, :BULKY
        # uses :NEXT_SERVI (timestamp, e.g. 2456474.5)
        raise "column :NEXT_SERVI undefined" unless route.has_key?(:NEXT_SERVI)
        next_service = Date.jd(route[:NEXT_SERVI])
	if ($time_now || Time.now) >= (next_service+7).to_time
	  next_service += BIANNUAL_INCREMENT
	end
        service_period = :WEEK
        recurrence = :BIANNUAL

      else
        raise "unknown collection type #{type}"

      end

      # deterine if service date should slip due to holiday
      if service_period == :DAY
        slip_days = self.class.holiday_slip(next_service)
        next_service += slip_days unless slip_days.nil?
      else
        slip_days = nil
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
          :recurrence => recurrence,
        },
      }

    end # search

  end # class CollectionRoute
end # module AustinRecycles
