require "test_helper"

class ProductsTest < ActionDispatch::IntegrationTest
  test "homepage responds successfully" do
    get root_path

    assert_response :success
  end 
    test "a different user cannot update a product" do
    owner = User.create!(
      name: "Owner",
      email: "owner@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    other_user = User.create!(
      name: "Other User",
      email: "other@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    product = Product.create!(
      title: "Original title",
      brand: "Fossil",
      model: "FH256",
      price: 100,
      user: owner
    )

    post user_session_path, params: {
      user: { email: other_user.email, password: "password123" }
    }

    # Verify that the second user signed in successfully.
    get edit_user_registration_path
    assert_response :success

    patch product_path(product), params: {
      product: { title: "Changed by another user" }
    }

    assert_equal "Original title", product.reload.title
  end
  test "a different user cannot edit or delete a product" do
    owner = User.create!(
      name: "Owner",
      email: "owner-edit@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    other_user = User.create!(
      name: "Other User",
      email: "other-edit@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    product = Product.create!(
      title: "Owner's product",
      brand: "Fossil",
      model: "FH256",
      price: 100,
      user: owner
    )

    post user_session_path, params: {
      user: { email: other_user.email, password: "password123" }
    }

    get edit_user_registration_path
    assert_response :success

    get edit_product_path(product)
    assert_redirected_to root_path
    assert_equal "You can only manage your own products.", flash[:alert]

    assert_no_difference("Product.count") do
      delete product_path(product)
    end

    assert_redirected_to root_path
    assert Product.exists?(product.id)
  end

  test "a guest cannot edit, update or delete a product" do
    owner = User.create!(
      name: "Owner",
      email: "owner-guest@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    product = Product.create!(
      title: "Original title",
      brand: "Fossil",
      model: "FH256",
      price: 100,
      user: owner
    )

    get edit_product_path(product)
    assert_redirected_to new_user_session_path

    patch product_path(product), params: {
      product: { title: "Changed by guest" }
    }
    assert_redirected_to new_user_session_path
    assert_equal "Original title", product.reload.title

    assert_no_difference("Product.count") do
      delete product_path(product)
    end
    assert_redirected_to new_user_session_path
    assert Product.exists?(product.id)
  end

    test "the owner can delete a product" do
    owner = User.create!(
      name: "Owner",
      email: "owner-delete@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    product = Product.create!(
      title: "Owner's product",
      brand: "Fossil",
      model: "FH256",
      price: 100,
      user: owner
    )

    post user_session_path, params: {
      user: { email: owner.email, password: "password123" }
    }

    get edit_user_registration_path
    assert_response :success

    assert_difference("Product.count", -1) do
      delete product_path(product)
    end

    assert_redirected_to root_path
    assert_not Product.exists?(product.id)
  end
  test "the owner can edit and update a product" do
    owner = User.create!(
      name: "Owner",
      email: "owner-update@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    product = Product.create!(
      title: "Original title",
      brand: "Fossil",
      model: "FH256",
      price: 100,
      user: owner
    )

    post user_session_path, params: {
      user: { email: owner.email, password: "password123" }
    }

    get edit_user_registration_path
    assert_response :success

    get edit_product_path(product)
    assert_response :success

    patch product_path(product), params: {
      product: { title: "Updated title" }
    }

    assert_redirected_to product_path(product)
    assert_equal "Updated title", product.reload.title
  end

    test "only the owner sees edit and delete links" do
    owner = User.create!(
      name: "Owner",
      email: "owner-links@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    other_user = User.create!(
      name: "Other User",
      email: "other-links@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    product = Product.create!(
      title: "Owner's product",
      brand: "Fossil",
      model: "FH256",
      price: 100,
      user: owner
    )

    # Guest
    get root_path
    assert_response :success
    assert_select "a[href=?]", edit_product_path(product), count: 0
    assert_select "a[data-method='delete'][href=?]", product_path(product), count: 0

    # A different signed-in user
    post user_session_path, params: {
      user: { email: other_user.email, password: "password123" }
    }

    get edit_user_registration_path
    assert_response :success

    get root_path
    assert_select "a[href=?]", edit_product_path(product), count: 0
    assert_select "a[data-method='delete'][href=?]", product_path(product), count: 0

    delete destroy_user_session_path

    # Owner
    post user_session_path, params: {
      user: { email: owner.email, password: "password123" }
    }

    get edit_user_registration_path
    assert_response :success

    get root_path
    assert_select "a[href=?]", edit_product_path(product), count: 1
    assert_select "a[data-method='delete'][href=?]", product_path(product), count: 1
  end

    test "a guest can view the homepage and product details" do
    owner = User.create!(
      name: "Owner",
      email: "owner-public@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    product = Product.create!(
      title: "Public product",
      brand: "Fossil",
      model: "FH256",
      price: 100,
      user: owner
    )

    get root_path
    assert_response :success
    assert_select "a[href=?]", product_path(product), text: "Public product"

    get product_path(product)
    assert_response :success
    assert_select "h1", text: "Public product"
  end
end
