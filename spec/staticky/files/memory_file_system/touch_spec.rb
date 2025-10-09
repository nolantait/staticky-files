# frozen_string_literal: true

require "staticky/files/memory_file_system"

RSpec.describe Staticky::Files::MemoryFileSystem, "#touch" do
  it "creates an empty file" do
    path = subject.join("touch")
    subject.touch(path)

    expect(path).to be_found
    expect(path).to have_file_contents("")
  end

  it "creates intermediate directories" do
    path = subject.join("path", "to", "file", "touch")
    subject.touch(path)

    expect(path).to be_found
    expect(path).to have_file_contents("")
  end

  it "leaves untouched existing file" do
    path = subject.join("touch")
    subject.write(path, "foo")
    subject.touch(path)

    expect(path).to be_found
    expect(path).to have_file_contents("foo")
  end

  it "raises error if path is a directory" do
    path = subject.join("touch-directory")
    subject.mkdir(path)

    expect { subject.touch(path) }
      .to raise_error do |exception|
        expect(exception).to be_a(Staticky::Files::IOError)
        expect(exception.cause).to be_a(Errno::EISDIR)
        expect(exception.message).to include(path.to_s)
      end
  end
end
