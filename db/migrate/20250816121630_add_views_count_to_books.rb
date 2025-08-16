class AddViewsCountToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :views_count, :integer, default: 0, null: false
    add_index :books, :views_count

    execute <<~SQL
      UPDATE books
      SET views_count = COALESCE(click_counts.count, 0)
      FROM (
        SELECT result_id, COUNT(*) as count
        FROM search_clicks
        WHERE result_type = 'Book'
        GROUP BY result_id
      ) AS click_counts
      WHERE books.id = click_counts.result_id;
    SQL
  end
end
