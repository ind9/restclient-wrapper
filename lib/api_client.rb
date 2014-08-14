require 'api_response_base'
require 'exceptions'

require 'rest_client'
require 'uri'
require 'hashie'
require 'active_support'

class ApiClient
  attr_accessor :host, :port, :protocol, :headers
  

  def initialize(host, port, protocol = 'http')
    @host = host
    @port = port
    @protocol = protocol
    @headers = {}
  end

  def set_headers(hash)
    @headers = @headers.merge(hash)
  end

  def request(method, path, options = {})
    start_time = Time.now
    response = data = nil
    path = url(method, path, options)
    data = payload(options) if method != 'get'
    begin
      case method
      when 'get'
        response = self.get(path)
      when 'post'
        response = self.post_or_put(path, data)
      when 'put'
        response = self.post_or_put(path, data)
      when 'delete'
        response = self.delete(path)
      end
    rescue RestClient::BadRequest => e
      log_request format_error(e, method, path, @headers, data)
      raise BadRequest.new(JSON.parse(e.http_body)["statusMessage"])								
    rescue RestClient::PreconditionFailed => e
      log_request format_error(e, method, path, @headers, data)
      raise PreconditionFailed.new(JSON.parse(e.http_body)["statusMessage"])
    rescue RestClient::Conflict => e
      log_request format_error(e, method, path, @headers, data)
      raise Conflict.new(JSON.parse(e.http_body)["statusMessage"])
    rescue RestClient::ResourceNotFound => e
      log_request format_error(e, method, path, @headers, data)
      raise ResourceNotFound.new(JSON.parse(e.http_body)["statusMessage"])
    rescue RestClient::Unauthorized => e
      log_request format_error(e, method, path, @headers, data)
      raise UnAuthorizedException.new(JSON.parse(e.http_body)["statusMessage"])								
    rescue Exception => e
      log_request "Error #{e.inspect} while executing #{method} on #{path} with headers : #{@headers} and data : #{data}"
      raise e
    end
    unless response.empty?
      response = ::ActiveSupport::JSON.decode(response)
      response = to_hashie(response)
    end
    return format_response(200, 'ok', response)
  end

  def get(path)
    RestClient::Request.execute(:method => :get, :url => path, :headers => @headers,  :content_type => 'application/json; charset=UTF-8')
  end

  def post_or_put(path, data)
    RestClient::Request.execute(:method => :post, :url => path, :payload => data, :headers => @headers, :content_type => 'application/json; charset=UTF-8')
  end

  def delete(path)
    RestClient.delete(path, @headers)
  end
  
  
  def log_request(string)
    p string
  end

  private
 
  def url(method, path, options = {})
    query_string = build_query(options[:request_params]) if method.eql? 'get'
    uri = URI::HTTP.build(:host => @host, :port => @port, :path => URI::encode(path), :query => query_string)
    uri.to_s
  end

	def escape_string(str)
		URI.escape(str, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
	end

  def payload(options)
    return {} if !options.has_key? :request_params
    ::ActiveSupport::JSON.encode(options[:request_params])
  end
  
  def build_query(options)
    return nil if options.nil? or options.empty?
    options = options.collect do |name, value|
      if value.is_a? Array
        value.collect { |v| "#{name}=#{v.class.to_s != 'Fixnum' ? escape_string(v.to_s) : v}" }.join('&')
      else
        "#{name}=#{!value.nil? ? (value.class.to_s != 'Fixnum' ? escape_string(value.to_s) : value) : ''}"
      end
    end.join('&')
    options
  end 

  def format_error(e, method, path, headers, data)
    return "Error #{JSON.parse(e.http_body)["statusMessage"]} while executing #{method} on #{path} with headers : #{headers} and data : #{data} | status = #{e.response.code}"
  end
  
  def format_response(status_code, status_message, data = nil)
    return ApiResponseBase.new(status_code, status_message, data)
  end
  
  	


  def to_hashie json
    if json.is_a? Array
      json.collect! { |x| x.is_a?(Hash) ? Hashie::Mash.new(x) : x }
    else
      Hashie::Mash.new(json)
    end
  end
end
