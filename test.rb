require 'rubygems'
require 'active_record'
require 'yaml'

ActiveRecord::Base.establish_connection(YAML::load(File.open('db/config.yml')))
ActiveRecord::Base.logger = Logger.new(STDERR)

class User < ActiveRecord::Base
end

require './store'

begin
  User.create(email: "foo@example.com")
  user = User.where(email: "foo@example.com").first
  user.email = "bar@example.com"
  user.save();
  puts user.email
rescue
  puts "An error occured."
end
