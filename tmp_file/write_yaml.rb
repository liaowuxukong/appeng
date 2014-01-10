# -*- coding:utf-8 -*-
require "yaml"


service = {}
service["appname"] = "counter"
service["category"] = "counter"
functions = []
service["function"] = functions
create_fun = {}
index_fun = {}
show_fun = {}
update_fun = {}
delete_fun = {}


create_fun["name"] = "create"
create_fun["params"] = 'counter,create,counters,"counter_name",{"name"=>"counter_name"}'
create_fun["info"]  = '函数作用为创建计数器，参数counter,create,counters为固定参数，counter_name为string字符串，表明创建的计数器名字，{"name"=>"counter_name"}为一个hash，name表示后的counter_name为创建的字符串名字'
create_fun["return"] = '返回为json格式，如果创建失败返回如下结果{"status":"fail","info":"exist"}，如果创建成功返回如下结果，{"status":"success","value":{"hello1":0}}'
create_fun["example"] = '创建名为"hello"的计数器，apibus.get_service(:counter,:create,:counters,"hello",{name:"hello"})'

index_fun["name"] = "show all counters"
index_fun["params"] = 'counter,index,counters'
index_fun["info"] = '显示所有已经存在的计数器。参数counter,index,counters为固定参数'
index_fun["return"] = '返回为json格式，例如：{"status":"success","value":{"hello":11,"test_counter":110}}'
index_fun["example"] = 'apibus.get_service(:counter,:index,:counters)'

show_fun["name"] = "show one counter"
show_fun["params"] = 'counter,show,counters,"counter_name"'
show_fun["info"] = '显示某个计数器的值。参数counter,show,counters为固定参数,"counter_name"为需要显示的计数器名称'
show_fun["return"] = '返回为json格式，调用成功返回{"status":"success","value":{"counter_name":0}}，失败返回{"status":"fail","info":"counter name error"}'
show_fun["example"] = 'apibus.get_service(:counter,:show,:counters,"counter_name")'

update_fun["name"] = "update counter"
update_fun["params"] = 'counter,update,counters,"counter_name",{"value"=>"new_value"}'
update_fun["info"] = '更新某个计数器，前三个固定，counter_name为要更新的计数器的名称，在hash中设置值，如果不设置，默认为计数器加1'
update_fun["return"] = '返回为json格式，调用成功返回{"status":"success","value":{"counter_name":"12"}}，失败返回{{"status":"fail","info":"counter name error"}'
update_fun["example"] = 'apibus.get_service(:counter,:update,:counters,"counter_name")'

delete_fun["name"] = "delete_fun"
delete_fun["params"] = 'counter,update,counters,"counter_name"'
delete_fun["info"] = '删除某个计数器，前三个固定，counter_name为要更新的计数器的名称'
delete_fun["return"] = '返回为json格式，调用成功返回{"status":"success"}，失败返回{{"status":"fail","info":"counter name error"}'
delete_fun["example"] = 'apibus.get_service(:counter,:delete,:counters,"counter_name")'


functions<<create_fun<<index_fun<<show_fun<<update_fun<<delete_fun

puts service


yaml_file_path = "/tmp/service1.yaml"
File.open(yaml_file_path, 'w'){|f| YAML.dump(service, f)}
