
require "net/http"

class APIBus

  def initialize
    @service_uris = {}
    @service_uris[:get_time] = "http://showtime.dc.escience.cn/"
  end

  def get_service(name,*params)
    uri = @service_uris[name.to_sym]
    resp = Net::HTTP.get_response(URI.parse(uri))
    resp.body
  end

end
