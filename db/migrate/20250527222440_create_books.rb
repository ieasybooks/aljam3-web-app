class CreateBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :books do |t|
      t.string :title, null: false
      t.string :author, null: false
      t.string :category, null: false
      t.integer :volumes, null: false
      t.integer :pages, null: false
      t.references :library, null: false, foreign_key: true

      t.timestamps
    end
  end
end
