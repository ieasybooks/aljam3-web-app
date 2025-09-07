# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join("swagger").to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "Aljam3 API",
        version: "v1"
      },
      paths: {},
      servers: [
        { url: "http://localhost:3000" },
        { url: "https://aljam3.com" }
      ],
      components: {
        schemas: {
          pagination: {
            type: :object,
            properties: {
              from: { type: :integer, description: "First record on the page" },
              to: { type: :integer, description: "Last record on the page" },
              count: { type: :integer, description: "Total number of records" },
              current_page: { type: :integer, description: "Current page number" },
              total_pages: { type: :integer, description: "Total number of pages" },
              limit: { type: :integer, description: "Limit the number of books to return" },
              next_page: { type: :integer, description: "Next page number, null if no next page", nullable: true },
              next_page_link: { type: :string, description: "API link to the next page, null if no next page", nullable: true },
              previous_page: { type: :integer, description: "Previous page number, null if no previous page", nullable: true },
              previous_page_link: { type: :string, description: "API link to the previous page, null if no previous page", nullable: true }
            },
            required: %w[from to count current_page total_pages limit next_page next_page_link previous_page previous_page_link]
          },
          book: {
            type: :object,
            properties: {
              id: { type: :integer, description: "Book ID" },
              title: { type: :string, description: "Book title" },
              author: {
                type: :object,
                properties: {
                  id: { type: :integer, description: "Author ID" },
                  name: { type: :string, description: "Author name" },
                  link: { type: :string, description: "API link to the author" }
                },
                required: %w[id name link]
              },
              category: {
                type: :object,
                properties: {
                  id: { type: :integer, description: "Category ID" },
                  name: { type: :string, description: "Category name" },
                  link: { type: :string, description: "API link to the category" }
                },
                required: %w[id name link]
              },
              library: {
                type: :object,
                properties: {
                  id: { type: :integer, description: "Library ID" },
                  name: { type: :string, description: "Library name" }
                },
                required: %w[id name]
              },
              pages_count: { type: :integer, description: "Number of pages" },
              files_count: { type: :integer, description: "Number of files, -1 if not available" },
              views_count: { type: :integer, description: "Number of views" },
              volumes: { type: :integer, description: "Number of volumes" },
              link: { type: :string, description: "API link to the book" }
            },
            required: %w[id title author category library pages_count files_count views_count volumes link]
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
