require 'rubygems'
require 'active_record'
require 'yaml'
require 'logger'

#Logger
log = Logger.new(STDERR)

#Setup Active-Record
unless(File.exist?('db/config.yml'))
  log.error "Database configuration file doesn't exist, please create 'db/config.yml'"
  exit
end

ActiveRecord::Base.establish_connection(YAML::load(File.open('db/config.yml')))
ActiveRecord::Base.logger = log

#Load all Active-Record models
Dir["./models/*.rb"].each do |file|
  require file
end
