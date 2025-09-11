class AddProviderAndUidToUsers < ActiveRecord::Migration[8.0]
  change_table :users, bulk: true do |t|
    t.string :uid
    t.string :provider
  end
end
