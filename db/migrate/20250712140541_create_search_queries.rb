class CreateSearchQueries < ActiveRecord::Migration[8.0]
  def change
    create_table :search_queries do |t|
      t.string :query
      t.jsonb :refinements
      t.references :user, null: true, foreign_key: true

      t.timestamps
    end
  end
end
