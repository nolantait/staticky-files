# frozen_string_literal: true

require "staticky/files/memory_file_system"

RSpec.describe Staticky::Files::MemoryFileSystem, "#chdir" do
  it "changes current working directory" do
    current_directory = subject.pwd
    subject.mkdir(dir = "path/to/dir")

    subject.chdir(dir) do
      expect(subject.pwd).to eq("dir")
    end

    expect(subject.pwd).to eq(current_directory)
  end

  it "raises error if directory cannot be found" do
    path = subject.join("chdir-non-existing")

    expect { subject.chdir(path) }
      .to raise_error do |exception|
        expect(exception).to be_a(Staticky::Files::IOError)
        expect(exception.cause).to be_a(Errno::ENOENT)
        expect(exception.message).to include(path.to_s)
      end
  end

  it "raises error if argument is a file" do
    path = subject.join("chdir-file")
    subject.touch(path)

    expect { subject.chdir(path) }
      .to raise_error do |exception|
        expect(exception).to be_a(Staticky::Files::IOError)
        expect(exception.cause).to be_a(Errno::ENOTDIR)
        expect(exception.message).to match(path.to_s)
      end
  end
end
