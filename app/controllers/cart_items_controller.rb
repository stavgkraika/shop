class CartItemsController < ApplicationController
  before_action :set_cart, only: [:update, :destroy]
  before_action :set_cart_item, only: [:update, :destroy]

  def create
    product = Product.find_by(id: params[:product_id])
    return redirect_to(root_path, alert: "Product not found") unless product

    current_cart.add_product(product)
    redirect_to cart_path, notice: "Added to your cart"
  end

  def update
    @cart.decrement_product(@cart_item.product)
    redirect_to cart_path, notice: "Removed from your cart"
  end

  def destroy
    @cart_item.destroy!
    redirect_to cart_path, notice: "Removed from your cart"
  end

  private

  def current_cart
    cart_from_session || Cart.create!.tap { |cart| session[:cart_id] = cart.id }
  end

  def cart_from_session
    Cart.find_by(id: session[:cart_id]) if session[:cart_id]
  end

  def set_cart
    @cart = cart_from_session
    redirect_to(cart_path, alert: "Cart item not found") unless @cart
  end

  def set_cart_item
    return unless @cart

    @cart_item = @cart.cart_items.find_by(id: params[:id])
    redirect_to(cart_path, alert: "Cart item not found") unless @cart_item
  end
end
