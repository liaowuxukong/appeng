require 'yaml'
module AppsHelper
  def get_info
    yaml_file  = @app.service_file_path
    service_info = YAML::load(File.open(yaml_file))
    service_info
  end
end
