class CartsController < ApplicationController
  def show
    @cart = current_cart
  end

  def destroy
    cart = cart_from_session
    cart&.destroy!
    session.delete(:cart_id)

    redirect_to root_path, notice: "Your cart is empty"
  end

  private

  def current_cart
    cart_from_session || create_cart
  end

  def cart_from_session
    return unless session[:cart_id]

    Cart.find_by(id: session[:cart_id])
  end

  def create_cart
    Cart.create!.tap { |cart| session[:cart_id] = cart.id }
  end
end
