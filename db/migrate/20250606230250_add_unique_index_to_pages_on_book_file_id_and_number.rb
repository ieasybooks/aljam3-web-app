class AddUniqueIndexToPagesOnBookFileIdAndNumber < ActiveRecord::Migration[8.0]
  def change
    add_index :pages, [ :book_file_id, :number ], unique: true
  end
end
