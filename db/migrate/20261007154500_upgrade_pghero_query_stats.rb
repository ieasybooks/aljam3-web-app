class UpgradePgheroQueryStats < ActiveRecord::Migration[8.1]
  def up
    create_table :pghero_queries do |t|
      t.text :query
    end

    add_index :pghero_queries, :query, using: :hash
    add_reference :pghero_query_stats, :query, index: false

    execute <<~SQL
      INSERT INTO pghero_queries (query)
        SELECT DISTINCT query FROM pghero_query_stats WHERE query IS NOT NULL
    SQL

    execute <<~SQL
      UPDATE pghero_query_stats SET query_id = pghero_queries.id
        FROM pghero_queries WHERE pghero_queries.query = pghero_query_stats.query
    SQL

    remove_column :pghero_query_stats, :query
  end

  def down
    add_column :pghero_query_stats, :query, :text

    execute <<~SQL
      UPDATE pghero_query_stats SET query = pghero_queries.query
        FROM pghero_queries WHERE pghero_queries.id = pghero_query_stats.query_id
    SQL

    remove_reference :pghero_query_stats, :query, index: false
    drop_table :pghero_queries
  end
end
