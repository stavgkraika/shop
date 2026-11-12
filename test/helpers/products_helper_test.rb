require "test_helper"

class ProductsHelperTest < ActionView::TestCase
  test "shows a fallback when the product has no seller" do
    product = Product.new

    assert_equal "Unknown seller", product_author(product)
  end

  test "shows a fallback when the seller has no name" do
    product = Product.new(user: User.new(name: ""))

    assert_equal "Unknown seller", product_author(product)
  end
end