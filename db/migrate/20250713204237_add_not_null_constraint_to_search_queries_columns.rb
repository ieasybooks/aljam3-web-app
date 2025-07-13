class AddNotNullConstraintToSearchQueriesColumns < ActiveRecord::Migration[8.0]
  def change
    change_column_null :search_queries, :query, false
    change_column_null :search_queries, :refinements, false
  end
end
