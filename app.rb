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
  if @user and @user.token != params[:token]
    message += "Unauthorized Request."
    return message
  elsif !@user
    @user = User.create(name: params[:user_name], slack_user_id: params[:user_id], token: params[:token])
    message += "Welcome #{@user.name} to snippy :tada: \n"
  end

  command = extract_content params[:text]
  unless command[:success]
    message += command[:message]
    return message
  end
  title = command[:content][0]
  snippet = command[:content][1]
  case command[:action]
    when :new
      @snippet = @user.snippets.new({title: title, snippet: snippet})
      message += save_snippet
    when :get
      @snippet = @user.snippets.find_by(title: title)
      unless @snippet
        message += not_found_msg title
      else
        message += @snippet.snippet
      end
    when :edit
      @snippet = @user.snippets.find_by(title: title)
      unless @snippet
        message += not_found_msg title
      else
        @snippet.snippet = snippet
        message += save_snippet
      end
    when :delete
      @snippet = @user.snippets.find_by(title: title)
      unless @snippet
        message += not_found_msg title
      else
        @snippet.destroy
        message += "Snippet is successfully destroyed. It is un-recoverable."
      end
    when :search
      query = title
      results = @user.snippets.where("title ILIKE ?", "%#{query}%")
      if results
        message += "Your Search results:- \n " + results.map.with_index {|s, i| "#{i+1}. #{s.title}"}.join("\n")
      else
        message += "Your Search query didn't yield any results. Try again with different keywords."
      end
  end
  message
end

def extract_content text
  keywords = {new: 2, get: 1, edit: 2, delete: 1, search: 1}
  command = text.split('-', 3)
  if command.length < 2
    return {success: false, message: "Not enough arguments."}
  end

  action = command[0].downcase.to_sym
  if !keywords.keys.include?(action)
    return {success: false, message: "Invalid Command. Valid commands are `#{keywords.keys.join(", ")}`"}
  elsif keywords[action] != command.length - 1
    return {success: false, message: "Invalid Format. Valid format are \n `new-title-content`, \n `get-title`, \n `search-query`, \n `update-title-content`, \n `delete-title`"}
  else
    return {success: true, action: action, content: command[1..-1]}
  end
end

def not_found_msg title
  "Unable to find #{title}. Check if spelling is correct. You can search for snippets instead by `/snippet search-YOUR_QUERY`"
end

def save_snippet
  if @snippet.save
    return "Snippet saved successfully. You can access it by `/snippet get-#{@snippet.title}. \n"
  else
    return "There was some error saving the snippet. Please try again."
  end
end
