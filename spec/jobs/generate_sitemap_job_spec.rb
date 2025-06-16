require "rails_helper"

RSpec.describe GenerateSitemapJob do
  let(:job) { described_class.new }

  before do
    allow(SitemapGenerator::Interpreter).to receive(:run)
  end

  describe "#perform" do
    it "calls SitemapGenerator::Interpreter.run with verbose: false" do
      job.perform

      expect(SitemapGenerator::Interpreter).to have_received(:run).with(verbose: false)
    end
  end

  describe "job configuration" do
    it "is queued as sitemap" do
      expect(described_class.queue_name).to eq("sitemap")
    end
  end
end
