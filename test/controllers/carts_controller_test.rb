require "test_helper"

class CartsControllerTest < ActionDispatch::IntegrationTest
  test "shows an empty cart" do
    assert_difference("Cart.count", 1) do
      get cart_url
    end

    assert_response :success
    assert_select "p", text: "Your cart is empty."
  end

  test "emptying a cart removes its items and redirects home" do
    product = Product.create!(
      title: "Watch",
      brand: "Fossil",
      model: "FH256",
      price: 12.50
    )
    post cart_items_url, params: { product_id: product.id }

    assert_difference("Cart.count", -1) do
      assert_difference("CartItem.count", -1) do
        delete cart_url
      end
    end

    assert_redirected_to root_url
    assert_equal "Your cart is empty", flash[:notice]
  end
end
