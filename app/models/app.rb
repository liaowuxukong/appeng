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
libdir = File.expand_path(File.join(File.dirname(__FILE__), "../../lib"))

mothershiplibdir = "#{libdir}/mothership/lib"
$LOAD_PATH.unshift(mothershiplibdir) unless $LOAD_PATH.include?(mothershiplibdir)
cfliddir = "#{libdir}/cf_lib/lib"
$LOAD_PATH.unshift(cfliddir) unless $LOAD_PATH.include?(cfliddir)


require "cf"
require "cf/plugin"

$stdout.sync = true

CF::Plugin.load_all

class App < ActiveRecord::Base
  attr_accessible :domain, :instance, :memory_limit, :name, :path
  attr_protected :status

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
    push_path  = Rails.root.join('public', 'data', path.original_filename).to_s
    puts "push_path=#{push_path}"
    push_path = push_path.split(".")[0]
    puts "push_path=#{push_path}"

    host = domain.split(".").shift
    last_domain = domain[host.length+1..-1]

    inputs = {name:name, path:push_path, instance: instance,
          memory: memory_limit, host: host, domain: last_domain}

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
  

end
