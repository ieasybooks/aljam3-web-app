class CatalogSearch
  Result = Data.define(:records, :matches, :next_page)

  def self.call(scope:, query:, page:, per_page:, filters: {})
    expressions = scope.klass == Category ? [] : [ "(hidden = false OR hidden NOT EXISTS)" ]
    expressions.concat(filters.map { |key, value| "#{key.to_s.delete_suffix('_id')} = #{Integer(value)}" })

    response = scope.klass.ms_index.search(
      query, filter: expressions, page:, hits_per_page: per_page,
      attributes_to_retrieve: [ "id" ], show_matches_position: true, matching_strategy: "all"
    )
    hits = response.fetch("hits")
    # Recheck visibility and filters in SQL: the index can lag behind updates or deletions.
    records = scope.where(id: hits.pluck("id")).index_by { |record| record.id.to_s }
    Result.new(
      records: hits.filter_map { |hit| records[hit.fetch("id").to_s] },
      matches: hits.to_h { |hit| [ hit.fetch("id").to_s, hit.fetch("_matchesPosition", {}) ] },
      next_page: (page + 1 if page < response.fetch("totalPages"))
    )
  end
end
