# frozen_string_literal: true

RSpec.describe SwitchPoint::Middleware::DatabaseSelector::Resolver do
  describe '#select_database' do
    let(:get_req) { ActionDispatch::Request.new('REQUEST_METHOD' => 'GET') }
    let(:post_req) { ActionDispatch::Request.new('REQUEST_METHOD' => 'POST') }

    it 'returns Time.at(0) with empty session' do
      session = {}
      resolver = described_class.new(get_req, session: session)

      expect(resolver.last_write_timestamp).to eq Time.at(0)
    end

    it 'records timestamp after writing' do
      session = {}
      resolver = described_class.new(post_req, session: session)
      resolver.select_database {}

      expect(resolver.last_write_timestamp).to be_within(1.second).of(Time.now)
    end

    it 'connects to writable immediately after writing' do
      session = {
        switch_point_last_write: described_class.convert_time_to_timestamp(Time.now)
      }
      resolver = described_class.new(get_req, session: session)
      resolver.select_database do
        expect(Book).to connect_to('main_writable.sqlite3')
      end
    end
  end
end
