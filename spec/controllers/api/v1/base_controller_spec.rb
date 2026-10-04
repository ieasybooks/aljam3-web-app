require "rails_helper"

RSpec.describe Api::V1::BaseController do
  subject(:formatted) { described_class.new.send(:process_meilisearch_highlights, content) }

  context "when highlighted fragments touch" do
    let(:content) { "<mark>علم</mark><mark>اء</mark>" }

    it "keeps a single uninterrupted highlight" do
      expect(formatted).to eq("<mark>علماء</mark>")
    end
  end

  context "when highlighted words are separated" do
    let(:content) { "<mark>ال</mark>علم <mark>نور</mark> <mark>وهدى</mark>" }

    it "preserves word spacing and leaves a lone definite article unmarked" do
      expect(formatted).to eq("العلم <mark>نور&nbsp;وهدى</mark>")
    end
  end
end
