$LOAD_PATH.unshift(File.dirname(__FILE__))

require "rubygems"
require "sinatra"
require "net/http"
require 'yaml'

get '/' do 
  "index"
end


#get '/weathers/:city_name' do
#  yaml_file = File.expand_path(File.join(File.dirname(__FILE__), "lib/city_codes.yaml"))
#  city_codes = YAML::load(File.open(yaml_file))
#  @city_code = city_codes[params[:city_name]]
#  uri = "http://m.weather.com.cn/data/"+@city_code+".html";
#  uri = URI.parse(uri)
#  resp = Net::HTTP.get_response(uri)
#  resp.body
#end

get '/weathers/:city_code' do
  uri = "http://m.weather.com.cn/data/"+params[:city_code]+".html";
  uri = URI.parse(uri)
  resp = Net::HTTP.get_response(uri)
  resp.body
end


