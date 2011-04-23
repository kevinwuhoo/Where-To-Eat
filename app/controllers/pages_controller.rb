class PagesController < ApplicationController
  # http://amaras-tech.co.uk/people/morgan/article/52
  def index
  end
  
  def nom
    
    env["HTTP_X_REAL_IP"] ||= env["REMOTE_ADDR"]
    @ip = env["HTTP_X_REAL_IP"]
    
    if @ip == "127.0.0.1"
      @resp, @data = query_quova("128.54.44.220")
    else
      @resp, @data = query_quova(@ip)
    end
    
    @doc  = Nokogiri::HTML(@data)
    @lat = @doc.xpath("//latitude").inner_html
    @lng = @doc.xpath("//longitude").inner_html

    # Convert categories form human readable to yelp api name
    @cat = []
    params[:form_categories].split(",").each do |c|
      @cat << $all_categories[c]
    end
    if @cat.empty?
      @cat = nil
    else
      @cat = @cat.join(",")
    end
    @dist = params[:form_distance].split()[0]
    @price = params[:form_price].length
    
    @yelp = JSON.parse(query_yelp @lat, @lng, @cat, @dist)
    @stores = []
    # Go through all stores and parse out/create necessary information, put in @store array
    @yelp["businesses"].shuffle.each do |store|
      
      # Get the rating from the link to pic
      rate = store["rating_img_url"].split("stars_")[1].split(".")[0].split("_")  
      
      # Generate a string for categories
      #if store["categories"].nil?
      #  cat_str = ""
      #else
        cat_str = [] 
        store["categories"].each do |cat|
          cat_str << cat[0]
        end
        cat_str = cat_str.join(", ")
      #end
      
      # Append to array @stores
      @stores << {:name => store["name"], 
                  :address => store["location"]["address"], 
                  :cross_streets => store["location"]["cross_streets"], 
                  :city => store["location"]["city"], 
                  :state_code => store["location"]["state_code"], 
                  :postal_code => store["location"]["postal_code"], 
                  :phone => store["display_phone"], 
                  :url => store["url"], 
                  :rate => rate[0], 
                  :rate_half => rate[1], 
                  :categories => cat_str}
      #categories, address, phone, website, hours, map, price, yelp link
    end
    @stores = @stores.to_json
  end
  
  def query_yelp(lat, lng, cat = nil, dist = nil)

    require 'oauth'

    consumer_key = ENV["yelp_consumer_key"]
    consumer_secret = ENV["yelp_consumer_secret"]
    token = ENV["yelp_token"]
    token_secret = ENV["yelp_token_secret"]

    api_host = 'api.yelp.com'

    consumer = OAuth::Consumer.new(consumer_key, consumer_secret, {:site => "http://#{api_host}"})
    access_token = OAuth::AccessToken.new(consumer, token, token_secret)

    path_arr = ["/v2/search?"]
    path_arr << "&ll=#{lat},#{lng}"
    #path_arr << "&ll=37.771008,-122.41175"    # Yelp HQ
    
    if cat.nil?
      path_arr << "&category_filter=restaurants"
    else
      path_arr << "&category_filter=#{cat}"
    end
    
    if dist.nil?
      path_arr << "&radius=10"
    else
      path_arr << "&radius=#{dist}"
    end
    
    path = path_arr.join ""
    #puts path
    req = access_token.get(path).body
    #puts req
    return req
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

  $all_categories = {"Afghan" => "afghani",
  "African" => "african",
  "American" => "newamerican,tradamerican",
  "Argentine" => "argentine",
  "Asian Fusion" => "asianfusion",
  "Barbeque" => "bbq",
  "Basque" => "basque",
  "Belgian" => "belgian",
  "Brasseries" => "brasseries",
  "Brazilian" => "brazilian",
  "Breakfast & Brunch" => "breakfast_brunch",
  "British" => "british",
  "Buffets" => "buffets",
  "Burgers" => "burgers",
  "Burmese" => "burmese",
  "Cajun/Creole" => "cajun",
  "Cambodian" => "cambodian",
  "Caribbean" => "caribbean",
  "Cheesesteaks" => "cheesesteaks",
  "Chicken Wings" => "chicken_wings",
  "Chinese" => "chinese",
  "Dim Sum" => "dimsum",
  "Creperies" => "creperies",
  "Cuban" => "cuban",
  "Delis" => "delis",
  "Diners" => "diners",
  "Ethiopian" => "ethiopian",
  "Fast Food" => "hotdogs",
  "Filipino" => "filipino",
  "Fish & Chips" => "fishnchips",
  "Fondue" => "fondue",
  "Food Stands" => "foodstands",
  "French" => "french",
  "Gastropubs" => "gastropubs",
  "German" => "german",
  "Gluten-Free" => "gluten_free",
  "Greek" => "greek",
  "Halal" => "halal",
  "Hawaiian" => "hawaiian",
  "Himalayan/Nepalese" => "himalayan",
  "Hot Dogs" => "hotdog",
  "Hungarian" => "hungarian",
  "Indian" => "indpak",
  "Indonesian" => "indonesian",
  "Irish" => "irish",
  "Italian" => "italian",
  "Japanese" => "japanese",
  "Korean" => "korean",
  "Kosher" => "kosher",
  "Latin American" => "latin",
  "Live/Raw Food" => "raw_food",
  "Malaysian" => "malaysian",
  "Mediterranean" => "mediterranean",
  "Mexican" => "mexican",
  "Middle Eastern" => "mideastern",
  "Modern European" => "modern_european",
  "Mongolian" => "mongolian",
  "Moroccan" => "moroccan",
  "Pakistani" => "pakistani",
  "Persian/Iranian" => "persian",
  "Peruvian" => "peruvian",
  "Pizza" => "pizza",
  "Polish" => "polish",
  "Portuguese" => "portuguese",
  "Russian" => "russian",
  "Sandwiches" => "sandwiches",
  "Scandinavian" => "scandinavian",
  "Seafood" => "seafood",
  "Singaporean" => "singaporean",
  "Soul Food" => "soulfood",
  "Soup" => "soup",
  "Southern" => "southern",
  "Spanish" => "spanish",
  "Steakhouses" => "steak",
  "Sushi Bars" => "sushi",
  "Taiwanese" => "taiwanese",
  "Tapas Bars" => "tapas",
  "Tapas/Small Plates" => "tapasmallplates",
  "Tex-Mex" => "tex-mex",
  "Thai" => "thai",
  "Turkish" => "turkish",
  "Ukrainian" => "ukrainian",
  "Vegan" => "vegan",
  "Vegetarian" => "vegetarian",
  "Vietnamese" => "vietnamese"}
end
