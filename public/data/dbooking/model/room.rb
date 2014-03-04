root_path = File.join(File.dirname(__FILE__), "..")
$LOAD_PATH.unshift(root_path) unless $LOAD_PATH.include?(root_path) 

require "model/people"
require "model/time_quota"
require "dao/room_dao"
require "dao/people_room_time_dao"
class Room

  class << self
    include DBOOKING::RoomDAO
    include DBOOKING::PeopleRoomTimeDAO
  end

  attr_accessor :number, :description
  def initialize(number, description="")
    @number = number 
    @description = description
  end

  def save
    self.class.inserts(self)
  end

  def destroy
    self.class.delete(self)
  end

  def update(new_room)
    self.class.update(new_room,self)
  end

  def booking(people,new_quota)
    isbooking,msg = booking?(new_quota)
    return [false,msg] if isbooking
    result,msg = booking_room(people,new_quota)
    if result
      [true,"state_code:0,msg:booking success"]
    else
      [false,msg]
    end
  end


  # 1. 该房间该时间段的订阅人
  # 2. 如果不是本人，则无法取消
  # 3. 如果是本人，则取消
  def cancel_booking(people,time_quota)
    result,people_email = self.class.find_people_by_room_time(self.number,
                                                              time_quota.start_time,
                                                              time_quota.end_time)
    return [false,people_email] unless result
    return [false,"state_code:23,msg:privilege error"] if people.email != people_email
    result,msg = self.class.delete(people.email,self.number,time_quota.start_time,time_quota.end_time)
    return [false,msg] unless result
    [true,"state_code:0,msg:cancel success"]
  end

  # 预订返回true,否则返回false
  def booking?(new_quota)
    valid,people_email,time_quota = valid?(new_quota)
    # 时间合法，说明没有被预订
    if valid
      [false,""]
    else
      msg = "#{people_email} is booking, from #{time_quota.start_time} to #{time_quota.end_time}"
      [true,"state_code:24,msg:#{msg}"]
    end
  end

  private
    # 判断时间是否合法，合法返回true,nil,nil
    # 非法返回 false,冲突人，冲突时间
    def valid?(new_quota)
      result,booking_hash = Room.find_all_by_room(self.number)
      return [false,booking_hash] unless result
      #puts "number = #{self.number},booking_hash = #{booking_hash.inspect}"
      booking_hash.each do |people_email,time_quota_list|
        #puts "time_quota_list = #{time_quota_list}"
        time_quota_list.each do |time_quota|
          return [false,people_email,time_quota] unless time_quota.valid?(new_quota)
        end
      end
      [true,nil,nil]
    end

    # 加入数据库
    def booking_room(people,new_quota)
      result,msg = self.class.insert_people_room_time(people.email,self.number,
                                         new_quota.start_time,new_quota.end_time)
      [false,"state_code:31,msg:#{msg}"] unless result
      [true,"#{msg}"]
    end


end

=begin

people = People.new("xuxin@cstnet.cn")
start_time = Time.mktime(2014,2,25,8,30)
end_time = Time.mktime(2014,2,25,10)
timequota = TimeQuota.new(end_time,start_time)

room = Room.new('101')
result,msg = room.booking(people,timequota)
puts msg

timequota = TimeQuota.new(Time.mktime(2014,2,25,10,30), Time.mktime(2014,2,25,13))
result,msg = room.booking(people,timequota)
puts msg

puts room.booking_hash


=end




