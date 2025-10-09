# frozen_string_literal: true

require "staticky/files/memory_file_system"

RSpec.describe Staticky::Files::MemoryFileSystem, "#entries" do
  it "raises an error when the path does not exist" do
    path = subject.join("file-1.txt")

    expect { subject.entries(path) }
      .to raise_error do |exception|
        expect(exception).to be_a(Staticky::Files::IOError)
        expect(exception.cause).to be_a(Errno::ENOENT)
        expect(exception.message).to include(path.to_s)
      end
  end

  it "raises an error when the path is a file" do
    path = subject.join("file-1.txt")
    subject.touch(path)

    expect { subject.entries(path) }
      .to raise_error do |exception|
        expect(exception).to be_a(Staticky::Files::IOError)
        expect(exception.cause).to be_a(Errno::ENOTDIR)
        expect(exception.message).to include(path.to_s)
      end
  end

  it "returns entries when the path is a directory" do
    subject.touch(subject.join("file-1.txt"))
    subject.touch(subject.join("file-2.txt"))

    expect(subject.entries(subject.join)).to eq [
      ".",
      "..",
      "file-1.txt",
      "file-2.txt"
    ]
  end

  it "returns an array with only relative paths on an empty directory" do
    subject.mkdir("empty")

    expect(subject.entries(subject.join("empty"))).to eq [".", ".."]
  end
end
