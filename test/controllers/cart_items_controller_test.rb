require "test_helper"

class CartItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = Product.create!(
      title: "Watch",
      brand: "Fossil",
      model: "FH256",
      price: 12.50
    )
  end

  test "adds a product to the cart" do
    assert_difference(["Cart.count", "CartItem.count"], 1) do
      post cart_items_url, params: { product_id: @product.id }
    end

    assert_redirected_to cart_url
    assert_equal "Added to your cart", flash[:notice]
  end

  test "repeated add increments the existing item" do
    post cart_items_url, params: { product_id: @product.id }

    assert_no_difference("CartItem.count") do
      post cart_items_url, params: { product_id: @product.id }
    end

    assert_equal 2, CartItem.find_by!(product: @product).quantity
  end

  test "decrements an item" do
    post cart_items_url, params: { product_id: @product.id }
    item = CartItem.find_by!(product: @product)
    item.update!(quantity: 2)

    patch cart_item_url(item)

    assert_equal 1, item.reload.quantity
    assert_redirected_to cart_url
    assert_equal "Removed from your cart", flash[:notice]
  end

  test "decrementing the final unit removes the item" do
    post cart_items_url, params: { product_id: @product.id }
    item = CartItem.find_by!(product: @product)

    assert_difference("CartItem.count", -1) do
      patch cart_item_url(item)
    end
  end

  test "removes an item immediately" do
    post cart_items_url, params: { product_id: @product.id }
    item = CartItem.find_by!(product: @product)

    assert_difference("CartItem.count", -1) do
      delete cart_item_url(item)
    end

    assert_equal "Removed from your cart", flash[:notice]
  end

  test "rejects an invalid product id without creating a cart" do
    assert_no_difference(["Cart.count", "CartItem.count"]) do
      post cart_items_url, params: { product_id: -1 }
    end

    assert_redirected_to root_url
    assert_equal "Product not found", flash[:alert]
  end
end
