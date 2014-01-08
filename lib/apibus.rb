require "net/http"
require 'yaml' 

class APIBus

  # 从文件中读取，建立hash表
  def initialize
    yaml_file = File.expand_path(File.join(File.dirname(__FILE__), "service_map.yaml"))
    @service_uris = YAML::load(File.open(yaml_file))
  end

  def get_service(name,action,resource,id=0,params={})
    domain = @service_uris[name.to_sym] || @service_uris[name.to_s]
    #puts "domain = #{domain}"
    action = action.to_sym
    resource = resource.to_sym
    trans_method = 
      case action
      when :index,:show,:new,:edit
        :get
      else
        :post
      end
    #puts "trans_method = #{trans_method}"

    uri = domain + "/" + resource.to_s +
      case action
      when :show
        "/" + id.to_s        
      when :new
        "/" + "new"
      when :edit
        "/" + id.to_s + "/edit"
      when :update
        params[:method] = :put
        "/" + id.to_s        
      when :delete
        params[:method] = :delete
        "/" + id.to_s 
      else
        ""
      end
    puts "uri = #{uri}"
    
    uri = URI.parse(uri)
    resp = 
      case trans_method
      when :get
        Net::HTTP.get_response(uri)
      else
        Net::HTTP.post_form(uri,params)
      end
    resp.body
  end

end

