require 'sinatra'

require 'active_support/json/encoding'
require 'json'
require 'sinatra/activerecord'

require './config/environments'

require './models/user'
require './models/snippet'


get '/gateway' do
  message = ""
  @trigger = params[:command]
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


  if command[:content].present?
    title = command[:content][0].strip.downcase
    snippet = command[:content][1]
  end

  case command[:action]
    when '-n'
      @snippet = @user.snippets.find_by(title: title)
      if @snippet
        message += duplicate_entry title
      else
        @snippet = @user.snippets.new({title: title, snippet: snippet.strip})
        message += save_snippet
      end
    when '-g'
      @snippet = @user.snippets.find_by(title: title)
      unless @snippet
        message += not_found_msg title
      else
        message += @snippet.snippet
      end
    when '-e'
      @snippet = @user.snippets.find_by(title: title)
      unless @snippet
        message += not_found_msg title
      else
        if command[:tag]
          if @user.snippets.find_by(title: snippet)
            message += duplicate_entry snippet
          else
            @snippet.title = snippet.strip
            message += save_snippet
          end
        else
          @snippet.snippet = snippet.strip
          message += save_snippet
        end
      end
    when '-d'
      @snippet = @user.snippets.find_by(title: title)
      unless @snippet
        message += not_found_msg title
      else
        @snippet.destroy
        message += "Snippet is successfully destroyed. It is un-recoverable."
      end
    when '-s'
      query = title
      if @user.snippets.find_by(title: query)
        message += "You have a title with exact match of your search query. If you intend to get the snippet try `#{@trigger} -g #{query}` command instead."
      end
      results = @user.snippets.where("title ILIKE ? OR snippet ILIKE ?", "%#{query}%", "%#{query}%")
      if results.present?
        message += "Your Search results:- \n " + results.map.with_index {|s, i| "#{i+1}. #{s.title} - #{truncate(s.snippet, 30)}"}.join("\n")
      else
        message += "Your Search query didn't yield any results. Try again with different keywords."
      end
    when '-r'
      if @user.snippets.present?
        message += "Total Snippets saved: #{@user.snippets.count}n \n"
        snippets = @user.snippets.order('updated_at desc')
        message += "Last 3 snippets updated, \n"
        message += snippets.limit(3).map.with_index {|s, i| "#{i+1}. #{s.title} - #{s.updated_at.strftime('%F %H:%M')}"}.join("\n")
      else
        message += "You don't have any snippets created. Create one now by `-n title -c content"
      end
  end
  message
end

def extract_content text
  keywords = {"-n" => 2, "-g" => 1, "-e" => 2, "-d" => 1, "-s" => 1, "-r" => 0}
  action = text[0..1]

  if !keywords.keys.include?(action)
    return {success: false, message: "Invalid Command. Valid commands are `#{keywords.keys.join(", ")}`"}
  end

  if text.include? " -t "
    command = text.gsub(action, "").strip.split(" -t ")
    tag = true
  else
    command = text.gsub(action, "").strip.split(" -c ")
    tag = false
  end

  if keywords[action] != command.length
    return {success: false, message: "Invalid Format. Valid format are \n `-n title -c content`, \n `-g title`, \n `-s query`, \n `-e title -c newContent` OR `-e title -t newTitle `, \n `-d title`"}
  else
    return {success: true, action: action, content: command, tag: tag}
  end
end

def not_found_msg title
  "Unable to find #{title}. Check if spelling is correct. You can search for snippets instead by `#{@trigger} -s #{title}`"
end

def save_snippet
  if @snippet.save!
    return "Snippet saved successfully. You can access it by `#{@trigger} -g #{@snippet.title}`. \n"
  else
    return "There was some error saving the snippet. Please try again."
  end
end

def truncate(content, max=10)
  content.length > max ? "#{content[0...max]}..." : content
end

def duplicate_entry title
  "Snippet already with the name #{title} exists. If you are trying to edit use `#{@trigger} -e #{title}`"
end
