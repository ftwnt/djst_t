require 'octokit'
require 'sinatra'
require 'slim'

class App < Sinatra::Base
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
