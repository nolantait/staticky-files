# frozen_string_literal: true

require "staticky/files/memory_file_system"

RSpec.describe Staticky::Files::MemoryFileSystem, "#rm" do
  it "deletes path" do
    path = subject.join("delete", "file")
    subject.touch(path)
    subject.rm(path)

    expect(path).not_to be_found
  end

  it "raises error if path doesn't exist" do
    path = subject.join("delete", "file")

    expect { subject.rm(path) }
      .to raise_error do |exception|
        expect(exception).to be_a(Staticky::Files::IOError)
        expect(exception.cause).to be_a(Errno::ENOENT)
        expect(exception.message).to include(path.to_s)
      end
  end

  it "raises error if path is a directory" do
    path = subject.join("delete", "directory")
    subject.mkdir(path)

    expect { subject.rm(path) }
      .to raise_error do |exception|
        expect(exception).to be_a(Staticky::Files::IOError)
        expect(exception.cause).to be_a(Errno::EPERM)
        expect(exception.message).to include(path.to_s)
      end
  end
end
