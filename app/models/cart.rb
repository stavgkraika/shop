class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy

  validates :user_id, uniqueness: true, allow_nil: true

  def add_product(product, quantity = 1)
    quantity = Integer(quantity)
    raise ArgumentError, "quantity must be positive" unless quantity.positive?

    with_lock do
      item = cart_items.find_or_initialize_by(product: product)
      item.quantity += quantity unless item.new_record?
      item.quantity = quantity if item.new_record?
      item.save!
      item
    end
  end

  def decrement_product(product)
    with_lock do
      item = cart_items.find_by(product: product)
      return unless item

      if item.quantity == 1
        item.destroy!
      else
        item.update!(quantity: item.quantity - 1)
      end

      item
    end
  end

  def total_quantity
    cart_items.sum(:quantity)
  end

  def total_price
    cart_items.includes(:product).reduce(BigDecimal("0")) do |total, item|
      total + item.total_price
    end
  end

  alias money_total total_price
end
