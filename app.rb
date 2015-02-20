require 'rubygems'
require 'sinatra/base'
require 'sinatra/flash'
require 'slim'
require 'json'
require './patcher/drupal_patcher'

class App < Sinatra::Base
  configure do
    enable :static
    enable :sessions
    register Sinatra::Flash

    set :views, File.join(File.dirname(__FILE__), 'views')
    set :public_folder, File.join(File.dirname(__FILE__), 'public')
    set :unallowed_paths, ['.', '..']
  end

  error do
    slim :error
  end

  get '/' do
    slim :index
  end

  post '/upload' do
    result = DrupalPatcher.patch(params[:module], params[:patch])
    flash[:link], flash[:output] = result[:file], result[:output]
    redirect '/'
  end

  get '/download/:file' do |file|
    dir = file.split(".").first
    send_file File.join("temp/#{dir}", file)
  end

  # Helpers
  helpers do

  end
end
