node.set["ohai"]["disabled_plugins"] = ["passwd"]

include_recipe "chef-client::config"
