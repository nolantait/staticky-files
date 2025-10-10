# frozen_string_literal: true

require "staticky/files/memory_file_system"
require "English"

RSpec.describe Staticky::Files::MemoryFileSystem, "#write" do
  let(:newline) { $INPUT_RECORD_SEPARATOR }

  it "creates an file with given contents (string)" do
    path = subject.join("write")
    subject.write(path, "Hello#{newline}World")

    expect(path).to be_found
    expect(path).to have_file_contents("Hello#{newline}World")
  end

  it "creates an file with given contents (array)" do
    path = subject.join("write")
    content = ["# frozen_string_literal: true#{newline}", newline, "module Foo#{newline}", "  class App#{newline}", "    CONSTANT = 23#{newline}", newline, "    def call(*)#{newline}", "    end#{newline}", "  end#{newline}", "end#{newline}"]
    expected = <<~CONTENT
      # frozen_string_literal: true

      module Foo
        class App
          CONSTANT = 23

          def call(*)
          end
        end
      end
    CONTENT
    subject.write(path, content)

    expect(path).to be_found
    expect(path).to have_file_contents(expected)
  end

  it "creates intermediate directories" do
    path = subject.join("path", "to", "file", "write")
    subject.write(path, ":)")

    expect(path).to be_found
    expect(path).to have_file_contents(":)")
  end

  it "overwrites file when it already exist" do
    path = subject.join("write")
    subject.write(path, "many many many many words")
    subject.write(path, "new words")

    expect(path).to be_found
    expect(path).to have_file_contents("new words")
  end

  it "raises error when path isn't writeable" do
    path = Pathname.new(subject.join("write-not-writeable"))
    subject.mkdir(path)
    subject.chmod(path, 0o000)

    expect { subject.write(path.join("file-not-writeable"), "content") }
      .to raise_error do |exception|
        expect(exception).to be_a(Staticky::Files::IOError)
        expect(exception.cause).to be_a(Errno::EACCES)
        expect(exception.message).to include(path.to_s)
      end
  end
end
