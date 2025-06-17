class AddNotNullConstraintForUrlColumnsInBookFiles < ActiveRecord::Migration[8.0]
  def change
    change_column_null :book_files, :pdf_url, false
    change_column_null :book_files, :txt_url, false
    change_column_null :book_files, :docx_url, false
  end
end
