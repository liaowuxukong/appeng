require "yaml"
libdir = File.expand_path(File.join(File.dirname(__FILE__)))

yaml_file = "/tmp/service1.yaml"
service_info = YAML::load(File.open(yaml_file))
funcitons = service_info["function"]
puts "appname = #{service_info["appname"]}"
puts "function count = #{funcitons.size}"
for i in (0...funcitons.size)
  puts "function #{i+1}:"
  puts "\tname:\t#{funcitons[i]["name"]}"
  puts "\tparams:\t#{funcitons[i]["params"]}"
  puts "\tinfo:\t#{funcitons[i]["info"]}"
  puts "\treturn:\t#{funcitons[i]["return"]}"
  puts "\texample:\t#{funcitons[i]["example"]}"
  puts
end
