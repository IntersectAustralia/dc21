require 'rubygems'
require 'spork'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  require 'simplecov'
  SimpleCov.start 'rails'
  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false
  end
  class Warden::SessionSerializer
    def serialize(record)
      record
    end

    def deserialize(keys)
      keys
    end
  end

  RSpec::Matchers.define(:be_same_file_as) do |exected_file_path|
    match do |actual_file_path|
      md5_hash(actual_file_path).should == md5_hash(exected_file_path)
    end

    def md5_hash(file_path)
      Digest::MD5.hexdigest(File.read(file_path))
    end
  end

  # e.g. path_to_foo.should be_same_file_as(path_to_bar)


end

Spork.each_run do
  # This code will be run each time you run your specs.
  require 'factory_girl_rails'
end

