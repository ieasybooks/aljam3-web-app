require "swagger_helper"

RSpec.describe "Api::V1::Libraries" do # rubocop:disable RSpec/EmptyExampleGroup
  path "/api/v1/libraries" do
    get "List libraries" do
      tags "Libraries"
      produces "application/json"

      response "200", "libraries found" do
        schema type: :object,
               properties: {
                 libraries: { type: :array, items: { "$ref" => "#/components/schemas/library" } }
               },
               required: %w[libraries]

        run_test!
      end
    end
  end

  path "/api/v1/libraries/{id}" do
    get "Get a library" do
      tags "Libraries"
      produces "application/json"

      parameter name: :id, in: :path, type: :integer, required: true,
                description: "Library ID"

      response "200", "library found" do
        schema "$ref" => "#/components/schemas/library"

        let(:id) { create(:library).id }

        run_test!
      end

      response "404", "library not found" do
        schema "$ref" => "#/components/schemas/not_found"

        let(:id) { 0 }

        run_test!
      end
    end
  end
end
