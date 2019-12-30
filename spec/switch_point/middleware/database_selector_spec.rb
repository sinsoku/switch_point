# frozen_string_literal: true

RSpec.describe SwitchPoint::Middleware::DatabaseSelector do
  describe '#call' do
    it 'connects to writable connections with POST request' do
      middleware = described_class.new(lambda { |_env|
        expect(Book).to connect_to('main_writable.sqlite3')
        expect(Book3).to connect_to('main2_writable.sqlite3')
        expect(Comment).to connect_to('comment_writable.sqlite3')
        expect(User).to connect_to('user.sqlite3')
        expect(BigData).to connect_to('main_writable.sqlite3')
        [200, {}, ['body']]
      })
      expect(middleware.call('REQUEST_METHOD' => 'POST')).to eq [200, {}, ['body']]
    end

    it 'connects to readonly connections with GET request' do
      middleware = described_class.new(lambda { |_env|
        expect(Book).to connect_to('main_readonly.sqlite3')
        expect(Book3).to connect_to('main2_readonly.sqlite3')
        expect(Comment).to connect_to('comment_readonly.sqlite3')
        expect(User).to connect_to('user.sqlite3')
        expect(BigData).to connect_to('main_readonly_special.sqlite3')
        [200, {}, ['body']]
      })
      expect(middleware.call('REQUEST_METHOD' => 'GET')).to eq [200, {}, ['body']]
    end
  end
end
