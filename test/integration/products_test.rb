require "test_helper"

class ProductsTest < ActionDispatch::IntegrationTest
  test "homepage responds successfully" do
    get root_path

    assert_response :success
  end 
end
