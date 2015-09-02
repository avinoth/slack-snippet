require 'sinatra'

require 'active_support/json/encoding'
require 'json'
require './config/environments'

require 'sinatra/activerecord'

# The entry point for slash commands
get '/gateway' do
end
