# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'development'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  #config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  #config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
end

# Figure out the external URI of the webapp to test the front end against
ocean_env = ENV['GIT_BRANCH'] ||       # Only available on the TeamCity test agents
            ENV['OCEAN_FRONTEND'] ||   # Set OCEAN_FRONTEND in your developer environment if
            "master"                   # you need to run your local tests against
                                       # anything other than master. DO NOT change
                                       # the string "master" in this file to
                                       # something else, as you then will change it
                                       # for everyone.
ocean_env = "master" if ocean_env == "<default>"
ocean_host = "#{ocean_env}-admin.#{BASE_DOMAIN}"      # The naming scheme prevents the use of prod (intentional)
if Rails.env == "development"
  client_host = "http://localhost"
  client_port = 3005
else
  client_host = "http://#{ocean_env}-admin.#{BASE_DOMAIN}"
  client_port = 80
end


# Configure Watir
WatirWebdriverRails.host = client_host
WatirWebdriverRails.port = client_port
WatirWebdriverRails.close_browser_after_finish = true

URL = "#{client_host}:#{client_port}"

def setup_browser(uri)
  if RUBY_PLATFORM =~ /linux/
    @headless = Headless.new
    @headless.start
    b = Watir::Browser.start uri
  else
    b = Watir::Browser.new ENV["browser"] || :chrome
    b.goto uri
  end

  # Make sure that window is maximized to not get viewport errors
  screen_width = b.execute_script("return screen.width;")
  screen_height = b.execute_script("return screen.height;")
  b.driver.manage.window.resize_to(screen_width,screen_height)
  b.driver.manage.window.move_to(0,0)
  b
end


def teardown_browser(browser)
  if RUBY_PLATFORM =~ /linux/
    #@headless.take_screenshot "miffo-#{rand(1000000000)}.jpg"
    browser.close
    @headless.destroy
  else
    browser.close
  end
end
