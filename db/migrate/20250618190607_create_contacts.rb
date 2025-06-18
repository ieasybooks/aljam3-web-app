class CreateContacts < ActiveRecord::Migration[8.0]
  def change
    create_table :contacts do |t|
      t.string :name, null: false, limit: 255
      t.string :email, null: false, limit: 255
      t.string :topic, null: false, limit: 255
      t.text :message, null: false

      t.timestamps
    end
  end
end
