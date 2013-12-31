require 'spec_helper'

describe CFMicro::McfCommand do
  shared_examples 'micro common inputs' do
    describe 'inputs' do
      subject { command.inputs }
      it { expect(subject[:vmx][:description]).to eq "Path to micro.vmx" }
      it { expect(subject[:password][:description]).to eq "Cleartext password for guest VM vcap user" }
    end

    describe 'arguments' do
      subject { command.arguments }

      it 'has the correct argument order' do
        should eq([
                      {:type => :required, :value => nil, :name => :vmx},
                      {:type => :optional, :value => nil, :name => :password}
                  ])
      end
    end
  end

  describe 'micro_status' do
    describe '#metadata' do
      let(:command) { Mothership.commands[:micro_status] }

      include_examples 'micro common inputs'

      describe 'command' do
        subject { command }

        its(:description) { should eq "Display Micro Cloud Foundry VM status" }
      end
    end
  end

  describe '#micro_offline' do
    describe 'metadata' do
      let(:command) { Mothership.commands[:micro_offline] }

      include_examples 'micro common inputs'

      describe 'command' do
        subject { command }

        its(:description) { should eq "Micro Cloud Foundry offline mode" }
      end
    end
  end

  describe '#micro_online' do
    describe 'metadata' do
      let(:command) { Mothership.commands[:micro_online] }

      include_examples 'micro common inputs'

      describe 'command' do
        subject { command }

        its(:description) { should eq "Micro Cloud Foundry online mode" }
      end
    end
  end
end
