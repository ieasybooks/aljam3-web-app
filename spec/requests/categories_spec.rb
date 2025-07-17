require "rails_helper"

RSpec.describe "Categories" do
  let(:category) { create(:category) }

  describe "GET /categories" do
    it "returns http success" do
      get categories_path

      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /categories/:id" do
    context "without pagination (page 1)" do
      it "returns http success" do
        get category_path(category.id)

        expect(response).to have_http_status(:success)
      end

      it "renders the full view for page 1" do
        get category_path(category.id)

        expect(response.content_type).to eq("text/html; charset=utf-8")
      end
    end

    context "with pagination (page > 1)" do
      before do
        create_list(:book, 25, category: category)
      end

      it "returns turbo_stream response for page 2" do
        get category_path(category.id), params: { page: "2" }, as: :turbo_stream

        expect(response.content_type).to eq("text/vnd.turbo-stream.html; charset=utf-8")
      end

      it "replaces the correct pagination element for page 2" do
        get category_path(category.id), params: { page: "2" }, as: :turbo_stream

        expect(response.body).to include('turbo-stream action="replace" target="results_list_2"')
      end
    end
  end
end
