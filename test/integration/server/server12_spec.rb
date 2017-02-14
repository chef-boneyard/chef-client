describe 'chef-server-directories' do
  describe file('/etc/opscode') do
    it { should be_directory }
    it { should be_owned_by 'root' }
  end

  describe file('/etc/opscode-analytics') do
    it { should be_directory }
    it { should be_owned_by 'opscode' }
    it { should be_grouped_into 'opscode' }
  end

  describe file('/var/log/opscode') do
    it { should be_directory }
    it { should be_owned_by 'opscode' }
    it { should be_grouped_into 'opscode' }
  end

  describe file('/var/opt/opscode') do
    it { should be_directory }
    it { should be_owned_by 'root' }
  end
end
