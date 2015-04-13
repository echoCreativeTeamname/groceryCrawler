require 'rubygems'
require 'active_record'
require 'yaml'
require 'logger'

#Logger
log = Logger.new(STDERR)

#Setup Active-Record
unless(File.exist?('../server-shared/config/database.yml'))
  log.error "Database configuration file doesn't exist, please create 'db/config.yml'"
  exit
end

ActiveRecord::Base.establish_connection(YAML::load(File.open('../server-shared/config/database.yml'))["development"])
ActiveRecord::Base.logger = log
ActiveRecord::Base.default_timezone = :local

#Load all Active-Record models
Dir["../server-shared/app/models/**/*.rb"].each do |file|
  require file
end

# Load crawlers
Dir["./crawlers/*.rb"].each do |file|
  require file
end

Dir["./crawlers/**/*.rb"].each do |file|
  require file
end

storecrawler = Crawler::Stores::Jumbo.new log
storecrawler.products
