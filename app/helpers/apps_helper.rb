require 'yaml'
require 'mysql2'
module AppsHelper
  def get_info
    yaml_file  = @app.service_file_path
    service_info = YAML::load(File.open(yaml_file))
    service_info
  end

  def get_client
    client = Mysql2::Client.new(
      host: "10.10.1.159",
      username: 'root',
      password: '',
      database: 'appeng',
      port: 3306
    )
    client
  end

  
  def exec_select(sql_query,success_message="")
    begin
      result = get_client.query(sql_query)
      [result,success_message]
    rescue Mysql2::Error=>e
      [false,e]
    end
  end

  def exec_proc(sql_query,success_message="")
    begin
      get_client.query(sql_query)
      [true,success_message]
    rescue Mysql2::Error=>e
      [false,e]
    end      
  end

end
