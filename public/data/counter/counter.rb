$LOAD_PATH.unshift(File.dirname(__FILE__))

require "rubygems"
require "sinatra"
require "json"

enable :sessions

before do
  
  puts "$counters = #{$counters}"
  $counters = {} unless  $counters
  @return_value = {} unless @return_value

end

after do

end


get '/' do 
  @return_value[:status] = "success"
  @return_value[:value] = $counters
  @return_value.to_json
end

# index
get '/counters' do
  @return_value[:status] = "success"
  @return_value[:value] = $counters
  @return_value.to_json
end

# show
get '/counters/:id' do
  @id = params[:id]
  if $counters[@id]
    @return_value[:status] = "success"
    @return_value[:value] = {"#{@id}"=>$counters[@id]}
  else
    @return_value[:status] = "fail"
    @return_value[:info] = "counter name error"
  end
  @return_value.to_json

end

#create
post '/counters' do
  name = params[:name]
  if $counters[name]
    @return_value[:status] = "fail"
    @return_value[:info] = "exist"
  else
    $counters[name] = 0
    @return_value[:status] = "success"
    @return_value[:value] = {"#{name}" => 0}
  end
  @return_value.to_json
end

# edit
get '/counters/:id/edit' do
  @return_value[:status] = "fail"
  @return_value[:info] = "function error"  
  @return_value.to_json
end
 
# update / delete
post '/counters/:id' do
  method = params[:method]
  if method == "put"
    update(params)
  elsif method == "delete"
    delete(params)
  else
    @return_value[:status] = "fail"
    @return_value[:info] = "params error"
    @return_value.to_json
  end
    
end

def update(params)
  name = params[:id]
  new_value = params[:value]
  if $counters[name]
    if new_value
      $counters[name] = new_value.to_i
    else
      $counters[name] = $counters[name] + 1
    end
    @return_value[:status] = "success"
    @return_value[:value] = {"#{name}" => "#{$counters[name]}"}
  else
    @return_value[:status] = "fail"
    @return_value[:info] = "counter name error"
  end
  @return_value.to_json
end

def delete(params)
  name = params[:id]
  if $counters[name]
    $counters.delete(:name)
    @return_value[:status] = "success"
  else
    @return_value[:status] = "fail"
    @return_value[:info] = "counter name error"
  end
  @return_value.to_json

end


