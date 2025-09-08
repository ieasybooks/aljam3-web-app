json.categories do
  json.array! @categories, partial: "api/v1/categories/category", as: :category
end
