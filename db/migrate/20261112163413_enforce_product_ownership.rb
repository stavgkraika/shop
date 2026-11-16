class EnforceProductOwnership < ActiveRecord::Migration[6.1]
  def up
    invalid_products = select_value(<<~SQL).to_i
      SELECT COUNT(*)
      FROM products
      LEFT JOIN users ON users.id = products.user_id
      WHERE users.id IS NULL
    SQL

    if invalid_products.positive?
      raise ActiveRecord::MigrationError,
            "Cannot enforce product ownership: #{invalid_products} " \
            "product(s) have no valid owner. Resolve them before migrating."
    end

    change_column_null :products, :user_id, false
    add_index :products, :user_id
    add_foreign_key :products, :users
  end

  def down
    remove_foreign_key :products, :users
    remove_index :products, :user_id
    change_column_null :products, :user_id, true
  end
end