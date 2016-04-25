source 'https://rubygems.org'

group :rake do
  gem 'rake'
  gem 'tomlrb'
end

group :lint do
  gem 'foodcritic', '~> 6.0'
  gem 'rubocop', '~> 0.38'
end

group :unit do
  gem 'berkshelf', '~> 4.3'
  gem 'chefspec', '~> 4.6'
end

group :kitchen_common do
  gem 'test-kitchen', '~> 1.7'
  # Windows specific, but kitchen won't work without these.
  gem 'winrm', '~> 1.6'
  gem 'winrm-fs', '~> 0.4.1'
end

group :kitchen_vagrant do
  gem 'kitchen-vagrant', '~> 0.19'
end

group :release do
  gem 'stove'
end
