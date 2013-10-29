require 'sinatra/base'
require 'sinatra/jsonp'
require 'logger'
require_relative '../austin-recycles.rb'

module AustinRecycles

  class Service < Sinatra::Base

    # Initialization performed at service start-up.
    #
    # Environment parameters to override configuration settings:
    #
    # APP_ROOT - Root directory of the application.
    # APP_DATABASE - Path to database file.
    # APP_DEBUG - If set, logging set to DEBUG level, which logs SQL operations.
    #
    configure do
      log = Logger.new($stderr)
      log.progname = self.name
      log_level = (ENV['APP_DEBUG'] ? "DEBUG" : "INFO")
      log.level = Logger.const_get(log_level)

      log.info "environment=#{settings.environment}"
      log.info "log level=#{log_level}"

      set :root, ENV['APP_ROOT'] || AustinRecycles::BASEDIR
      log.info "root=#{settings.root}"

      set :public_folder, "#{settings.root}/public"
      log.info "public_folder=#{settings.public_folder}"

      database = ENV['APP_DATABASE'] || "#{settings.root}/#{AustinRecycles::DATABASE}"
      log.info "database=#{database}"
      @@app = AustinRecycles::App.new(:database => database, :log => log)

      log.info "configuration complete"
    end


    # Helper methods for request handling.
    helpers Sinatra::Jsonp
    helpers do

      def search(params)

        # ?delay=n
        # Pause for "n" seconds.
        # Intended for test/debug, to simulate slow connections.
        if params.has_key?("delay")
          sleep(params["delay"].to_i)
        end

         # ?t=datespec
         # Force current date to "datespec", which must be a valid Time.parse value.
         # Intended for test/debug.
         if params.has_key?("t")
           $time_now = Time.parse(params["t"])
         end

        lat = params['latitude'].to_f
        lng = params['longitude'].to_f
        content_type :json
        jsonp @@app.search(lat, lng)
      end

    end


    before do
      @params = {}
      env = request.env
      @params.merge!(env['rack.request.form_hash']) unless env['rack.request.form_hash'].empty?
      @params.merge!(env['rack.request.query_hash']) unless env['rack.request.query_hash'].empty?
    end


    get '/' do
      redirect to('/index.html')
    end

    get '/svc' do
      search(@params)
    end

    post '/svc' do
      search(@params)
    end

    run! if app_file == $0

  end # Service
end # AustinRecycles
