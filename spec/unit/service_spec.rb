require 'spec_helper'

describe 'chef-client::service' do

  context 'AIX' do
    let(:chef_run) { ChefSpec::ServerRunner.new(platform: 'aix', version: '7.1').converge(described_recipe) }
    before do
      stub_command("lssrc -s chef").and_return(true)
      stub_command("lsitab chef").and_return(true)
    end
    it 'should use the src service' do
      expect(chef_run).to include_recipe('chef-client::src_service')
    end
  end

  context 'Arch' do
    let(:chef_run) { ChefSpec::ServerRunner.new(platform: 'arch', version: '3.10.5-1-ARCH').converge(described_recipe) }
    it 'should use the systemd service' do
      expect(chef_run).to include_recipe('chef-client::systemd_service')
    end
  end

  context 'CentOS 5' do
    let(:chef_run) { ChefSpec::ServerRunner.new(platform: 'centos', version: '5.10').converge(described_recipe) }
    it 'should use the init service' do
      expect(chef_run).to include_recipe('chef-client::init_service')
    end
  end

  context 'CentOS 6' do
    let(:chef_run) { ChefSpec::ServerRunner.new(platform: 'centos', version: '6.5').converge(described_recipe) }
    it 'should use the init service' do
      expect(chef_run).to include_recipe('chef-client::init_service')
    end
  end

  context 'CentOS 7' do
    let(:chef_run) { ChefSpec::ServerRunner.new(platform: 'centos', version: '7.0').converge(described_recipe) }
    it 'should use the systemd service' do
      expect(chef_run).to include_recipe('chef-client::systemd_service')
    end
  end

  context 'Fedora' do
    let(:chef_run) { ChefSpec::ServerRunner.new(platform: 'fedora', version: '20').converge(described_recipe) }
    it 'should use the systemd service' do
      expect(chef_run).to include_recipe('chef-client::systemd_service')
    end
  end

  context 'FreeBSD' do
    let(:chef_run) { ChefSpec::ServerRunner.new(platform: 'freebsd', version: '9.2').converge(described_recipe) }
    it 'should use the bsd service' do
      expect(chef_run).to include_recipe('chef-client::bsd_service')
    end
  end

  context 'Mac OS X' do
    let(:chef_run) { ChefSpec::ServerRunner.new(platform: 'mac_os_x', version: '10.8.2').converge(described_recipe) }
    it 'should use the launchd service' do
      expect(chef_run).to include_recipe('chef-client::launchd_service')
    end
  end

  context 'OpenSuSE' do
    let(:chef_run) { ChefSpec::ServerRunner.new(platform: 'opensuse', version: '13.1').converge(described_recipe) }
    it 'should use the init service' do
      expect(chef_run).to include_recipe('chef-client::init_service')
    end
  end

  context 'Solaris' do
    let(:chef_run) { ChefSpec::ServerRunner.new(platform: 'solaris2', version: '5.11').converge(described_recipe) }
    it 'should use the smf service' do
      expect(chef_run).to include_recipe('chef-client::smf_service')
    end
  end
end
