source 'http://rubygems.org'

gem 'rails', '3.0.7'
gem 'activesupport', '3.0.7'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mysql2'

gem 'oauth', '0.4.4'
gem 'acts-as-taggable-on'
gem 'aaronh-chronic'

group :production, :migration do
  gem 'mongrel', '>= 1.2.0.pre2'
  gem 'mongrel_cluster'
end

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
group :development do
  gem 'capistrano'
end

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :test do
  gem 'mocha', '0.9.10', :require => false
end
