json.partial! "api/v1/pagination", locals: { pagy: @pagy }

json.authors do
  json.array! @authors do |author|
    json.partial! "api/v1/authors/author", author:
  end
end
