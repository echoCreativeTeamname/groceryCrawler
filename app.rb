require 'rubygems'
require 'active_record'
require 'yaml'
require 'logger'

#Logger
log = Logger.new(STDERR)
#log = Logger.new(File.open("log/debug.log", "a"))

#Setup Active-Record
unless(File.exist?('db/config.yml'))
  log.error "Database configuration file doesn't exist, please create 'db/config.yml'"
  exit
end
ActiveRecord::Base.establish_connection(YAML::load(File.open('db/config.yml'))["development"])
ActiveRecord::Base.logger = log

#Load all Active-Record models
Dir["./db/models/*.rb"].each do |file|
  require file
end

require("./crawlers/StoreCrawler")
require("./crawlers/stores/Jumbo")

store = Crawler::Stores::Jumbo.new log
store.products

=begin
#Crawler::Stores::Jumbo.load(log)
#Crawler::Stores::Jumbo.stores

Store.where(city: "Amsterdam").all.each do |store|
  puts store.storechain.name
end
=end
