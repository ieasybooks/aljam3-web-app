class AddSuspendedAtToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :suspended_at, :datetime, default: nil
  end
end
