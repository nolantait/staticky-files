# frozen_string_literal: true

require "staticky/files/memory_file_system"
require "English"

RSpec.describe Staticky::Files::MemoryFileSystem, "#read" do
  let(:newline) { $INPUT_RECORD_SEPARATOR }

  it "reads file" do
    path = subject.join("read")
    subject.write(path, expected = "Hello#{newline}World")

    expect(subject.read(path)).to eq(expected)
  end

  it "raises error when path is a directory" do
    path = subject.join("read-directory")
    subject.mkdir(path)

    expect { subject.read(path) }
      .to raise_error do |exception|
        expect(exception).to be_a(Staticky::Files::IOError)
        expect(exception.cause).to be_a(Errno::EISDIR)
        expect(exception.message).to include(path.to_s)
      end
  end

  it "raises error when path doesn't exist" do
    path = subject.join("read-does-not-exist")

    expect { subject.read(path) }
      .to raise_error do |exception|
        expect(exception).to be_a(Staticky::Files::IOError)
        expect(exception.cause).to be_a(Errno::ENOENT)
        expect(exception.message).to include(path.to_s)
      end
  end
end
