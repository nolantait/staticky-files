# frozen_string_literal: true

require "staticky/files/memory_file_system"
require "English"

RSpec.describe Staticky::Files::MemoryFileSystem, "#readlines" do
  let(:newline) { $INPUT_RECORD_SEPARATOR }

  it "reads file and returns array of lines" do
    path = subject.join("readlines-file")
    subject.write(path, "hello#{newline}world")

    expect(subject.readlines(path)).to eq(%W[hello#{newline} world])
  end

  it "reads empty file and returns empty array" do
    path = subject.join("readlines-empty-file")
    subject.touch(path)

    expect(subject.readlines(path)).to eq([])
  end

  it "raises error if file doesn't exist" do
    path = subject.join("readlines-non-existing-file")

    expect { subject.readlines(path) }
      .to raise_error do |exception|
        expect(exception).to be_a(Staticky::Files::IOError)
        expect(exception.cause).to be_a(Errno::ENOENT)
        expect(exception.message).to include(path.to_s)
      end
  end

  it "raises error if path is a directory" do
    path = subject.join("readlines", "directory")
    subject.mkdir(path)

    expect { subject.readlines(path) }
      .to raise_error do |exception|
        expect(exception).to be_a(Staticky::Files::IOError)
        expect(exception.cause).to be_a(Errno::EISDIR)
        expect(exception.message).to include(path.to_s)
      end
  end

  it "raises error if path isn't readable" do
    path = subject.join("readlines-unreadable-file")
    subject.write(path, "content")
    subject.chmod(path, 0o000) # No permissions

    expect { subject.readlines(path) }
      .to raise_error do |exception|
        expect(exception).to be_a(Staticky::Files::IOError)
        expect(exception.cause).to be_a(Errno::EACCES)
        expect(exception.message).to include(path.to_s)
      end
  end
end
