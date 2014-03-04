
class TimeQuota
  attr_accessor :start_time, :end_time

  # start_time 要小于 end_time
  def initialize(start_time, end_time)
    start_time,end_time = adjust_time(start_time,end_time)
    @start_time, @end_time = start_time ,end_time
  end

  # 判断时间段是否合法, 合法返回true,否则返回false
  # start_time 在时间段内 或者 end_time 在时间段内都是非法
  # start_time在adjust_time中加1秒 !!!!
  def valid?(time_quota)
    if time_quota.section_second > self.section_second
      long_quota, short_quota = time_quota, self
    else
      long_quota, short_quota = self, time_quota
    end
    
    if long_quota.in_section?(short_quota.start_time+1) or 
       long_quota.in_section?(short_quota.end_time-1)
      false
    else
      true
    end
  end

  def inspect
    "start time = #{start_time}, end time = #{end_time}"
  end

  def section_second
    end_time - start_time    
  end

  def in_section?(time_point)
    if time_point <= @end_time and time_point >= @start_time
      true
    else
      false
    end
  end


  private
    def adjust_time(start_time,end_time)
      start_time,end_time = end_time,start_time if start_time > end_time
      [start_time,end_time]
    end

end


=begin
start_time = Time.mktime(2014,2,25,8,30)
end_time = Time.mktime(2014,2,25,10)
time_point1 = Time.mktime(2014,2,25,21,5)
time_point2 = Time.mktime(2014,2,25,10)


timequota = TimeQuota.new(end_time,start_time)
puts timequota.inspect

timequota2 = TimeQuota.new(time_point1,time_point2)
puts timequota2.inspect


puts timequota.valid?(timequota2)
=end