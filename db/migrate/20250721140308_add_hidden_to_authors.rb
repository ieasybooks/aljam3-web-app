class AddHiddenToAuthors < ActiveRecord::Migration[8.0]
  def change
    add_column :authors, :hidden, :boolean, null: false, default: false
  end
end
