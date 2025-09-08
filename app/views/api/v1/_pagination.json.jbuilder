# locals: (json:, pagy:, url_method:)

json.pagination do
  json.from pagy.from
  json.to pagy.to
  json.count pagy.count
  json.current_page pagy.page
  json.total_pages pagy.last
  json.limit pagy.limit
  json.next_page pagy.next
  json.next_page_link pagy.next ? send(url_method, **request.query_parameters.merge(page: pagy.next)) : nil
  json.previous_page pagy.prev
  json.previous_page_link pagy.prev ? send(url_method, **request.query_parameters.merge(page: pagy.prev)) : nil
end
