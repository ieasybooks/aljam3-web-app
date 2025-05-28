class CreateBookFiles < ActiveRecord::Migration[8.0]
  def change
    create_table :book_files do |t|
      t.integer :file_type, null: false
      t.text :url, null: false
      t.float :size, null: false
      t.references :book, null: false, foreign_key: true

      t.timestamps
    end
  end
end
