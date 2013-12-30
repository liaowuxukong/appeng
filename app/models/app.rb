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

class App < ActiveRecord::Base
  attr_accessible :domain, :instance, :memory_limit, :name, :path
  validates :domain, presence: true, uniqueness: { case_sensitive: false }
  validates :instance, presence: true
  validates :memory_limit, presence: true
  validates :name, presence: true, length: { maximum: 50 }, uniqueness: { case_sensitive: false }
  validates :path, presence: true

  before_save do |app| 
    app.name = name.downcase
    app.domain = domain.downcase
  end
  

end

