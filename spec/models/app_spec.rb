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

require 'spec_helper'

describe App do

  before do 
    @app = App.new(name:"hello", path:"/home/lucas/hello/",instance: 1,
                  memory_limit: "256m", domain:"hello.dc.escience.cn")
  end
  subject {@app}

  describe "test variable respond" do
    @all_variables = [:domain, :instance, :memory_limit, :name, :path]
    @all_variables.each do |variable|
      it { should respond_to(variable)}
    end
    it { should be_valid }

    @all_variables.each do |variable|
      describe "when #{variable} is not present" do
        before { @app.send("#{variable}="," ")}
        it { should_not be_valid}
      end
    end

  end # describe "test variable respond" do

  describe "when name and domain are already taken" do
    before do
      same_app = @app.dup
      same_app.name = @app.name.upcase
      same_app.domain = @app.domain.upcase
      same_app.save
    end
    it { should_not be_valid}
  end



end
