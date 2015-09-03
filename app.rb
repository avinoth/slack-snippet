require 'sinatra'

require 'active_support/json/encoding'
require 'json'
require 'sinatra/activerecord'

require './config/environments'

require './models/user'
require './models/snippet'

# The entry point for slash commands
get '/gateway' do
  message = ""
  @user = User.find_by(slack_user_id: params[:user_id])
  unless @user
    @user = User.create(name: params[:user_name], slack_user_id: params[:user_id], token: params[:token])
    message = "Welcome #{@user.name} to snippy :tada: \n"
  end

  command = extract_content params[:text]
  unless command[:success]
    message += command[:message]
  else
    message += "#{command[:action]} - #{command[:content]}"
  end
  message
end

def extract_content text
  keywords = {new: 2, get: 1, search: 1, delete: 1, update: 2}
  command = text.split('-', 3)
  if command.length < 2
    return {success: false, message: "Not enough arguments."}
  end

  action = command[0].downcase.to_sym
  if !keywords.keys.include?(action)
    return {success: false, message: "Invalid Command. Valid commands are `new, get, search, update, delete`"}
  elsif keywords[action] != command.length - 1
    return {success: false, message: "Invalid Format. Valid format are \n `new title`, \n `get title`, \n `search query`, \n `update title content`, \n `delete title`"}
  else
    return {success: true, action: action, content: command[1..-1]}
  end
end
