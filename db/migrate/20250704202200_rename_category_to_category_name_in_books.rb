class RenameCategoryToCategoryNameInBooks < ActiveRecord::Migration[8.0]
  def change
    rename_column :books, :category, :category_name
  end
end
