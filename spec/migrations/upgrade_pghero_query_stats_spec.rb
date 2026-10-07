require "rails_helper"
require Rails.root.join("db/migrate/20261007154500_upgrade_pghero_query_stats")

RSpec.describe UpgradePgheroQueryStats do
  let(:migration) { described_class.new }
  let(:connection) { ActiveRecord::Base.connection }
  let(:original_stats) { connection.select_all("SELECT * FROM pghero_query_stats ORDER BY id").to_a }

  around do |example|
    ActiveRecord::Migration.suppress_messages { example.run }
  end

  before do
    migration.migrate(:down)
    connection.execute <<~SQL
      INSERT INTO pghero_query_stats (database, "user", query, query_hash, total_time, calls, captured_at)
      VALUES
        ('primary', 'aljam3', 'SELECT 1', 1, 1.5, 2, '2026-10-01 12:00:00'),
        ('primary', 'aljam3', 'SELECT 1', 1, 2.5, 3, '2026-10-01 12:05:00'),
        ('primary', 'aljam3', NULL, 2, 3.5, 4, '2026-10-01 12:10:00')
    SQL
    original_stats
    migration.migrate(:up)
  end

  it "preserves historical stats, including records without query text" do
    migrated_stats = connection.select_all(<<~SQL).to_a
      SELECT stats.id, stats.database, stats.user, queries.query,
        stats.query_hash, stats.total_time, stats.calls, stats.captured_at
      FROM pghero_query_stats stats
      LEFT JOIN pghero_queries queries ON queries.id = stats.query_id
      ORDER BY stats.id
    SQL

    expect(migrated_stats).to eq(original_stats)
  end

  it "stores repeated query text only once" do
    expect(connection.select_values("SELECT query FROM pghero_queries")).to eq([ "SELECT 1" ])
  end

  it "restores query text for existing and newly captured stats on rollback" do
    insert_new_query_stats
    migration.migrate(:down)

    restored_stats = connection.select_all("SELECT * FROM pghero_query_stats ORDER BY id").to_a
    expect(restored_stats).to eq(original_stats + [ original_stats.first.merge("id" => restored_stats.last.fetch("id"), "query" => "SELECT 2") ])
  end

  def insert_new_query_stats
    connection.execute <<~SQL
      INSERT INTO pghero_queries (query) VALUES ('SELECT 2');
      INSERT INTO pghero_query_stats (database, "user", query_id, query_hash, total_time, calls, captured_at)
      SELECT 'primary', 'aljam3', id, 1, 1.5, 2, '2026-10-01 12:00:00'
      FROM pghero_queries WHERE query = 'SELECT 2'
    SQL
  end
end
