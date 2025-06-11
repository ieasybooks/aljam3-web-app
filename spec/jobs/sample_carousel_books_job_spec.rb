require "rails_helper"

RSpec.describe SampleCarouselBooksJob do
  subject(:job) { described_class.new }

  describe "#perform" do
    let(:sample_book_ids) { [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ] }
    let(:book_relation) { class_double(Book) }

    before do
      allow(Book).to receive(:order).with("RANDOM()").and_return(book_relation)
      allow(book_relation).to receive(:limit).with(10).and_return(book_relation)
      allow(book_relation).to receive(:pluck).with(:id).and_return(sample_book_ids)
      allow(Rails.cache).to receive(:write)
    end

    it "caches 10 random book IDs" do
      job.perform

      expect(Rails.cache).to have_received(:write).with("carousel_books_ids", sample_book_ids)
    end

    it "queries books with random ordering" do
      job.perform

      expect(Book).to have_received(:order).with("RANDOM()")
    end

    it "limits the query to 10 books" do
      job.perform

      expect(book_relation).to have_received(:limit).with(10)
    end

    it "plucks only the ID column" do
      job.perform

      expect(book_relation).to have_received(:pluck).with(:id)
    end

    context "when no books exist" do
      let(:sample_book_ids) { [] }

      it "caches an empty array" do
        job.perform

        expect(Rails.cache).to have_received(:write).with("carousel_books_ids", [])
      end
    end

    context "when fewer than 10 books exist" do
      let(:sample_book_ids) { [ 1, 2, 3 ] }

      it "caches the available book IDs" do
        job.perform

        expect(Rails.cache).to have_received(:write).with("carousel_books_ids", [ 1, 2, 3 ])
      end
    end
  end

  describe "job configuration" do
    it "uses the default queue" do
      expect(described_class.queue_name).to eq("default")
    end
  end
end
