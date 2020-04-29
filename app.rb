require 'sinatra'

class App < Sinatra::Base
  get '/' do
    'sup here'
  end
end
