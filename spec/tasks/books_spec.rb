require "rails_helper"

RSpec.describe "rake db:import_book", type: :task do
  let(:library) { create(:library) }
  let(:valid_argv) { build_argv }

  def build_argv(library_id: nil, txt_urls: nil)
    library_id ||= library.id.to_s
    txt_urls ||= "https://example.com/file with spaces.txt;https://example.com/another file.txt"

    new_argv = []

    new_argv << "db:import_book"
    new_argv << "--"
    new_argv << "--title"
    new_argv << "صحيح البخاري"
    new_argv << "--author"
    new_argv << "محمد بن اسماعيل البخاري"
    new_argv << "--category"
    new_argv << "الحديث"
    new_argv << "--pages"
    new_argv << "180"
    new_argv << "--volumes"
    new_argv << "1"
    new_argv << "--library-id"
    new_argv << library_id
    new_argv << "--pdf-urls"
    new_argv << "https://example.com/file with spaces.pdf;https://example.com/another file.pdf"
    new_argv << "--txt-urls"
    new_argv << txt_urls
    new_argv << "--docx-urls"
    new_argv << "https://example.com/file with spaces.docx;https://example.com/another file.docx"

    new_argv
  end

  context "with valid arguments" do
    it "imports the book" do # rubocop:disable RSpec/ExampleLength,RSpec/MultipleExpectations
      original_argv = ARGV.dup
      ARGV.replace(valid_argv)

      allow(URI).to receive(:open).and_yield(StringIO.new("First page.\nPAGE_SEPARATOR\nSecond page."))

      expect { task.invoke }.to change(Book, :count).by(1)
                            .and change(BookFile, :count).by(2)
                            .and change(Page, :count).by(2)

      expect(Page.pluck(:content)).to eq([ "First page.", "Second page." ])
      expect(Page.pluck(:number)).to eq([ 1, 2 ])
    ensure
      ARGV.replace(original_argv)
    end
  end

  context "with --help" do
    it "shows the help and exits" do # rubocop:disable RSpec/ExampleLength
      original_argv = ARGV.dup
      ARGV.replace([ "--help" ])

      expect { task.invoke }.to raise_error(SystemExit).and output(/Usage: rake db:import_book/).to_stdout
    ensure
      ARGV.replace(original_argv)
    end
  end

  context "with missing arguments" do
    it "shows the error and exits" do # rubocop:disable RSpec/ExampleLength
      original_argv = ARGV.dup
      ARGV.replace(valid_argv[0..-3])

      expect { task.invoke }.to raise_error(SystemExit).and output(/Error: Missing required arguments: docx_urls/).to_stdout
    ensure
      ARGV.replace(original_argv)
    end
  end

  context "with non-existing library" do
    it "shows the error and exits" do # rubocop:disable RSpec/ExampleLength
      original_argv = ARGV.dup
      ARGV.replace(build_argv(library_id: "999999"))

      expect { task.invoke }.to raise_error(SystemExit).and output(/Error: Library with ID '999999' not found/).to_stdout
    ensure
      ARGV.replace(original_argv)
    end
  end

  context "with un-equal number of URLs" do
    it "shows the error and exits" do # rubocop:disable RSpec/ExampleLength
      original_argv = ARGV.dup
      ARGV.replace(build_argv(txt_urls: "https://example.com/file with spaces.txt"))

      expect { task.invoke }.to raise_error(SystemExit)
                            .and output(/Error: The number of URLs must be the same for all file types/).to_stdout
    ensure
      ARGV.replace(original_argv)
    end
  end

  context "when OptionParser raises an error" do
    it "shows the error and exits" do
      allow_any_instance_of(OptionParser).to receive(:parse!).and_raise(OptionParser::InvalidOption) # rubocop:disable RSpec/AnyInstance

      expect { task.invoke }.to raise_error(SystemExit).and output(/Error:/).to_stdout
    end
  end

  context "when URI.open raises an error" do
    it "shows the error and exits" do # rubocop:disable RSpec/ExampleLength
      original_argv = ARGV.dup
      ARGV.replace(valid_argv)

      allow(URI).to receive(:open).and_raise(URI::InvalidURIError)

      expect { task.invoke }.to raise_error(SystemExit).and output(/An error occurred while downloading or processing TXT file from/).to_stdout
    ensure
      ARGV.replace(original_argv)
    end
  end

  context "when Book.create! raises an error" do
    it "shows the error and exits" do # rubocop:disable RSpec/ExampleLength,RSpec/NoExpectationExample
      original_argv = ARGV.dup
      ARGV.replace(valid_argv)

      allow_any_instance_of(Book).to receive(:save!).and_raise(ActiveRecord::RecordInvalid) # rubocop:disable RSpec/AnyInstance

      expect { task.invoke }.to raise_error(SystemExit).and output(/An error occurred while creating the book/).to_stdout
    ensure
      ARGV.replace(original_argv)
    end
  end

  context "when BookFile.create! raises an error" do
    it "shows the error and exits" do # rubocop:disable RSpec/ExampleLength,RSpec/MultipleExpectations
      original_argv = ARGV.dup
      ARGV.replace(valid_argv)

      allow_any_instance_of(Book).to receive_message_chain(:files, :create!).and_raise(ActiveRecord::RecordInvalid) # rubocop:disable RSpec/AnyInstance,RSpec/MessageChain

      expect { task.invoke }.to raise_error(SystemExit).and output { |output|
        expect(output.scan(/An error occurred while creating BookFile for/).length).to eq(6)
      }.to_stdout
    ensure
      ARGV.replace(original_argv)
    end
  end
end
