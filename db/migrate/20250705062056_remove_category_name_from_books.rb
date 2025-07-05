class RemoveCategoryNameFromBooks < ActiveRecord::Migration[8.0]
  def change
    remove_column :books, :category_name, :string, null: false
  end
end
