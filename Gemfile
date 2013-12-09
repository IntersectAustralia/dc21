source 'http://rubygems.org'

gem 'rails', '3.2.16'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'pg'
gem "rubyzip", '0.9.9', :require => 'zip/zip'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'underscore-rails'
end

gem 'newrelic_rpm'
gem 'therubyracer'
gem 'bagit'
gem 'jquery-rails'
gem "haml", "~> 3.1.8"
gem "haml-rails"
gem "tabs_on_rails"
gem "devise", "~> 1.5.4"
gem "cancan"
gem "capistrano-ext"
gem "capistrano"
gem "capistrano_colors"
gem "colorize"
gem "squeel"
gem "httparty"
gem "decent_exposure"
gem "rvm-capistrano"
gem "google-analytics-rails"
gem 'highline' # This has (up until now) been implicitly included by capistrano
gem 'will_paginate'
gem 'bootstrap-sass'
gem 'bootstrap-will_paginate'
gem 'rake', '~> 0.9.2.2'
gem 'validates_timeliness', '~> 3.0'
gem 'rabl'
gem 'elif'

gem 'resque', :require => "resque/server"
gem 'resque-status', :require => "resque/status_server"
gem 'resque-scheduler', :require => 'resque_scheduler'
gem 'daemons-rails'

gem "devise_shibboleth_authenticatable", github: 'IntersectAustralia/devise_shibboleth_authenticatable', :branch => 'master'
gem "select2-rails"

group :development, :test do
  gem "rspec-rails"
  gem "factory_girl_rails", :require => false
  gem "shoulda-matchers"
  gem 'selenium-webdriver'
  gem "mailcatcher"

  # cucumber gems
  gem "email_spec"
  gem "cucumber"
  gem "cucumber-rails", :require => false
  gem "capybara", '~> 1.1.4'
  gem "database_cleaner"
  gem 'spork', '~> 0.9.0.rc'
  gem "launchy"    # So you can do Then show me the page
  gem "debugger", '~> 1.6.3'
  gem "zeus"
end

group :development do
  gem "rails3-generators"
end

group :test do
  gem "simplecov", :require => false
  gem "simplecov-rcov", :require => false
end

gem 'mimetype-fu', :require => 'mimetype_fu'

# exception tracker
gem 'whoops_rails_logger', git: 'https://github.com/IntersectAustralia/whoops_rails_logger.git'
gem 'create_deployment_record', git: 'https://github.com/IntersectAustralia/create_deployment_record.git'
gem 'acts_as_singleton'

gem 'rest-client'
