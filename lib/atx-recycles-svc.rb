dir = File.dirname(__FILE__)
$LOAD_PATH.unshift(dir, "#{dir}/../vendor/findit-support/lib")

require 'sinatra/base'
require 'sinatra/jsonp'
require 'atx-recycles-svc/app'

module ATXRecyclesSvc
  class Service < Sinatra::Base   
   
   @@app = ATXRecyclesSvc::App.new
   
   set :public_folder, 'public'
    
   helpers do  
     helpers Sinatra::Jsonp
   end
   
   get '/' do
     redirect "/index.html"
   end   
   
   get '/svc' do
     params = request.env['rack.request.query_hash']
     lat = params['latitude'].to_f
     lng = params['longitude'].to_f
     jsonp @@app.search(lat, lng)
   end
   
   post '/svc' do
     a = URI.decode_www_form(request.body.read)
     lat = (a.assoc('latitude') || []).last.to_f
     lng = (a.assoc('longitude') || []).last.to_f
     jsonp @@app.search(lat, lng)
   end
  
   # start the server if ruby file executed directly
   run! if app_file == $0
  end
  
end
