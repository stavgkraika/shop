class CreateCartsAndCartItems < ActiveRecord::Migration[6.1]
  def change
    create_table :carts do |t|
      t.references :user,
                   null: true,
                   foreign_key: { on_delete: :cascade },
                   index: { unique: true }

      t.timestamps
    end

    create_table :cart_items do |t|
      t.references :cart,
                   null: false,
                   foreign_key: { on_delete: :cascade }
      t.references :product,
                   null: false,
                   foreign_key: { on_delete: :cascade }
      t.integer :quantity, null: false, default: 1

      t.timestamps
    end

    add_index :cart_items, [:cart_id, :product_id], unique: true
    add_check_constraint :cart_items,
                         "quantity > 0",
                         name: "cart_items_quantity_positive"
  end
end
