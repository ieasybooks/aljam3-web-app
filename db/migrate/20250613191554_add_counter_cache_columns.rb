class AddCounterCacheColumns < ActiveRecord::Migration[8.0]
  def change
    add_column :libraries, :books_count, :integer, default: 0, null: false
    add_column :books, :files_count, :integer, default: 0, null: false
    add_column :book_files, :pages_count, :integer, default: 0, null: false
  end
end
