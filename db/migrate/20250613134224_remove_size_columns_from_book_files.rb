class RemoveSizeColumnsFromBookFiles < ActiveRecord::Migration[8.0]
  def change
    remove_column :book_files, :pdf_size, :float, null: false
    remove_column :book_files, :txt_size, :float, null: false
    remove_column :book_files, :docx_size, :float, null: false
  end
end
