FactoryGirl.define do
  factory :app do
    path "/home/lucas/hello"
    name "hello"
    instance 1
    memory_limit "256m"
    domain "hello.dc.escience.cn"
    status "running"
  end  
end