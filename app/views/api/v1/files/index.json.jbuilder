json.files do
  json.array! @files, partial: "api/v1/files/file", as: :file
end
