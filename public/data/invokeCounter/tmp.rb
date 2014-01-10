require "json"


my_hash = {status:"success",value:{hello: 1, world:2}}
puts my_hash
my_hash.delete(:status)
puts my_hash