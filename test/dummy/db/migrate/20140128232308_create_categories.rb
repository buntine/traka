class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name
      t.string :uuid

      t.timestamps
    end

    create_table :categories_products do |t|
      t.integer :product_id
      t.integer :category_id
    end

  end
end
