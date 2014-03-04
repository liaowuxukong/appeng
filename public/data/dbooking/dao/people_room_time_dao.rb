root_path = File.join(File.dirname(__FILE__), "..")
$LOAD_PATH.unshift(root_path) unless $LOAD_PATH.include?(root_path) 

require "help/db_help"
require "model/room"
require "model/time_quota"

module DBOOKING::PeopleRoomTimeDAO
  include DBOOKING::DBHelp

# !!!!
# 查找的时候如果有start time的话，就不需要进行全部遍历
# 历史数据不需要加入查找
  # 通过 room_number,start_time,end_time找到对应的预订用户
  def find_people_by_room_time(room_number,start_time,end_time)
    sql_query = "select * from rooms_time_people where "+
                "room_number=\"#{room_number}\" and "+
                "start_time = \"#{start_time.to_s}\" and "+
                "end_time = \"#{end_time.to_s}\";"
    
    result,msg = exec_select(sql_query,"select success")
    return [false,"state_code:31,msg:#{msg}"] unless result
    return [false,"state_code:32,msg:not found anything"] if result.count == 0
    people_email = ""
    result.each do |row|
      people_email = row["people_email"]
    end
    [true,people_email]
  end

  def find_room_by_people_time(email,start_time,end_time)
    
  end

  def find_time_by_people_room(email,room_number)
    
  end

  # 根据 roomnumber发现所有的预订
  # 返回一个hash， {people_email =>[time_quota1,time_quota2]}
  def find_all_by_room(room_number)
    sql_query = "select * from rooms_time_people where room_number=\"#{room_number}\";"
    result,msg = exec_select(sql_query,"select success")
    return [false,"state_code:31,msg:#{msg}"] unless result

    booking_hash = {}
    result.each do |row|
      people_email = row["people_email"]
      time_quota_list = booking_hash[people_email] || Array.new
      time_quota_list << TimeQuota.new(row['start_time'],row['end_time'])
      booking_hash[people_email] = time_quota_list
    end
    [true,booking_hash]
  end

  # 将people_email,room_number,start_time,end_time插入数据库
  def insert_people_room_time(people_email,room_number,start_time,end_time)
    sql_query = "insert into rooms_time_people "+
                "(room_number,people_email,start_time,end_time) values "+
                "(\"#{room_number}\",\"#{people_email}\","+
                "\"#{start_time}\",\"#{end_time}\");"
    exec_proc(sql_query,"insert success")
  end

  # 从数据库中删除一个数据
  def delete(people_email,room_number,start_time,end_time)
    sql_query = "delete from rooms_time_people where "+
                "people_email=\"#{people_email}\" and "+
                "room_number=\"#{room_number}\" and "+
                "start_time=\"#{start_time}\" and "+
                "end_time=\"#{end_time}\";"
    
    exec_proc(sql_query,"delete success")
  end



end