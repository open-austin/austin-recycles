dir = File.dirname(__FILE__)
$LOAD_PATH.unshift(dir, "#{dir}/../vendor/findit-support/lib")

require 'sinatra/base'
require 'sinatra/jsonp'
require 'austin-recycles/app'

module AustinRecycles
  class Service < Sinatra::Base   
   
   @@app = AustinRecycles::App.new
   
   set :public_folder, 'public'
    
   helpers do  
     helpers Sinatra::Jsonp
   end
   
   before do
     @params = request.env['rack.request.query_hash']
     if @params.has_key?("delay")
       sleep(@params["delay"].to_i)
     end

     # Check for test parameter "t"
     # If "t" is not provided, use today's date
     if @params.has_key?("t")
       $date_today = Date.parse(@params["t"])
     else
       $date_today = Date.today
     end
   end
   
   get '/' do
     redirect "/index.html"
   end   
   
   get '/svc' do
     lat = @params['latitude'].to_f
     lng = @params['longitude'].to_f
     content_type :json
     jsonp @@app.search(lat, lng)
   end
   
   post '/svc' do
     a = URI.decode_www_form(request.body.read)
     lat = (a.assoc('latitude') || []).last.to_f
     lng = (a.assoc('longitude') || []).last.to_f
     content_type :json
     jsonp @@app.search(lat, lng)
   end
  
   # start the server if ruby file executed directly
   run! if app_file == $0
  end
  
end
