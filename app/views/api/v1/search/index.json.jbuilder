json.partial! "api/v1/pagination", locals: { pagy: @pagy, url_method: :api_v1_search_url }

json.pages do
  json.array! @pages, partial: "api/v1/search/result", as: :page
end
