require 'octokit'
require 'ostruct'

class RepositoriesFetcher
  class << self
    def perform(query:)
      new(query: query).perform
    end
  end

  attr_reader :query, :data, :error_message

  def initialize(query:)
    @query = query
  end

  def perform
    response = octokit_client.search_repositories query
    @data = ::OpenStruct.new(
      items: response.items.sort_by { |item| [item.owner.login, item.name] },
      items_count: response.items.count,
      total: response.total_count
    )
    self
  rescue Octokit::UnprocessableEntity => e
    @error_message = e.message.to_s.gsub(/(\n)/, '<br />')
    self
  end

  def success?
    error_message.nil?
  end

  private

  def octokit_client
    @octokit_client ||= Octokit::Client.new
  end
end
