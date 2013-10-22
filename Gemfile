source 'http://rubygems.org'

gem 'rails', '3.1.12'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'pg'
gem "rubyzip", :require => 'zip/zip'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.1.4'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'newrelic_rpm'
gem 'therubyracer'
gem 'bagit'
gem 'jquery-rails'
gem "haml"
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
gem 'daemons-rails'

group :development, :test do
  gem "rspec-rails"
  gem "factory_girl_rails", :require => false
  gem "shoulda-matchers"
  gem 'selenium-webdriver', '~> 2.35.1'

  # cucumber gems
  gem "email_spec"
  gem "cucumber"
  gem "cucumber-rails", :require => false
  gem "capybara"
  gem "database_cleaner"
  gem 'spork', '~> 0.9.0.rc'
  gem "launchy"    # So you can do Then show me the page
  gem "debugger"
  gem "zeus"
end

group :development do
  gem "rails3-generators"
end

group :test do
  gem "metrical"
  gem "simplecov", :require => false
  gem "simplecov-rcov", :require => false
end

# exception tracker
gem 'whoops_rails_logger', git: 'https://github.com/IntersectAustralia/whoops_rails_logger.git'

gem 'acts_as_singleton'
