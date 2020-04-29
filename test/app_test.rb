# ENV['APP_ENV'] = 'test'

require 'test/unit'
require 'rack/test'

require './app'

set :environment, :test

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    App
  end

  def test_basic
    get '/'

    assert last_response.ok?
    assert_equal last_response.body, 'sup here'
  end
end
