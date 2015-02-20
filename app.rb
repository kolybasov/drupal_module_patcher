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
    if result.is_a?(Hash)
      unless contains_errors(result[:output])
        flash[:link] = result[:file]
      end
      flash[:output] = result[:output]
    else
      flash[:output] = result
    end
    redirect '/'
  end

  get '/download/:dir/:file' do |dir, file|
    send_file File.join("temp/#{dir}", file)
  end

  # Helpers
  helpers do
    def contains_errors(output)
      output.include?('Assume -R? [n]') or output.include?('can\'t find file') or
      output.include?('fail') or output.include?('Skipping patch') or
      output.include?('patch unexpectedly ends')
    end
  end
end
