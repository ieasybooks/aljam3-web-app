require "rails_helper"
require_relative "../../script/file_system"

RSpec.describe FileSystem do
  subject(:file_system) { described_class.new }

  describe "#read_csv" do
    it "delegates to CSV.read" do
      allow(CSV).to receive(:read)

      file_system.read_csv("test.csv", headers: true)

      expect(CSV).to have_received(:read).with("test.csv", headers: true)
    end
  end

  describe "#file_exists?" do
    it "delegates to File.exist?" do
      allow(File).to receive(:exist?)

      file_system.file_exists?("test.txt")

      expect(File).to have_received(:exist?).with("test.txt")
    end
  end
end
