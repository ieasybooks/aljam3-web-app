class ChangeUrlColumnToThreeColumnsInBookFiles < ActiveRecord::Migration[8.0]
  def change
    remove_column :book_files, :url, null: false
    add_column :book_files, :pdf_url, :text, null: true, default: ""
    add_column :book_files, :txt_url, :text, null: true, default: ""
    add_column :book_files, :docx_url, :text, null: true, default: ""
  end
end
