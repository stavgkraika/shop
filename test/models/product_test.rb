require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "product has a price attribute" do
    assert_respond_to Product.new, :price
  end
end
