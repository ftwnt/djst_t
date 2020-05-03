require 'sinatra'
require 'slim'

require './services/repositories_fetcher'

class App < Sinatra::Base
  configure do
    FileUtils.mkdir_p('log') unless File.directory? 'log'
    file = File.new('log/app.log', 'a+')
    file.sync = true

    use Rack::CommonLogger, file
  end

  before do
    @query = params[:query]
  end

  get '/' do
    slim :index
  end

  post '/search_repositories' do
    result = RepositoriesFetcher.perform(query: @query)
    if result.success?
      @data = result.data
    else
      @error_message = result.error_message
    end

    slim :index
  end
end
