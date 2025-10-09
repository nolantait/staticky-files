# frozen_string_literal: true

require "staticky/files/memory_file_system"

RSpec.describe Staticky::Files::MemoryFileSystem, "#rm_rf" do
  it "deletes directory" do
    path = subject.join("delete", "directory")
    subject.mkdir(path)
    subject.rm_rf(path)

    expect(path).not_to be_found
  end

  it "deletes a file" do
    path = subject.join("delete_directory", "file")
    subject.touch(path)
    subject.rm_rf(path)

    expect(path).not_to be_found
  end

  it "raises error if directory doesn't exist" do
    path = subject.join("delete", "directory")

    expect { subject.rm_rf(path) }
      .to raise_error do |exception|
        expect(exception).to be_a(Staticky::Files::IOError)
        expect(exception.cause).to be_a(Errno::ENOENT)
        expect(exception.message).to include(path.to_s)
      end
  end
end
