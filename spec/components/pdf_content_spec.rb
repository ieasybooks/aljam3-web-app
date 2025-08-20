require "rails_helper"

RSpec.describe Components::PdfContent, type: :component do
  let(:book) { create(:book, :with_files) }
  let(:file) { book.files.first }
  let(:page) { file.pages.first }

  before do
    # Mock the file to have a pdf_url
    allow(file).to receive(:pdf_url).and_return("http://example.com/test.pdf")
  end

  subject(:component) { described_class.new(file: file, page: page) }

  describe "rendering" do
    let(:rendered) { render_inline(component) }

    it "renders a turbo frame with correct id" do
      expect(rendered.css("turbo-frame").first[:id]).to eq("pdf-frame-#{page.id}")
    end

    it "renders a card with correct classes" do
      card = rendered.css(".sm\\:max-w-1\\/2").first
      expect(card).to be_present
      expect(card[:class]).to include("flex-1 flex flex-col overflow-hidden")
    end

    it "renders an iframe with correct src" do
      iframe = rendered.css("iframe").first
      expect(iframe).to be_present
      expect(iframe[:src]).to include("/pdfjs")
      expect(iframe[:src]).to include("page=#{page.number}")
    end

    it "includes correct data attributes for PDF viewer" do
      iframe = rendered.css("iframe").first
      expect(iframe["data-pdf-viewer-target"]).to eq("iframe")
      expect(iframe["data-top-controls-target"]).to eq("iframe")
      expect(iframe["data-bottom-controls-target"]).to eq("iframe")
    end
  end
end