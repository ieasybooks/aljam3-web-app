class ChangeSizeColumnToThreeColumnsInBookFiles < ActiveRecord::Migration[8.0]
  def change
    remove_column :book_files, :size, null: false
    add_column :book_files, :pdf_size, :float, null: false, default: 0
    add_column :book_files, :txt_size, :float, null: false, default: 0
    add_column :book_files, :docx_size, :float, null: false, default: 0
  end
end
