# frozen_string_literal: true

require "staticky/files/memory_file_system"

RSpec.describe Staticky::Files::MemoryFileSystem, "#mkdir_p" do
  it "creates directory" do
    directory = subject.join("mkdir_p")
    path = subject.join(directory, "file.rb")
    subject.mkdir_p(path)

    expect(subject.directory?(directory)).to be(true)
    expect(path).not_to be_found
  end

  it "creates intermediate directories" do
    directory = subject.join("path", "to", "mkdir_p")
    path = subject.join(directory, "file.rb")
    subject.mkdir_p(path)

    expect(subject.directory?(directory)).to be(true)
    expect(path).not_to be_found
  end

  # It fails due to an RSpec formatter that crashes
  it "raises error when path is a file" do
    file = subject.join("mkdir_p", "file")
    subject.write(file, content = "foo")
    path = subject.join(file, "nested")

    expect { subject.mkdir_p(path) }
      .to raise_error do |exception|
        expect(exception).to be_a(Staticky::Files::IOError)
        expect(exception.cause).to be_a(Errno::EEXIST)
      end

    # ensure it doesn't override already existing file
    expect(subject.directory?(path)).to be(false)
    expect(subject.read(file)).to eq(content)
  end

  it "raises error when path isn't writeable" do
    parent = subject.join("path")

    subject.mkdir(parent)
    subject.chmod(parent, 0o000)
    path = subject.join(parent, "to", "mkdir_p", "dir-not-writeable")

    expect { subject.mkdir_p(path) }
      .to raise_error do |exception|
        expect(exception).to be_a(Staticky::Files::IOError)
        expect(exception.cause).to be_a(Errno::EACCES)
        expect(exception.message).to include(parent.to_s)
      end
  end
end
