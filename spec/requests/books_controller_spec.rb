require 'swagger_helper'

RSpec.describe BooksController do # rubocop:disable RSpec/EmptyExampleGroup
  path '/books.json' do
    get 'get books' do
      tags 'Books'
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false,
                description: 'Page number to be returned'

      response '200', 'books found' do
        schema type: :object,
               properties: {
                 pagination: { '$ref' => '#/components/schemas/pagination' },
                 books: { type: :array, items: { '$ref' => '#/components/schemas/book' } }
               },
               required: %w[pagination books]

        let(:page) { 1 }

        run_test!
      end
    end
  end
end
