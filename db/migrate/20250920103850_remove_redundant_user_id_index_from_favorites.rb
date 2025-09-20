class RemoveRedundantUserIdIndexFromFavorites < ActiveRecord::Migration[8.0]
  def change
    remove_index :favorites, :user_id
  end
end
