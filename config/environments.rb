require "sinatra/activerecord"

configure :production, :development do
  db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/slacksnippet_development')

  ActiveRecord::Base.establish_connection(
      :adapter => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
      :host     => db.host,
      :username => db.user,
      :password => 'd0nt mess',
      :database => db.path[1..-1],
      :encoding => 'utf8'
  )
end
