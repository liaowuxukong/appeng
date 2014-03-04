root_path = File.join(File.dirname(__FILE__), "..")
$LOAD_PATH.unshift(root_path) unless $LOAD_PATH.include?(root_path) 

require "dao/people_dao"
require "model/room"
require "model/time_quota"

class People
  class << self
    include DBOOKING::PeopleDAO
  end

  attr_accessor :email
  def initialize(email)
    @email = email
  end

  def same_people(people)
    self.email == people.email
  end

  def save
    self.class.insert(self)
  end

  def destroy
    self.class.delete(self)
  end

  def update(new_people)
    self.class.update(new_people,self)
  end

  def inspect
    email
  end

  # 订会议室
  def booking(room_number,start_time,end_time)
    result,room = Room.find_by_number(room_number)
    return [false,room] unless result
    room.booking(self,TimeQuota.new(start_time,end_time))
  end

  # 2. 如果不是本人，则无法取消
  # 3. 如果是本人，则取消
  def cancel_booking(room_number,start_time,end_time)
    result,room = Room.find_by_number(room_number)
    return [false,room] unless result
    room.cancel_booking(self,TimeQuota.new(start_time,end_time))
  end

  # 寻找某个时间段内没有预订的房间
  def find_unbooking_room(start_time,end_time)
    unbooking_rooms_list = []
    result,rooms_list = Room.all
    return result,rooms_list unless result
    rooms_list.each do |room|
      isbooking,msg =  room.booking?(TimeQuota.new(start_time,end_time))
      unbooking_rooms_list << room unless isbooking
    end
    [true,unbooking_rooms_list]
  end

  # 显示所有会议室
  def find_all_rooms
    Room.all
  end



end

=begin
people = People.new("wocao@cstnet.cn")
result,msg = people.save
puts msg
=end

