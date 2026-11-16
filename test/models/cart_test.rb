require "test_helper"

class CartTest < ActiveSupport::TestCase
  setup do
    @cart = Cart.create!
    @product = Product.create!(
      title: "Watch",
      brand: "Fossil",
      model: "FH256",
      price: 12.50
    )
  end

  test "adding a product creates an item and repeated adds increment it" do
    item = @cart.add_product(@product)

    assert_equal 1, item.quantity
    assert_equal item.id, @cart.add_product(@product).id
    assert_equal 2, item.reload.quantity
    assert_equal 1, @cart.cart_items.count
  end

  test "calculates total quantity and money using decimals" do
    assert_instance_of BigDecimal, @cart.total_price
    assert_equal BigDecimal("0"), @cart.total_price

    @cart.add_product(@product, 3)

    assert_equal 3, @cart.total_quantity
    assert_equal BigDecimal("37.50"), @cart.total_price
    assert_equal @cart.total_price, @cart.money_total
  end

  test "decrement removes an item when it reaches zero" do
    @cart.add_product(@product, 2)

    @cart.decrement_product(@product)
    assert_equal 1, @cart.cart_items.find_by!(product: @product).quantity

    assert_difference("CartItem.count", -1) do
      @cart.decrement_product(@product)
    end
  end

  test "cart item quantity must be positive" do
    item = @cart.cart_items.build(product: @product, quantity: 0)

    assert_not item.valid?
    assert_includes item.errors[:quantity], "must be greater than 0"
  end

  test "a product can only appear once in a cart" do
    @cart.cart_items.create!(product: @product)
    duplicate = @cart.cart_items.build(product: @product)

    assert_not duplicate.valid?
  end

  test "deleting a product removes its cart items" do
    @cart.add_product(@product)

    assert_difference("CartItem.count", -1) do
      @product.destroy!
    end
  end
end
