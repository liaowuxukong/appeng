root_path = File.join(File.dirname(__FILE__), "..")
$LOAD_PATH.unshift(root_path) unless $LOAD_PATH.include?(root_path) 

require "help/db_help"

module DBOOKING::PeopleDAO
  
    include DBOOKING::DBHelp

    # 返回 是否成功，信息
    def insert(people)
      sql_query = "insert into people (email) values (\"#{people.email}\");"
      exec_proc(sql_query,"insert success")
    end

    # 返回 是否成功，信息
    def delete(people)
      sql_query = "delete from people where email=\"#{people.email}\";"
      exec_proc(sql_query,"delete success");
    end

    # 返回 是否成功，信息
    def update(new_people,old_people)
      result,msg = find_by_email(old_people.email)
      return [false,msg.to_s] unless result
      sql_query = "update people set email=\"#{new_people.email}\" where email=\"#{old_people.email}\";"
      exec_proc(sql_query,"update success")
    end

    # 返回 是否成功，信息
    # 如果存在则，new一个people返回
    def find_by_email(email)
      sql_query = "select * from people where email = \"#{email}\";"
      result,msg = exec_select(sql_query,"select success")

      return [false,"state_code:11,msg:#{msg}"] unless result

      return [false,"state_code:12,msg:not find people #{email}"] if result.count == 0

      email = ""
      result.each do |row|
        email =  row["email"]
      end
      [true,People.new(email)]

    end

    # 返回数据库中的所有people，返回list
    def all
      sql_query = "select * from people;"
      result,msg = exec_select(sql_query,"select success")
      return [false,"state_code:11,msg:#{msg}"] unless result
      return [false,"state_code:12,msg:no people in the database"] if result.count == 0
      people_list = []
      result.each do |row|
        email = row["email"]
        people_list << People.new(email)
      end
      [true,people_list]
    end

end
