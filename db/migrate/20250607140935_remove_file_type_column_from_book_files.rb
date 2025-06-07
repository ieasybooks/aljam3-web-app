class RemoveFileTypeColumnFromBookFiles < ActiveRecord::Migration[8.0]
  def change
    remove_column :book_files, :file_type, null: false
  end
end
