class PagesController < ApplicationController
  # http://amaras-tech.co.uk/people/morgan/article/52
  def index
    env['HTTP_X_REAL_IP'] ||= env['REMOTE_ADDR']
    @ip = env['HTTP_X_REAL_IP']
    @loc = query_quova(@ip)
    
    
  end

  # API location
  PRODUCTION_ENDPOINT = 'api.quova.com'
  PRODUCTION_PORT = 80

  # Your credentials
  API_KEY = ENV["quova_api_key"]
  API_SECRET = ENV["quova_api_secret"]
  API_VERSION = 'v1'
  # http://developer.quova.com/docs#sample_ruby
  def query_quova(ip_address)

    current_time = Time.now
    timestamp = Time.now.to_i.to_s
    puts API_KEY
    puts API_SECRET
    sig = Digest::MD5.hexdigest( API_KEY+API_SECRET+timestamp )

    request_url = "/#{API_VERSION}/ipinfo/#{ip_address}?apikey=#{API_KEY}&sig=#{sig}"

    http = Net::HTTP.new( PRODUCTION_ENDPOINT , PRODUCTION_PORT )
    http.start do |http|
      req = Net::HTTP::Get.new(request_url)

      resp, data = http.request(req)
      puts resp
      puts data
      return data
    end
    return nil
  end

end
