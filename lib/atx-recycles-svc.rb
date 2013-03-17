#require 'atx-recycles-svc/app'
#require 'atx-recycles-svc/database'
#require 'atx-recycles-svc/location'
#require 'atx-recycles-svc/collection-route'
#
#class String
#  
#  def capitalize_words
#    self.split.map{|w| w.capitalize}.join(' ')
#  end
#    
#  require 'cgi'
#  def html_safe
#    CGI::escape_html(self)
#  end
#  
#end
#
#
#class NilClass
#  
#  # So I can use foo.empty? safely on things expected to hold a String.  
#  def empty?
#    true
#  end
#  
#end


BASEDIR = File.dirname(__FILE__)
$:.insert(0, BASEDIR + '/../vendor/findit-support/lib')
$:.insert(0, BASEDIR )

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

