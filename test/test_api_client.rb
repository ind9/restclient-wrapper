require 'minitest/autorun'
require 'api_client'
require 'mocha/mini_test'


class ApiClientTest < Minitest::Unit::TestCase
  
  def setup
    @client = ApiClient.new("localhost", 3000)
  end

  def test_set_headers()
    @client.set_headers({'header1' => 123})
    assert_equal({'header1' => 123}, @client.headers)
  end

  def test_url()
    url_string = @client.send(:url, 'get', '/all', {:request_params => {'a' => 1, 'b' => [1,2,3], 'c' => false}})
    assert_equal(url_string, "http://localhost:3000/all?a=1&b=1&b=2&b=3&c=false")
  end

  def test_payload()
    assert_equal(@client.send(:payload, {}), {})
    assert_equal("{\"a\":1}", @client.send(:payload, {:request_params => {'a' => 1}}))
  end
  
  def test_format_response
    assert_instance_of(ApiResponseBase, @client.send(:format_response, 200, "ok", {}))
    assert_equal(@client.send(:format_response, 200, "ok", {}).status_code, 200)
    assert_equal(@client.send(:format_response, 200, "ok", {}).status_message, "ok")
    assert_equal(@client.send(:format_response, 200, "ok", {"data" => true}).data, {"data" => true})
  end
  
  def test_request
    @client.stubs(:get).returns("[]")
    assert_equal(@client.send(:request, 'get', '/all', {}).status_code, 200)
  end
end
