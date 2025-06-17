# frozen_string_literal: true

require_relative "../../script/books_importer"

RSpec.describe BooksImporter do
  let(:file_system) { instance_double(FileSystem) }
  let(:ssh_client) { instance_double(SshClient) }
  let(:output) { StringIO.new }
  let(:argv) { [] }
  let(:importer) { described_class.new(file_system: file_system, ssh_client: ssh_client, output: output, argv: argv) }

  describe "#run" do
    context "when --help is present" do
      let(:argv) { [ "--help" ] }

      it "displays help and exits" do # rubocop:disable RSpec/MultipleExpectations
        expect { importer.run }.to raise_error(SystemExit)

        expect(output.string).to include("Usage: ruby lib/tools/import_books.rb [options]")
        expect(output.string).to include("Examples:")
      end
    end

    context "when -h is present" do
      let(:argv) { [ "-h" ] }

      it "displays help and exits" do # rubocop:disable RSpec/MultipleExpectations
        expect { importer.run }.to raise_error(SystemExit)

        expect(output.string).to include("Usage: ruby lib/tools/import_books.rb [options]")
        expect(output.string).to include("Examples:")
      end
    end

    context "when required arguments are missing" do
      let(:argv) { [ "--index-path=/path/to/index.tsv" ] }

      it "displays error and exits" do # rubocop:disable RSpec/MultipleExpectations
        expect { importer.run }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end

        expect(output.string).to include("Error: Missing required arguments")
        expect(output.string).to include("huggingface_library_id")
      end
    end

    context "when index file does not exist" do
      let(:argv) do
        [
          "--index-path=/nonexistent/path.tsv",
          "--huggingface-library-id=test/library",
          "--aljam3-library-id=1",
          "--server-ip=127.0.0.1",
          "--server-username=root"
        ]
      end

      before do
        allow(file_system).to receive(:file_exists?).with("/nonexistent/path.tsv").and_return(false)
      end

      it "raises ValidationError" do
        expect { importer.run }.to raise_error(BooksImporter::ValidationError, /Index file does not exist/)
      end
    end

    context "with Unix-style index path" do
      let(:argv) {
        [
          "--index-path=~/test.tsv",
          "--huggingface-library-id=test/library",
          "--aljam3-library-id=1",
          "--server-ip=127.0.0.1",
          "--server-username=root"
        ]
      }

      it "expands the index path correctly" do # rubocop:disable RSpec/MultipleExpectations
        allow(file_system).to receive_messages(file_exists?: true, read_csv: [])

        importer.run

        expanded_path = File.expand_path("~/test.tsv")

        expect(file_system).to have_received(:file_exists?).with(expanded_path)
        expect(file_system).to have_received(:read_csv).with(expanded_path, col_sep: "\t", headers: true)
      end
    end

    context "with valid arguments" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:index_path) { "/path/to/index.tsv" }

      let(:argv) do
        [
          "--index-path=#{index_path}",
          "--huggingface-library-id=test/library",
          "--aljam3-library-id=1",
          "--server-ip=127.0.0.1",
          "--server-username=root"
        ]
      end

      let(:csv_data) do
        [
          {
            "title" => "Test Book 1",
            "author" => "Test Author 1",
            "category" => "Test Category 1",
            "pages" => "100",
            "pdf_paths" => '["./book1/file1.pdf"]',
            "txt_paths" => '["./book1/file1.txt"]',
            "docx_paths" => '["./book1/file1.docx"]'
          },
          {
            "title" => "Test Book 2",
            "author" => "Test Author 2",
            "category" => "Test Category 2",
            "pages" => "200",
            "pdf_paths" => '["./book2/file1.pdf", "./book2/file2.pdf"]',
            "txt_paths" => '["./book2/file1.txt", "./book2/file2.txt"]',
            "docx_paths" => '["./book2/file1.docx", "./book2/file2.docx"]'
          }
        ]
      end

      before do
        allow(file_system).to receive(:file_exists?).with(index_path).and_return(true)
        allow(file_system).to receive(:read_csv).with(index_path, col_sep: "\t", headers: true).and_return(csv_data)
      end

      it "processes all books successfully" do # rubocop:disable RSpec/ExampleLength,RSpec/MultipleExpectations
        allow(ssh_client).to receive(:execute_with_output)

        importer.run

        expect(ssh_client).to have_received(:execute_with_output).twice do |server_ip, username, command, &block|
          expect(server_ip).to eq("127.0.0.1")
          expect(username).to eq("root")
          expect(command).to include("docker exec $(docker ps -aqf \"name=aljam3-web\" | head -n 1)")
          expect(command).to include("bundle exec rake db:import_book")

          block.call("Import successful") if block
        end

        expect(output.string).to include("Import successful")
      end

      it "builds correct import commands" do # rubocop:disable RSpec/ExampleLength,RSpec/MultipleExpectations
        allow(ssh_client).to receive(:execute_with_output)

        importer.run

        expected_commands = []

        expect(ssh_client).to have_received(:execute_with_output).twice do |_server_ip, _username, command, &block|
          expected_commands << command
        end

        # Check first book command
        expect(expected_commands[0]).to include('--title="Test Book 1"')
        expect(expected_commands[0]).to include('--author="Test Author 1"')
        expect(expected_commands[0]).to include('--category="Test Category 1"')
        expect(expected_commands[0]).to include('--pages=100')
        expect(expected_commands[0]).to include('--library-id=1')
        expect(expected_commands[0]).to include('--pdf-urls="https://huggingface.co/datasets/test/library/resolve/main/book1/file1.pdf"')

        # Check second book command
        expect(expected_commands[1]).to include('--title="Test Book 2"')
        expect(expected_commands[1]).to include('--pdf-urls="https://huggingface.co/datasets/test/library/resolve/main/book2/file1.pdf;https://huggingface.co/datasets/test/library/resolve/main/book2/file2.pdf"')
      end

      context "when book has volumes" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        let(:csv_data) do
          [
            {
              "title" => "Book with Volumes",
              "author" => "Test Author",
              "category" => "Test Category",
              "pages" => "100",
              "volumes" => "3",
              "pdf_paths" => '["./book1/file1.pdf"]',
              "txt_paths" => '["./book1/file1.txt"]',
              "docx_paths" => '["./book1/file1.docx"]'
            }
          ]
        end

        it "includes volumes parameter in the command" do # rubocop:disable RSpec/MultipleExpectations
          allow(ssh_client).to receive(:execute_with_output)

          importer.run

          expect(ssh_client).to have_received(:execute_with_output) do |_server_ip, _username, command, &block|
            expect(command).to include('--volumes="3"')
          end
        end
      end

      context "when book has no volumes" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        let(:csv_data) do
          [
            {
              "title" => "Book without Volumes",
              "author" => "Test Author",
              "category" => "Test Category",
              "pages" => "100",
              "pdf_paths" => '["./book1/file1.pdf"]',
              "txt_paths" => '["./book1/file1.txt"]',
              "docx_paths" => '["./book1/file1.docx"]'
            }
          ]
        end

        it "does not include volumes parameter in the command" do # rubocop:disable RSpec/MultipleExpectations
          allow(ssh_client).to receive(:execute_with_output)

          importer.run

          expect(ssh_client).to have_received(:execute_with_output) do |_server_ip, _username, command, &block|
            expect(command).not_to include('--volumes=')
          end
        end
      end

      context "when book has empty volumes" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        let(:csv_data) do
          [
            {
              "title" => "Book with Empty Volumes",
              "author" => "Test Author",
              "category" => "Test Category",
              "pages" => "100",
              "volumes" => "",
              "pdf_paths" => '["./book1/file1.pdf"]',
              "txt_paths" => '["./book1/file1.txt"]',
              "docx_paths" => '["./book1/file1.docx"]'
            }
          ]
        end

        it "does not include volumes parameter in the command" do # rubocop:disable RSpec/MultipleExpectations
          allow(ssh_client).to receive(:execute_with_output)

          importer.run

          expect(ssh_client).to have_received(:execute_with_output) do |_server_ip, _username, command, &block|
            expect(command).not_to include('--volumes=')
          end
        end
      end

      context "when dry-run is enabled" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        let(:argv) do
          [
            "--index-path=#{index_path}",
            "--huggingface-library-id=test/library",
            "--aljam3-library-id=1",
            "--server-ip=127.0.0.1",
            "--server-username=root",
            "--dry-run"
          ]
        end

        it "does not execute SSH commands" do
          allow(ssh_client).to receive(:execute_with_output)

          importer.run

          expect(ssh_client).not_to have_received(:execute_with_output)
        end
      end

      context "when skip-first is not provided" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        it "processes all books (default behavior)" do # rubocop:disable RSpec/MultipleExpectations
          allow(ssh_client).to receive(:execute_with_output)

          importer.run

          expect(ssh_client).to have_received(:execute_with_output).twice
        end
      end

      context "when skip-first is 0" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        let(:argv) do
          [
            "--index-path=#{index_path}",
            "--huggingface-library-id=test/library",
            "--aljam3-library-id=1",
            "--server-ip=127.0.0.1",
            "--server-username=root",
            "--skip-first=0"
          ]
        end

        it "processes all books" do # rubocop:disable RSpec/MultipleExpectations
          allow(ssh_client).to receive(:execute_with_output)

          importer.run

          expect(ssh_client).to have_received(:execute_with_output).twice
        end
      end

      context "when skip-first is 1" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        let(:argv) do
          [
            "--index-path=#{index_path}",
            "--huggingface-library-id=test/library",
            "--aljam3-library-id=1",
            "--server-ip=127.0.0.1",
            "--server-username=root",
            "--skip-first=1"
          ]
        end

        it "skips the first book and processes the rest" do # rubocop:disable RSpec/MultipleExpectations,RSpec/ExampleLength
          allow(ssh_client).to receive(:execute_with_output)

          importer.run

          expect(ssh_client).to have_received(:execute_with_output).once do |_server_ip, _username, command, &block|
            expect(command).to include('--title="Test Book 2"')
            expect(command).not_to include('--title="Test Book 1"')
          end
        end
      end

      context "when skip-first is 2" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        let(:argv) do
          [
            "--index-path=#{index_path}",
            "--huggingface-library-id=test/library",
            "--aljam3-library-id=1",
            "--server-ip=127.0.0.1",
            "--server-username=root",
            "--skip-first=2"
          ]
        end

        it "skips both books" do # rubocop:disable RSpec/MultipleExpectations
          allow(ssh_client).to receive(:execute_with_output)

          importer.run

          expect(ssh_client).not_to have_received(:execute_with_output)
        end
      end

      context "when skip-first is greater than total books" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        let(:argv) do
          [
            "--index-path=#{index_path}",
            "--huggingface-library-id=test/library",
            "--aljam3-library-id=1",
            "--server-ip=127.0.0.1",
            "--server-username=root",
            "--skip-first=10"
          ]
        end

        it "skips all books" do # rubocop:disable RSpec/MultipleExpectations
          allow(ssh_client).to receive(:execute_with_output)

          importer.run

          expect(ssh_client).not_to have_received(:execute_with_output)
        end
      end

      context "when book has invalid data" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        let(:csv_data) do
          [
            {
              "title" => "Invalid Book",
              "author" => "Test Author",
              "category" => "Test Category",
              "pages" => "100",
              "pdf_paths" => '["./book1/file1.pdf"]',
              "txt_paths" => '["./book1/file1.txt", "./book1/file2.txt"]',
              "docx_paths" => '["./book1/file1.docx"]'
            }
          ]
        end

        it "skips the book and logs the reason" do # rubocop:disable RSpec/MultipleExpectations
          importer.run

          expect(output.string).to include('Skipping book "Invalid Book"')
          expect(output.string).to include("different number of files in different formats")
        end
      end

      context "when SSH command fails" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        before do
          allow(ssh_client).to receive(:execute_with_output).and_raise(RuntimeError, "SSH connection failed")
        end

        it "logs the error and continues" do # rubocop:disable RSpec/MultipleExpectations
          importer.run

          expect(output.string).to include("ERROR: Failed to import book 'Test Book 1': SSH connection failed")
          expect(output.string).to include("ERROR: Failed to import book 'Test Book 2': SSH connection failed")
        end
      end

      context "when paths contain special/UTF-8 characters" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        let(:csv_data) do
          [
            {
              "title" => "Book with Special Characters",
              "author" => "Author Name",
              "category" => "Category",
              "pages" => "100",
              "pdf_paths" => '["./books/file with spaces & symbols.pdf"]',
              "txt_paths" => '["./books/file with spaces & symbols.txt"]',
              "docx_paths" => '["./books/file with spaces & symbols.docx"]'
            }
          ]
        end

        it "properly encodes URLs" do # rubocop:disable RSpec/MultipleExpectations,RSpec/ExampleLength
          allow(ssh_client).to receive(:execute_with_output)

          importer.run

          expect(ssh_client).to have_received(:execute_with_output) do |_server_ip, _username, command, &block|
            expect(command).to include("file%20with%20spaces%20&%20symbols.pdf")
          end
        end
      end

      context "when JSON paths use single quotes" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        let(:csv_data) do
          [
            {
              "title" => "Book with Single Quotes",
              "author" => "Author",
              "category" => "Category",
              "pages" => "100",
              "pdf_paths" => "['./book/file.pdf']", # Single quotes
              "txt_paths" => "['./book/file.txt']",
              "docx_paths" => "['./book/file.docx']"
            }
          ]
        end

        it "properly parses the JSON" do # rubocop:disable RSpec/ExampleLength,RSpec/MultipleExpectations
          allow(ssh_client).to receive(:execute_with_output)

          importer.run

          expect(ssh_client).to have_received(:execute_with_output) do |_server_ip, _username, command, &block|
            expect(command).to include("file.pdf")
          end
        end
      end

      context "when files are sorted incorrectly" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        let(:csv_data) do
          [
            {
              "title" => "Book with Multiple Files",
              "author" => "Author",
              "category" => "Category",
              "pages" => "100",
              "pdf_paths" => '["./book/file2.pdf", "./book/file1.pdf"]',
              "txt_paths" => '["./book/file2.txt", "./book/file1.txt"]',
              "docx_paths" => '["./book/file2.docx", "./book/file1.docx"]'
            }
          ]
        end

        it "sorts URLs correctly" do # rubocop:disable RSpec/MultipleExpectations,RSpec/ExampleLength
          allow(ssh_client).to receive(:execute_with_output)

          importer.run

          expect(ssh_client).to have_received(:execute_with_output) do |_server_ip, _username, command, &block|
            # Verify file1 comes before file2 in the sorted order
            pdf_urls_match = command.match(/--pdf-urls="([^"]*)"/)

            expect(pdf_urls_match).not_to be_nil

            urls = pdf_urls_match[1]
            file1_pos = urls.index("file1.pdf")
            file2_pos = urls.index("file2.pdf")

            expect(file1_pos).not_to be_nil
            expect(file2_pos).not_to be_nil
            expect(file1_pos).to be < file2_pos

            # Also check that both files are present with semicolon separator
            expect(urls).to include("file1.pdf;")
            expect(urls).to include("file2.pdf")
          end
        end
      end
    end
  end
end
