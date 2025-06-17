class RemoveBookFileIdIndexFromPages < ActiveRecord::Migration[8.0]
  def change
    remove_index :pages, :book_file_id
  end
end
