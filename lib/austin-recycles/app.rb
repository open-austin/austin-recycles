require 'findit-support'
require_relative './collection-route.rb'

module AustinRecycles
  
  class App

    # Construct a new AustinRecycles app instance.
    def initialize(options = {})
      database = options[:database] || "#{AustinRecycles::BASEDIR}/#{AustinRecycles::DATABASE}"
      raise "database \"#{database}\" not found" unless File.exist?(database)

      @db = Sequel.spatialite(database)
      @db.logger = options[:log] if options.has_key?(:log)
      @db.sql_log_level = :debug

      @finders = {}
      AustinRecycles::CollectionRoute::TYPES.each do |type|
        @finders[type] = AustinRecycles::CollectionRoute.new(@db, type)
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
