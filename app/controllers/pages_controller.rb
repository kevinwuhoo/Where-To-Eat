class PagesController < ApplicationController
  # http://amaras-tech.co.uk/people/morgan/article/52
  def index
    '''
    env["HTTP_X_REAL_IP"] ||= env["REMOTE_ADDR"]
    @ip = env["HTTP_X_REAL_IP""]
    
    if @ip == "127.0.0.1"
      @resp, @data = query_quova("128.54.44.220")
    else
      @resp, @data = query_quova(@ip)
    end
    
    @doc  = Nokogiri::HTML(@data)
    @lat = @doc.xpath("//latitude").inner_html
    @lon = @doc.xpath("//longitude").inner_html
    #content = JSON.parse(query_yelp @lat, @lon)
    '''
  end

  def query_yelp(lat, lon)

    require 'oauth'

    consumer_key = ENV["yelp_consumer_key"]
    consumer_secret = ENV["yelp_consumer_secret"]
    token = ENV["yelp_token"]
    token_secret = ENV["yelp_token_secret"]

    api_host = 'api.yelp.com'

    consumer = OAuth::Consumer.new(consumer_key, consumer_secret, {:site => "http://#{api_host}"})
    access_token = OAuth::AccessToken.new(consumer, token, token_secret)

    path_arr = ["/v2/search?"]
    path_arr << "&ll=#{lat},#{lon}"
    path_arr << "&radius=10"
    path_arr << "&category=restaurant"
    path = path_arr.join ""

    return access_token.get(path).body
  end    

  # http://developer.quova.com/docs#sample_ruby
  PRODUCTION_ENDPOINT = 'api.quova.com'
  PRODUCTION_PORT = 80
  API_KEY = ENV["quova_api_key"]
  API_SECRET = ENV["quova_api_secret"]
  API_VERSION = 'v1'
  def query_quova(ip_address)
    current_time = Time.now
    timestamp = Time.now.to_i.to_s
    
    sig = Digest::MD5.hexdigest( API_KEY+API_SECRET+timestamp )
    request_url = "/#{API_VERSION}/ipinfo/#{ip_address}?apikey=#{API_KEY}&sig=#{sig}"
    
    http = Net::HTTP.new( PRODUCTION_ENDPOINT , PRODUCTION_PORT )
    http.start do |http|
      req = Net::HTTP::Get.new(request_url)
      resp, data = http.request(req)
      return resp, data
    end
    return nil
  end

end
