require 'app_configuration'
require 'dropbox_sdk'
 
enable :sessions

helpers do
  def dropbox_flow(conf, session)
    DropboxOAuth2Flow.new(conf.dropbox_key, conf.dropbox_secret, 'http://localhost:9292/auth_finish', session, :csrf_token_session_key)
  end
end

configure do
  set :conf, AppConfiguration.new('.config.yml')
end

get '/auth' do
  redirect to(dropbox_flow(settings.conf, session).start)
end

get '/auth_finish' do
  flow = dropbox_flow(settings.conf, session)
  access_token, user_id = flow.finish(params)

  session[:access_token] = access_token
  session[:user_id] = user_id

  "Token: #{access_token}<br/>User ID: #{user_id}"
end

get '/save/:content' do
  raise "Not authorised." unless session[:access_token] 

  client = DropboxClient.new(session[:access_token])

  content = params[:content]

  # Instead of `content`, we might put `open('myfile.pdf')`
  response = client.put_file("/#{content}.txt", content)

  response.to_s
end
