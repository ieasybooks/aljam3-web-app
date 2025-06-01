class CreatePages < ActiveRecord::Migration[8.0]
  def change
    create_table :pages do |t|
      t.text :content, null: false
      t.integer :number, null: false
      t.references :book_file, null: false, foreign_key: true

      t.timestamps
    end
  end
end
