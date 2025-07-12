class CreateSearchClicks < ActiveRecord::Migration[8.0]
  def change
    create_table :search_clicks do |t|
      t.references :result, polymorphic: true, null: false
      t.references :search_query, null: false, foreign_key: true

      t.timestamps
    end
  end
end
