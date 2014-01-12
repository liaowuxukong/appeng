require "yaml"

$LOAD_PATH.unshift(File.dirname(__FILE__))

city_code_file = File.open("lib/city_code")
city_codes = {}

city_code_file.each do |line|
  if line.strip.size!=0
    city_code,city_name = line.strip.split("=")
    city_codes[city_name] = city_code
  end
end

File.open("lib/city_codes.yaml", 'w'){|f| YAML.dump(city_codes, f)}

