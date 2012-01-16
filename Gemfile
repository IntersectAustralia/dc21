source 'http://rubygems.org'

gem 'rails', '3.1.1'

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

gem 'therubyracer'

gem 'jquery-rails'
gem "haml"
gem "haml-rails"
gem "tabs_on_rails"
gem "devise"
gem "cancan"
gem "capistrano-ext"
gem "capistrano"
gem "capistrano_colors"
gem "colorize"
gem "metrical", :group => :test
gem "simplecov", ">=0.3.8", :require => false, :group => :test
gem "squeel"

group :development, :test do
  gem "rspec-rails"
  gem "factory_girl_rails", :require => false
  gem "shoulda"

  # cucumber gems
  gem "email_spec"
  gem "cucumber"
  gem "cucumber-rails"
  gem "capybara"
  gem "database_cleaner"
  gem 'spork', '~> 0.9.0.rc'
  gem "launchy"    # So you can do Then show me the page
end

group :development do
  gem "rails3-generators"
end
