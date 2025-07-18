require "rails_helper"

RSpec.describe ReindexMeilisearchJob do
  describe "#perform" do
    let(:job) { described_class.new }
    let(:model) { "SomeModel" }
    let(:constantized_model) { double }
    let(:records) { double }

    before do
      allow(job).to receive(:sleep)
      allow(model).to receive(:constantize).and_return(constantized_model)
      allow(constantized_model).to receive(:where).and_return(records)
      allow(records).to receive(:reindex!)
    end

    it "constantizes the model string" do
      job.perform(model, 1, 25000)

      expect(model).to have_received(:constantize)
    end

    context "with default step size" do
      it "processes records in chunks of 10000 by default" do # rubocop:disable RSpec/MultipleExpectations
        job.perform(model, 1, 25000)

        # Should process 3 chunks: 1-10000, 10001-20000, 20001-25000
        expect(constantized_model).to have_received(:where).with(id: 1..10000)
        expect(constantized_model).to have_received(:where).with(id: 10001..20000)
        expect(constantized_model).to have_received(:where).with(id: 20001..25000)
      end
    end

    context "with custom step size" do
      it "uses the provided step size" do # rubocop:disable RSpec/MultipleExpectations
        job.perform(model, 1, 15000, 5000)

        # Should process 3 chunks: 1-5000, 5001-10000, 10001-15000
        expect(constantized_model).to have_received(:where).with(id: 1..5000)
        expect(constantized_model).to have_received(:where).with(id: 5001..10000)
        expect(constantized_model).to have_received(:where).with(id: 10001..15000)
      end
    end

    context "when processing chunks" do
      it "calls reindex! for each chunk" do
        job.perform(model, 1, 25000, 10000)

        expect(records).to have_received(:reindex!).exactly(3).times
      end

      it "handles the last chunk correctly when end_id is not divisible by step" do # rubocop:disable RSpec/MultipleExpectations
        job.perform(model, 1, 15500, 10000)

        expect(constantized_model).to have_received(:where).with(id: 1..10000)
        expect(constantized_model).to have_received(:where).with(id: 10001..15500)
      end
    end

    context "with a single chunk" do
      it "processes all records in one chunk when range is smaller than step" do # rubocop:disable RSpec/MultipleExpectations
        job.perform(model, 1, 5000, 10000)

        expect(constantized_model).to have_received(:where).with(id: 1..5000).once
        expect(records).to have_received(:reindex!).once
      end
    end
  end

  describe "job queue" do
    it "is queued on the default queue" do
      expect(described_class.new.queue_name).to eq("default")
    end
  end
end
