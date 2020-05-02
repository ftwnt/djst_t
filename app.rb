require 'octokit'
require 'sinatra'
require 'slim'

class App < Sinatra::Base
  configure do
    FileUtils.mkdir_p('log') unless File.directory? 'log'
    file = File.new("log/app.log","a+")
    file.sync = true

    use Rack::CommonLogger, file
  end

  get '/' do
    response = octokit_client.search_repositories 'spr_t'
    @items = response.items

    slim :index
  end

  private

  def octokit_client
    @octokit_client ||= Octokit::Client.new
  end
end
