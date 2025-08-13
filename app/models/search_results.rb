class SearchResults < Literal::Data
  prop :pagy, Pagy
  prop :results, _Union(_Array(Page), _Array(Book), _Array(Author))
end
