# frozen_string_literal: true

require "staticky/files/memory_file_system"

RSpec.describe Staticky::Files::MemoryFileSystem, "#mode" do
  it "gets UNIX mode" do
    path = subject.join("mode")
    subject.touch(path)
    subject.chmod(path, mode = 0o755)

    expect(subject.mode(path)).to eq(mode)
  end

  it "raises error if path doesn't exist" do
    path = subject.join("mode")

    expect { subject.mode(path) }
      .to raise_error do |exception|
        expect(exception).to be_a(Staticky::Files::IOError)
        expect(exception.cause).to be_a(Errno::ENOENT)
        expect(exception.message).to include(path.to_s)
      end
  end
end
