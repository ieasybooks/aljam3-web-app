class AddHiddenToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :hidden, :boolean, null: false, default: false
  end
end
