require "spec_helper"

module CF
  module Space
    describe Spaces do
      let(:full) { false }
      let(:app) { build(:app) }
      let!(:space_1) { build(:space, :name => "bb_second", :apps => [app], :service_instances => [build(:managed_service_instance)]) }
      let!(:space_2) { build(:space, :name => "aa_first", :apps => [app], :service_instances => [build(:managed_service_instance)], :domains => [build(:domain)]) }
      let!(:space_3) { build(:space, :name => "cc_last", :apps => [app], :service_instances => [build(:managed_service_instance)], :domains => [build(:domain)]) }
      let(:spaces) { [space_1, space_2, space_3] }
      let(:organization) { build(:organization, :spaces => spaces, :name => "foo") }
      let(:client) do
        build(:client).tap do |client|
          client.stub(:spaces => spaces, :current_organization => organization)
        end
      end

      before do
        stub_client_and_precondition
        CF::Populators::Organization.any_instance.stub(:populate_and_save!).and_return(organization)
        organization.stub(:spaces).and_return(spaces)
      end

      describe "metadata" do
        let(:command) { Mothership.commands[:spaces] }

        describe "command" do
          subject { command }
          its(:description) { should eq "List spaces in an organization" }
          it { expect(Mothership::Help.group(:spaces)).to include(subject) }
        end

        include_examples "inputs must have descriptions"

        describe "arguments" do
          subject { command.arguments }
          it "has the correct argument order" do
            should eq([{:type => :optional, :value => nil, :name => :organization}])
          end
        end
      end

      subject { cf %W[spaces --#{bool_flag(:full)} --no-quiet] }

      it "outputs that it is getting spaces" do
        subject

        stdout.rewind
        expect(stdout.readline).to match /Getting spaces.*OK/
        expect(stdout.readline).to eq "\n"
      end

      context "when there are no spaces" do
        let(:spaces) { [] }

        context "and the full flag is given" do
          let(:full) { true }

          it "displays yaml-style output with all space details" do
            CF::Space::Spaces.any_instance.should_not_receive(:invoke)
            subject
          end
        end

        context "and the full flag is not given (default is false)" do
          it "should show only the progress" do
            subject

            stdout.rewind
            expect(stdout.readline).to match /Getting spaces.*OK/
            expect(stdout).to be_eof
          end
        end
      end

      context "when there are spaces" do
        context "and the full flag is given" do
          let(:full) { true }

          it "displays yaml-style output with all space details" do
            CF::Space::Spaces.any_instance.should_receive(:invoke).with(:space, :space => space_2, :full => true)
            CF::Space::Spaces.any_instance.should_receive(:invoke).with(:space, :space => space_1, :full => true)
            CF::Space::Spaces.any_instance.should_receive(:invoke).with(:space, :space => space_3, :full => true)
            subject
          end
        end

        context "and the full flag is not given (default is false)" do
          it "displays tabular output with names, spaces and domains" do
            subject

            stdout.rewind
            stdout.readline
            stdout.readline

            expect(stdout.readline).to match /name\s+apps\s+services/
            spaces.sort_by(&:name).each do |space|
              expect(stdout.readline).to match /#{space.name}\s+#{name_list(space.apps)}\s+#{name_list(space.service_instances)}/
            end
            expect(stdout).to be_eof
          end
        end
      end
    end
  end
end
