require 'rubygems'
require 'sinatra'

log_dir = "log"
log_file = "sinatra-#{Time.now.strftime("%Y%m%d")}.log"

FileUtils.mkdir_p(log_dir) unless Dir.exists?(log_dir)
log = File.new("#{log_dir}/#{log_file}", "a")
$stdout.reopen(log)
$stderr.reopen(log)
$stderr.puts("=== Application restarted at " + Time.now.to_s)

require './lib/austin-recycles/service.rb'

run AustinRecycles::Service
