json.categories do
  json.array! @categories do |category|
    json.partial! "api/v1/categories/category", category:
  end
end
