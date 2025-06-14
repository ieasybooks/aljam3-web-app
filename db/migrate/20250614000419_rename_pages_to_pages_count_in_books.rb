class RenamePagesToPagesCountInBooks < ActiveRecord::Migration[8.0]
  def change
    rename_column :books, :pages, :pages_count
  end
end
