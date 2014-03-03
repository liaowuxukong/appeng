# == Schema Information
#
# Table name: apps
#
#  id           :integer         not null, primary key
#  path         :string(255)
#  name         :string(255)
#  instance     :integer
#  memory_limit :string(255)
#  domain       :string(255)
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

=begin
libdir = File.expand_path(File.join(File.dirname(__FILE__), "../../lib"))
mothershiplibdir = "#{libdir}/mothership/lib"
$LOAD_PATH.unshift(mothershiplibdir) unless $LOAD_PATH.include?(mothershiplibdir)
cfliddir = "#{libdir}/cf_lib/lib"
$LOAD_PATH.unshift(cfliddir) unless $LOAD_PATH.include?(cfliddir)
require "cf"
require "cf/plugin"
$stdout.sync = true
CF::Plugin.load_all
=end

require "apps_helper"

class App < ActiveRecord::Base
  include AppsHelper
  attr_accessible :domain, :instance, :memory_limit, :name, :path, :status


  validates :domain, presence: true, uniqueness: { case_sensitive: false }
  validates :instance, presence: true
  validates :memory_limit, presence: true
  validates :name, presence: true, length: { maximum: 50 }, uniqueness: { case_sensitive: false }
  validates :path, presence: true

  before_save do |app| 
    app.name = name.downcase
    app.domain = domain.downcase
  end

  def push
    puts "="*10+"push"+"="*10
    push_path  = path
    puts "push_path=#{push_path}"

    host = domain.split(".").shift
    last_domain = domain[host.length+1..-1]


    inputs = {name:name, path:push_path, instance: instance,
          memory: memory_limit, host: host, domain: last_domain}

    @save_name = inputs[:name].to_s
    @url = "http://"+inputs[:name].to_s+"."+inputs[:domain].to_s

    argv = "push --name=#{inputs[:name]} --path=#{inputs[:path]} --host=#{inputs[:host]} "+
           "--domain=#{inputs[:domain]} --memory=#{inputs[:memory]} "+
           "--instances=#{inputs[:instance]}"
    argv = argv.split()
    puts argv
    
    result = CF::CLI.start(argv)
    puts "result = #{result}"
    puts "="*10+"push"+"="*10
    true

  end

  def delete
    sql_query = "delete from name_url where name=\"#{name}\";"
    exec_proc(sql_query,"delete success");
  end

  def save_to_database
    
    sql_query = "insert into name_url (name,url) values (\"#{@save_name}\",\"#{@url}\");"
    result,msg = exec_proc(sql_query,"insert success")
    result
  end
  

end
