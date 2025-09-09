json.pages do
  json.array! @pages, partial: "api/v1/pages/page", as: :page
end
