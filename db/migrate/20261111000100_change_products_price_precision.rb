class ChangeProductsPricePrecision < ActiveRecord::Migration[6.1]
  def up
    change_column :products, :price, :decimal, precision: 10, scale: 2, default: 0
  end

  def down
    change_column :products, :price, :decimal, precision: 5, scale: 2, default: 0
  end
end
