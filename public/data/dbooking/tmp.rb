$LOAD_PATH.unshift(File.dirname(__FILE__))
require "model/people"
require "dao/people_room_time_dao"
require "net/http"



result,people = People.find_by_email("xuxin@cstnet.cn")




=begin

start_time = Time.mktime(2014,2,25,16,00)
end_time = Time.mktime(2014,2,25,15)


unbooking_rooms = people.find_unbooking_room(start_time,end_time)
puts unbooking_rooms.inspect


result,msg = people.cancel_booking("102",start_time,end_time)
puts msg



result,msg = people.booking("101",start_time,end_time)
puts msg;

=end

=begin
uri = "http://apibus.dc.escience.cn/"
params = {name_19900101:"dbooking",action_19900101:"index",
          resource_19900101:"rooms",id_19900101:"",
          people_email:"xuxin@cstnet.cn",
          start_time:"2014_2_25_16_0",
          end_time:"2014_2_25_18_0"}
uri = URI.parse(uri)
resp = Net::HTTP.post_form(uri,params)

puts resp.body
=end

=begin
uri = "http://apibus.dc.escience.cn/"
params = {name_19900101:"dbooking",action_19900101:"create",
          resource_19900101:"rooms_time",id_19900101:"",
          people_email:"wangqiao@cstnet.cn",
          room_number:"102",
          start_time:"2014_2_25_16_0",
          end_time:"2014_2_25_18_0"}
uri = URI.parse(uri)
resp = Net::HTTP.post_form(uri,params)

puts resp.body

=end



uri = "http://127.0.0.1:4567/rooms_time/0"
params = {method:"delete",
          people_email:"liwei@cstnet.cn",
          room_number:"102",
          start_time:"2014_2_25_16_00",
          end_time:"2014_2_25_18_00"}
uri = URI.parse(uri)
resp = Net::HTTP.post_form(uri,params)

puts resp.body













