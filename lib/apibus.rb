require "net/http"
require 'yaml' 

class APIBus

  # 从文件中读取，建立hash表
  def initialize
    yaml_file = File.expand_path(File.join(File.dirname(__FILE__), "service_map.yaml"))
    @service_uris = YAML::load(File.open(yaml_file))
  end

  def get_service(name,*params)
    uri = @service_uris[name.to_sym] 
    uri ||= @service_uris[name.to_s]
    resp = Net::HTTP.get_response(URI.parse(uri))
    resp.body
  end

end
