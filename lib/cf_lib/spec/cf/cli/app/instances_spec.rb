require "spec_helper"
require "stringio"

module CF
  module App
    describe Stats do
      let(:global) { {:color => false} }
      let(:inputs) { {:app => apps[0]} }
      let(:given) { {} }
      let(:client) { build(:client) }
      let(:apps) { [build(:app, :client => client, :name => "basic-app-name")] }
      let(:time) { Time.local(2012, 11, 1, 2, 30) }

      before do
        client.stub(:apps).and_return(apps)
        CF::CLI.any_instance.stub(:client).and_return(client)
        CF::CLI.any_instance.stub(:precondition).and_return(nil)

        client.base.stub(:instances).with(anything) do
          {
            "12" => {:state => "STOPPED", :since => time.to_i, :debug_ip => "foo", :debug_port => "bar", :console_ip => "baz", :console_port => "qux"},
            "1" => {:state => "STOPPED", :since => time.to_i, :debug_ip => "foo", :debug_port => "bar", :console_ip => "baz", :console_port => "qux"},
            "2" => {:state => "STARTED", :since => time.to_i, :debug_ip => "foo", :debug_port => "bar", :console_ip => "baz", :console_port => "qux"}
          }
        end
      end

      subject do
        capture_output do
          Mothership.new.invoke(:instances, inputs, given, global)
        end
      end

      describe "metadata" do
        let(:command) { Mothership.commands[:instances] }

        describe "command" do
          subject { command }
          its(:description) { should eq "List an app's instances" }
          it { expect(Mothership::Help.group(:apps, :info)).to include(subject) }
        end

        include_examples "inputs must have descriptions"

        describe "arguments" do
          subject { command.arguments }
          it "has no arguments" do
            should eq([{:type => :splat, :value => nil, :name => :apps}])
          end
        end
      end

      it "prints out the instances in the correct order" do
        subject
        expect(output).to say("instance #1")
        expect(output).to say("instance #2")
        expect(output).to say("instance #12")
      end

      it "prints out one of the instances correctly" do
        subject
        expect(output).to say("instance #2: started")
        expect(output).to say("  started: #{time.strftime("%F %r")}")
        expect(output).to say("  debugger: port bar at foo")
        expect(output).to say("  console: port qux at baz")
      end
    end
  end
end
