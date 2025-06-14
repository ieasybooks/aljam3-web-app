require "rails_helper"

RSpec.describe ReindexMeilisearchJob do
  describe "#perform" do
    let(:model) { "SomeModel" }
    let(:constantized_model) { double("ConstantizedModel") } # rubocop:disable RSpec/VerifiedDoubles
    let(:records) { double("Records") } # rubocop:disable RSpec/VerifiedDoubles
    let(:start_id) { 1 }
    let(:end_id) { 10 }

    before do
      allow(model).to receive(:constantize).and_return(constantized_model)
      allow(constantized_model).to receive(:where).and_return(records)
      allow(records).to receive(:reindex!)
    end

    it "constantizes the model string" do
      described_class.new.perform(model, start_id, end_id)

      expect(model).to have_received(:constantize)
    end

    it "filters the constantized model by the ID range" do
      described_class.new.perform(model, start_id, end_id)

      expect(constantized_model).to have_received(:where).with(id: start_id..end_id)
    end

    it "calls reindex! on the filtered records" do
      described_class.new.perform(model, start_id, end_id)

      expect(records).to have_received(:reindex!)
    end

    it "chains the constantize, where and reindex! calls correctly" do # rubocop:disable RSpec/MultipleExpectations
      described_class.new.perform(model, start_id, end_id)

      expect(model).to have_received(:constantize).ordered
      expect(constantized_model).to have_received(:where).with(id: start_id..end_id).ordered
      expect(records).to have_received(:reindex!).ordered
    end
  end

  describe "job queue" do
    it "is queued on the default queue" do
      expect(described_class.new.queue_name).to eq("default")
    end
  end
end
