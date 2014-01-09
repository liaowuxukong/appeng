require "yaml"

yaml_file = "/tmp/service.yaml"
service_info = YAML::load(File.open(yaml_file))

puts service_info

puts "funtion size = #{service_info["function"].size}"
service_info["function"].each do |function|
  puts "#{function["info"]}:"
  print "\t params:"
  print_params = []
  function["params"].each do |param|
    unless  param["type"]
      if param["value"]
        print_params<<"#{param["value"]}"
      elsif param["tips"]
        print_params<<"\"#{param["tips"]}\""
      end  
    else
      hash_params = param["hash"]
      print_value = ""
      print_value +="{"
      hash_params.each{|hash_param| print_value += "#{hash_param["key"]}=>"+"\"#{hash_param["value"]}\""}
      print_value += "}"
      print_params << print_value
    end
  end
  print print_params.join(",")

  puts
end