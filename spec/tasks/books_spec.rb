require "rails_helper"

RSpec.describe "rake db:import_book", type: :task do
  let(:library) { create(:library) }
  let(:valid_argv) { build_argv }

  def build_argv(library_id: nil, txt_paths: nil)
    library_id ||= library.id.to_s
    txt_paths ||= "spec/data/txt_book_file_1.txt;spec/data/txt_book_file_2.txt"

    new_argv = []

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
    new_argv << "--pdf-sizes"
    new_argv << "15.4;10.1"
    new_argv << "--txt-urls"
    new_argv << "https://example.com/file with spaces.txt;https://example.com/another file.txt"
    new_argv << "--txt-sizes"
    new_argv << "0.3;0.1"
    new_argv << "--docx-urls"
    new_argv << "https://example.com/file with spaces.docx;https://example.com/another file.docx"
    new_argv << "--docx-sizes"
    new_argv << "1.3;0.9"
    new_argv << "--txt-paths"
    new_argv << txt_paths

    new_argv
  end

  context "with valid arguments" do
    it "imports the book" do # rubocop:disable RSpec/ExampleLength,RSpec/MultipleExpectations
      original_argv = ARGV.dup
      ARGV.replace(valid_argv)

      expect { task.invoke }.to change(Book, :count).by(1)
                            .and change(BookFile.where(file_type: :pdf), :count).by(2)
                            .and change(BookFile.where(file_type: :txt), :count).by(2)
                            .and change(BookFile.where(file_type: :docx), :count).by(2)
                            .and change(Page, :count).by(5)

      expect(BookFile.pluck(:size)).to eq([ 15.4, 10.1, 0.3, 0.1, 1.3, 0.9 ])
      expect(Page.pluck(:content)).to eq([ "page 1", "page 2", "page 3", "page 1", "page 2" ])
      expect(Page.pluck(:number)).to eq([ 1, 2, 3, 1, 2 ])
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

  context "without arguments" do
    it "shows the help and exits" do # rubocop:disable RSpec/ExampleLength
      original_argv = ARGV.dup
      ARGV.replace([])

      expect { task.invoke }.to raise_error(SystemExit).and output(/Usage: rake db:import_book/).to_stdout
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

  context "with un-equal number of URLs, sizes, and paths" do
    it "shows the error and exits" do # rubocop:disable RSpec/ExampleLength
      original_argv = ARGV.dup
      ARGV.replace(build_argv(txt_paths: "/path/to/file with spaces.txt"))

      expect { task.invoke }.to raise_error(SystemExit)
                            .and output(/Error: The number of URLs, sizes, and paths must be the same for all file types/).to_stdout
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
