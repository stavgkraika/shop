require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "product has a price attribute" do
    assert_respond_to Product.new, :price
  end
    test "requires an owner" do
    product = Product.new(
      title: "Watch",
      brand: "Fossil",
      model: "FH256",
      price: 100
    )

    assert_not product.valid?
    assert_includes product.errors[:user], "must exist"
  end

  test "can be deleted" do
    user = User.create!(
      name: "Seller",
      email: "product-seller@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    product = Product.create!(
      title: "Watch",
      brand: "Fossil",
      model: "FH256",
      price: 100,
      user: user
    )

    assert_difference("Product.count", -1) do
      product.destroy!
    end
  end
    test "database rejects a product without a user_id" do
    product = create_owned_product

    assert_raises(ActiveRecord::NotNullViolation) do
      Product.where(id: product.id).update_all(user_id: nil)
    end
  end

  test "database rejects a product with a nonexistent user_id" do
    product = create_owned_product
    nonexistent_user_id = User.maximum(:id).to_i + 1

    assert_raises(ActiveRecord::InvalidForeignKey) do
      Product.where(id: product.id).update_all(user_id: nonexistent_user_id)
    end
  end

    test "rejects a negative price" do
    product = create_owned_product
    product.price = -1

    assert_not product.valid?
    assert_not_empty product.errors[:price]
  end

  test "rejects a non-numeric price" do
    product = create_owned_product
    product.price = "not-a-number"

    assert_not product.valid?
    assert_not_empty product.errors[:price]
  end

  test "accepts a zero price" do
    product = create_owned_product
    product.price = 0

    assert product.valid?
  end

  private

  def create_owned_product
    user = User.create!(
      name: "Seller",
      email: "database-check@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    Product.create!(
      title: "Watch",
      brand: "Fossil",
      model: "FH256",
      price: 100,
      user: user
    )
  end
end
