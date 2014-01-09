require "yaml"


service = {}
service["appname"] = "counter"
service["category"] = "counter"

function = []
service["function"] = function

fun_create = {}
fun_create["info"] = "create counter"
params = [{"type"=> "string","value"=>"counter"},
          {"type"=> "string","value"=>"create"},
          {"type"=> "string","value"=>"counters"},
          {"type"=>"string","tips" => "counter_name"},
          {"type"=>"hash", "hash"=>[{ "key" =>"name","value" => "counter_name"}]}
        ]
fun_create["params"] = params
return_value = {"type" => "json","value"=>[{"name" => "status","info" =>"create result"},
                                   {"name"=>"value","info" =>"new counter value"}]}
fun_create["return"] = return_value
function << fun_create


yaml_file_path = "/tmp/service1.yaml"
File.open(yaml_file_path, 'w'){|f| YAML.dump(service, f)}
