$LOAD_PATH.unshift(File.dirname(__FILE__))

require "rubygems"
require "sinatra"
require "json"
require "lib/apibus"

enable :sessions



before do
  @api = APIBus.new
  return_value = @api.get_service(:counter,:update,:counters,"test_counter")
  return_hash = JSON.parse(return_value)
  if return_hash["status"] == "fail"
    @api.get_service(:counter,:create,:counters,"test_counter",{name:"test_counter"})
  else
    @counter = {}
    @counter[:name] = "test_counter"
    @counter[:value] = return_hash["value"]["test_counter"]
  end
end

after do

end


get '/' do 
  @counter.to_json
end
