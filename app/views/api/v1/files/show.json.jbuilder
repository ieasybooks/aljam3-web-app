json.partial! "api/v1/files/file", file: @file

if params[:expand]&.include?("pages")
  json.partial! "api/v1/pagination", locals: { pagy: @pagy, url_method: :api_v1_book_file_url }

  json.pages do
    json.array! @pages, partial: "api/v1/pages/page", as: :page
  end
end
