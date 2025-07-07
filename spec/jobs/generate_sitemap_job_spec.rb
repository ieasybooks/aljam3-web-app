require "rails_helper"

RSpec.describe GenerateSitemapJob do
  let(:job) { described_class.new }
  let(:sitemap_task) { double }

  before do
    allow(Rake::Task).to receive(:[]).with("sitemap:refresh").and_return(sitemap_task)
    allow(sitemap_task).to receive(:invoke)
    allow(Rake::Task).to receive(:task_defined?).with("sitemap:refresh").and_return(true)
    allow(Rails.application).to receive(:load_tasks)
  end

  describe "#perform" do
    it "calls load_rake_tasks_once and invokes the sitemap:refresh task" do
      allow(job).to receive(:load_rake_tasks_once)

      job.perform

      expect(job).to have_received(:load_rake_tasks_once)
    end

    it "invokes the sitemap:refresh Rake task" do # rubocop:disable RSpec/MultipleExpectations
      job.perform

      expect(Rake::Task).to have_received(:[]).with("sitemap:refresh")
      expect(sitemap_task).to have_received(:invoke)
    end
  end

  describe "#load_rake_tasks_once" do
    context "when sitemap:refresh task is already defined" do
      before do
        allow(Rake::Task).to receive(:task_defined?).with("sitemap:refresh").and_return(true)
      end

      it "returns early without loading tasks" do
        job.send(:load_rake_tasks_once)

        expect(Rails.application).not_to have_received(:load_tasks)
      end
    end

    context "when sitemap:refresh task is not defined" do
      before do
        allow(Rake::Task).to receive(:task_defined?).with("sitemap:refresh").and_return(false)
      end

      it "loads Rails tasks" do
        job.send(:load_rake_tasks_once)

        expect(Rails.application).to have_received(:load_tasks)
      end
    end
  end

  describe "job configuration" do
    it "is queued as sitemap" do
      expect(described_class.queue_name).to eq("sitemap")
    end
  end
end
