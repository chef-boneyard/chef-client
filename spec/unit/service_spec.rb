require 'spec_helper'

describe 'chef-client::service' do
  context 'AIX' do
    let(:chef_run) { ChefSpec::SoloRunner.new(platform: 'aix').converge(described_recipe) }
    before do
      stub_command('lssrc -s chef').and_return(true)
      stub_command('lsitab chef').and_return(true)
    end
    it 'should use the src service' do
      expect(chef_run).to include_recipe('chef-client::src_service')
    end
  end

  context 'Amazon Linux 201X' do
    let(:chef_run) { ChefSpec::SoloRunner.new(platform: 'amazon', version: '2018.03').converge(described_recipe) }
    it 'should use the init service' do
      expect(chef_run).to include_recipe('chef-client::init_service')
    end
  end

  context 'Amazon Linux 2' do
    let(:chef_run) { ChefSpec::SoloRunner.new(platform: 'amazon', version: '2').converge(described_recipe) }
    it 'should use the systemd service' do
      expect(chef_run).to include_recipe('chef-client::systemd_service')
    end
  end

  context 'CentOS 6' do
    let(:chef_run) { ChefSpec::SoloRunner.new(platform: 'centos', version: '6').converge(described_recipe) }
    it 'should use the init service' do
      expect(chef_run).to include_recipe('chef-client::init_service')
    end
  end

  context 'CentOS 7' do
    let(:chef_run) { ChefSpec::SoloRunner.new(platform: 'centos', version: '7').converge(described_recipe) }
    it 'should use the systemd service' do
      expect(chef_run).to include_recipe('chef-client::systemd_service')
    end
  end

  context 'CentOS 8' do
    let(:chef_run) { ChefSpec::SoloRunner.new(platform: 'centos', version: '8').converge(described_recipe) }
    it 'should use the systemd service' do
      expect(chef_run).to include_recipe('chef-client::systemd_service')
    end
  end

  context 'Debian' do
    let(:chef_run) { ChefSpec::SoloRunner.new(platform: 'debian').converge(described_recipe) }
    it 'should use the systemd service' do
      expect(chef_run).to include_recipe('chef-client::systemd_service')
    end
  end

  context 'Fedora' do
    let(:chef_run) { ChefSpec::SoloRunner.new(platform: 'fedora').converge(described_recipe) }
    it 'should use the systemd service' do
      expect(chef_run).to include_recipe('chef-client::systemd_service')
    end
  end

  context 'FreeBSD' do
    let(:chef_run) { ChefSpec::SoloRunner.new(platform: 'freebsd').converge(described_recipe) }
    it 'should use the bsd service' do
      expect(chef_run).to include_recipe('chef-client::bsd_service')
    end
  end

  context 'macOS' do
    let(:chef_run) { ChefSpec::SoloRunner.new(platform: 'mac_os_x').converge(described_recipe) }
    it 'should use the launchd service' do
      expect(chef_run).to include_recipe('chef-client::launchd_service')
    end
  end

  context 'SLES' do
    let(:chef_run) { ChefSpec::SoloRunner.new(platform: 'suse').converge(described_recipe) }
    it 'should use the systemd service' do
      expect(chef_run).to include_recipe('chef-client::systemd_service')
    end
  end

  context 'openSUSE Leap' do
    let(:chef_run) { ChefSpec::SoloRunner.new(platform: 'opensuse').converge(described_recipe) }
    it 'should use the systemd service' do
      expect(chef_run).to include_recipe('chef-client::systemd_service')
    end
  end

  context 'Ubuntu' do
    let(:chef_run) { ChefSpec::SoloRunner.new(platform: 'ubuntu').converge(described_recipe) }
    it 'should use the systemd service' do
      expect(chef_run).to include_recipe('chef-client::systemd_service')
    end
  end

  context 'Solaris' do
    let(:chef_run) { ChefSpec::SoloRunner.new(platform: 'solaris2').converge(described_recipe) }
    it 'should use the smf service' do
      expect(chef_run).to include_recipe('chef-client::smf_service')
    end
  end
end
