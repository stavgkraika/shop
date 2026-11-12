require "application_system_test_case"

class HomepageTest < ApplicationSystemTestCase
  test "shows the products heading" do
    visit root_path

    assert_text "Browse new products"
  end
end
