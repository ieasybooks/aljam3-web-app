class AddIndexToSearchClick < ActiveRecord::Migration[8.0]
  def change
    add_column :search_clicks, :index, :integer, null: false, default: -1
  end
end
