require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |config|
  config.color = true               # Use color in STDOUT
  config.formatter = :documentation # Use the specified formatter
  config.log_level = :error         # Avoid deprecation notice SPAM

  config.before do
    # Mock chef_version_for_provides to be < 18 for chef_client_scheduled_task so that resource will be evaluated
    # by current chef unit testing version
    class Chef::Resource
      class << self
        alias_method :chef_version_for_provides_original, :chef_version_for_provides

        def chef_version_for_provides(constraint)
          if ::File.basename(__FILE__) == 'scheduled_task.rb'
            '< 18.0' # Bump the constraint to current 17.x versions of Chef
          else
            chef_version_for_provides_original(constraint)
          end
        end
      end
    end

    unless RUBY_PLATFORM =~ /mswin|mingw32|windows/
      # This enables spec testing of windows recipes on nix OSes. This is used
      # to address the use of Win32::Service in recipe chef-client::task
      Win32 = Module.new unless defined?(Win32)
      Win32::Service = Class.new unless defined?(Win32::Service)
      allow(::Win32::Service).to receive(:exists?).with(anything).and_return(false)
      allow(::Win32::Service).to receive(:exists?).with('chef-client').and_return(true)
    end
  end
end
