require 'spec_helper'
require './services/repositories_fetcher'

describe RepositoriesFetcher do
  let(:query_param) { 'query' }

  describe '.perform' do
    let(:service_double) { instance_double(described_class.to_s, perform: true) }

    it 'calls message chain' do
      expect(described_class).to receive(:new).with(query: query_param) { service_double }
      expect(service_double).to receive(:perform)

      described_class.perform(query: query_param)
    end
  end

  describe '#perform' do
    before { allow(Octokit::Client).to receive(:new) { api_service_stub } }

    let(:api_service_stub) do
      instance_double('Octokit::Client', search_repositories: expected_data)
    end
    let(:exception_message) { 'Some exception message' }
    subject { described_class.new(query: query_param).perform }

    context 'when exception is raised' do
      let(:expected_data) { [] }
      before do
        allow(api_service_stub)
          .to receive(:search_repositories)
          .and_raise(Octokit::UnprocessableEntity)
      end

      it 'calls the client' do
        expect(api_service_stub).to receive(:search_repositories).with(query_param)

        subject
      end

      it 'assigns the error message' do
        expect(subject.error_message).to_not be_nil
      end

      it 'does not assign the data' do
        expect(subject.data).to be_nil
      end

      it 'returns self' do
        expect(subject).to be_a RepositoriesFetcher
      end
    end

    context 'when service responds with a data' do
      let(:faked_total) { 35 }
      let(:expected_data) do
        amount = 5
        items = amount.times.each_with_object([]) do |_, memo|
          memo << instance_double(
            'Item',
            name: 'name',
            owner: instance_double('Owner', login: 'login')
          )
        end
        instance_double(
          'Result',
          items: items,
          items_count: amount,
          total_count: faked_total
        )
      end
      let(:expected_response) do
        {
          items: expected_data.items,
          items_count: expected_data.items.count,
          total: faked_total
        }
      end

      it 'calls the client' do
        expect(api_service_stub).to receive(:search_repositories).with(query_param)

        subject
      end

      it 'does not assign the error message' do
        expect(subject.error_message).to be_nil
      end

      it 'assign the data' do
        expect(OpenStruct).to receive(:new).with(expected_response)

        subject
      end

      it 'returns self' do
        expect(subject).to be_a RepositoriesFetcher
      end
    end
  end
end
