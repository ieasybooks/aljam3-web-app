json.libraries do
  json.array! @libraries, partial: "api/v1/libraries/library", as: :library
end
