require "test_helper"
require "selenium-webdriver"

Capybara.register_driver :remote_chrome do |app|
  Capybara::Selenium::Driver.new(
    app,
    browser: :remote,
    url: ENV.fetch("SELENIUM_REMOTE_URL"),
    options: Selenium::WebDriver::Chrome::Options.new
  )
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :remote_chrome

  setup do
    Capybara.server_host = "0.0.0.0"
    Capybara.server_port = 3000
    Capybara.app_host = "http://test:3000"
  end
end