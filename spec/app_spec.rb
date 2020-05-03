require 'spec_helper'
require 'rack/test'

require './app'

ENV['RACK_ENV'] = 'test'

describe App do
  include Rack::Test::Methods

  def app
    described_class
  end

  describe 'GET /' do
    it 'succeeds' do
      get '/'

      expect(last_response).to be_ok
    end
  end

  describe 'POST /search_repositories' do
    let(:query_param) { 'some_query' }

    subject { post '/search_repositories', { query: query_param } }

    context 'when data fetcher succeeds' do
      let(:faked_total) { 35 }
      let(:expected_data) do
        amount = 5
        items = amount.times.each_with_object([]) do |idx, memo|
          memo << instance_double(
            'Item',
            html_url: "some_url-#{idx}",
            full_name: "some_name-#{idx}",
            owner: instance_double("Owner-#{idx}", login: "login-#{idx}")
          )
        end
        instance_double(
          'Result',
          items: items,
          items_count: amount,
          total: faked_total
        )
      end
      before do
        allow(RepositoriesFetcher).to receive(:perform) do
          instance_double('RepositoriesFetcher',
                          data: expected_data,
                          success?: true)
        end
      end

      it 'calls RepositoriesFetcher with needed param' do
        expect(RepositoriesFetcher).to receive(:perform).with(query: query_param)

        subject
      end

      it 'displays received data' do
        subject

        expect(last_response.body).to match(expected_data.items[0].html_url)
        expect(last_response.body).to match(expected_data.items[0].full_name)
        expect(last_response.body).to match(expected_data.items[1].html_url)
        expect(last_response.body).to match(expected_data.items[1].full_name)
        expect(last_response.body).to match(expected_data.items[2].html_url)
        expect(last_response.body).to match(expected_data.items[2].full_name)
        expect(last_response.body).to match(expected_data.items[3].html_url)
        expect(last_response.body).to match(expected_data.items[3].full_name)
        expect(last_response.body).to match(expected_data.items[4].html_url)
        expect(last_response.body).to match(expected_data.items[4].full_name)

        expect(last_response.body)
          .to match("#{expected_data.items_count} of #{expected_data.total}")
      end

      it 'does not contain error message element' do
        subject

        expect(last_response.body).to_not match('div class="error"')
      end
    end

    context 'when data fetcher succeeds' do
      let(:fake_error_message) { 'some error message' }
      before do
        allow(RepositoriesFetcher).to receive(:perform) do
          instance_double('RepositoriesFetcher',
                          error_message: fake_error_message,
                          success?: false)
        end
      end

      it 'calls RepositoriesFetcher with needed param' do
        expect(RepositoriesFetcher).to receive(:perform).with(query: query_param)

        subject
      end

      it 'displays error message' do
        subject

        expect(last_response.body).to match(fake_error_message)
      end
    end
  end
end
