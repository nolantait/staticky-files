# frozen_string_literal: true

require "staticky/files/memory_file_system"

RSpec.describe Staticky::Files::MemoryFileSystem, "#mkdir" do
  it "creates directory" do
    path = subject.join("mkdir")
    subject.mkdir(path)

    expect(subject.directory?(path)).to be(true)
  end

  it "creates intermediate directories" do
    path = subject.join("path", "to", "mkdir")
    subject.mkdir(path)

    expect(subject.directory?(path)).to be(true)
  end

  it "raises error when path is a file" do
    path = subject.join("mkdir-is-file")
    subject.write(path, content = "foo")

    expect { subject.mkdir(path) }
      .to raise_error do |exception|
        expect(exception).to be_a(Staticky::Files::IOError)
        expect(exception.cause).to be_a(Errno::EEXIST)
        expect(exception.message).to include(path.to_s)
      end

    # ensure it doesn't override already existing file
    expect(subject.directory?(path)).to be(false)
    expect(subject.read(path)).to eq(content)
  end

  xit "raises error when path isn't writeable" do
    path = subject.join("mkdir-not-writeable")
    path.mkpath
    mode = path.stat.mode

    begin
      path.chmod(0o000)

      expect { subject.mkdir(path.join("dir-not-writeable")) }
        .to raise_error do |exception|
          expect(exception).to be_a(Staticky::Files::IOError)
          expect(exception.cause).to be_a(Errno::EACCES)
          expect(exception.message).to include(path.to_s)
        end
    ensure
      path.chmod(mode)
    end
  end
end
