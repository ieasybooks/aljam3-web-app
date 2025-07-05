class RenameAuthorToAuthorNameInBooks < ActiveRecord::Migration[8.0]
  def change
    rename_column :books, :author, :author_name
  end
end
