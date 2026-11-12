require "test_helper"
require "tmpdir"

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
    test "shows the seller name on the homepage and product page" do
    seller = User.create!(
      name: "Alice Seller",
      email: "alice-seller@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    product = Product.create!(
      title: "Seller's watch",
      brand: "Fossil",
      model: "FH256",
      price: 100,
      user: seller
    )

    get root_path
    assert_response :success
    assert_select ".product", text: /Sold by:\s*Alice Seller/

    get product_path(product)
    assert_response :success
    assert_select "p", text: /Sold by\s+Alice Seller/
  end

    test "a signed-in user can create a product" do
    seller = User.create!(
      name: "Seller",
      email: "seller-create@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    post user_session_path, params: {
      user: { email: seller.email, password: "password123" }
    }

    get edit_user_registration_path
    assert_response :success

    assert_difference("Product.count", 1) do
      post products_path, params: {
        product: {
          title: "Watch for sale",
          brand: "Fossil",
          model: "FH256",
          description: "A watch in good condition.",
          condition: "Used",
          finish: "Black",
          price: "100.00"
        }
      }
    end

    product = Product.find_by!(title: "Watch for sale")

    assert_equal seller.id, product.user_id
    assert_equal 100, product.price
    assert_redirected_to product_path(product)
  end
    test "a signed-in user cannot create a product with invalid data" do
    seller = User.create!(
      name: "Seller",
      email: "invalid-product@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    post user_session_path, params: {
      user: { email: seller.email, password: "password123" }
    }

    get edit_user_registration_path
    assert_response :success

    assert_no_difference("Product.count") do
      post products_path, params: {
        product: {
          title: "",
          brand: "Fossil",
          model: "FH256",
          price: "-10"
        }
      }
    end

    assert_response :unprocessable_entity
  end
    test "a signed-in user can create a product with an image" do
    seller = User.create!(
      name: "Seller",
      email: "image-upload@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    post user_session_path, params: {
      user: { email: seller.email, password: "password123" }
    }

    get edit_user_registration_path
    assert_response :success

    Dir.mktmpdir("shop-upload-test") do |directory|
      original_root = ImageUploader.root
      ImageUploader.root = directory

      begin
        image = fixture_file_upload(
          Rails.root.join("app/assets/images/fossil.jpg"),
          "image/jpeg"
        )

        assert_difference("Product.count", 1) do
          post products_path, params: {
            product: {
              title: "Watch with image",
              brand: "Fossil",
              model: "FH256",
              price: "100",
              image: image
            }
          }
        end

        product = Product.find_by!(title: "Watch with image")

        assert_equal seller.id, product.user_id
        assert_equal "fossil.jpg", product.image.identifier
        assert File.file?(product.image.path)
        assert_redirected_to product_path(product)
      ensure
        ImageUploader.root = original_root
      end
    end
  end
    test "the price field has no short character limit" do
    seller = User.create!(
      name: "Seller",
      email: "price-field@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    post user_session_path, params: {
      user: { email: seller.email, password: "password123" }
    }

    get new_product_path
    assert_response :success

    assert_select "input[name='product[price]'][maxlength]", count: 0
  end
end
