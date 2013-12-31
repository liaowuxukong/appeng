
require "spec_helper"

describe "App page" do
  subject { page }

  describe "push app" do
    before { visit new_app_path}
    let(:submit) { "create new app"}

    describe "with invalid information" do
      it "should not create an app" do
        expect { click_button submit}.not_to change(App, :count)
      end
    end

    describe "with valid information" do
      before do
        fill_in "path",       with: "/home/lucas/example"
        fill_in "name",       with: "example"
        fill_in "instance",   with: 1
        fill_in "memory_limit",with: "256m"
        fill_in "domain",      with: "example.dc.escience.cn"
      end
      it "should create an app" do 
        expect { click_button submit}.to change(App, :count).by(1)
      end
    end

  end

end