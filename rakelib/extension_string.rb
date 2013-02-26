# Various extensions to the String class
class String
  unless String.respond_to?('snake_case')
    # Convert to snake case.
    # @example
    #   "FooBar".snake_case           #=> "foo_bar"
    #   "HeadlineCNNNews".snake_case  #=> "headline_cnn_news"
    #   "CNN".snake_case              #=> "cnn"
    #
    # @return [String] Receiver converted to snake case.
    def snake_case
      return self.downcase if self =~ /^[A-Z]+$/
      self.gsub(/([A-Z]+)(?=[A-Z][a-z]?)|\B[A-Z]/, '_\&') =~ /_*(.*)/
      $+.downcase
    end
  end

  unless String.respond_to?('camel_case')
    # Convert to camel case.
    # @example
    #   "foo_bar".camel_case          #=> "FooBar"
    #
    # @return [String] Receiver converted to camel case.
    def camel_case
      return self if self !~ /_/ && self =~ /[A-Z]+.*/
      split('_').map{|e| e.capitalize}.join
    end
  end
end
