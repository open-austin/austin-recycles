require 'atx-recycles-svc/app'
require 'atx-recycles-svc/database'
require 'atx-recycles-svc/location'
require 'atx-recycles-svc/collection-route'

class String
  
  def capitalize_words
    self.split.map{|w| w.capitalize}.join(' ')
  end
    
  require 'cgi'
  def html_safe
    CGI::escape_html(self)
  end
  
end


class NilClass
  
  # So I can use foo.empty? safely on things expected to hold a String.  
  def empty?
    true
  end
  
end
