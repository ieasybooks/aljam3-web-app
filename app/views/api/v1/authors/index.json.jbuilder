json.partial! "api/v1/pagination", locals: { pagy: @pagy, url_method: :api_v1_authors_url }

json.authors do
  json.array! @authors, partial: "api/v1/authors/author", as: :author
end
