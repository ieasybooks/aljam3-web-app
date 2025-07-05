class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.integer :books_count, null: false, default: 0

      t.timestamps
    end
  end
end
