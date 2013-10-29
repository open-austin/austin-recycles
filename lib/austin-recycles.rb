require 'rubygems'
require 'bundler/setup' 

module AustinRecycles
  BASEDIR = Bundler.root
  DATABASE = "data/2013/austin-recycles.db" # relative to BASEDIR
end

class NilClass
  def empty?
    true
  end
end

require_relative './austin-recycles/app.rb'
