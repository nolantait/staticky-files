# frozen_string_literal: true

require "staticky/files/memory_file_system"
require "English"

RSpec.describe Staticky::Files::MemoryFileSystem do
  let(:newline) { $INPUT_RECORD_SEPARATOR }

  describe "#initialize" do
    it "returns a new instance" do
      expect(subject).to be_a(described_class)
    end
  end

  describe "#expand_path" do
    it "expands path from given directory" do
      dir = subject.join("expand-path", "given-dir")
      expected = subject.join(dir, path = "file")

      expect(subject.expand_path(path, dir)).to eq(expected)
    end

    it "returns absolute path as it is" do
      path = File::SEPARATOR + subject.join("expand-path", "absolute")
      expect(subject.expand_path(path, subject.pwd)).to eq(path)
    end
  end

  describe "#pwd" do
    it "returns root directory by default" do
      expect(subject.pwd).to eq("/")
    end
  end

  describe "#chmod" do
    it "sets UNIX mode" do
      path = subject.join("chmod")
      subject.touch(path)
      subject.chmod(path, mode = 0o755)

      expect(subject.mode(path)).to eq(mode)
    end

    it "raises error if path doesn't exist" do
      path = subject.join("chmod")

      expect { subject.chmod(path, 0o755) }
        .to raise_error do |exception|
          expect(exception).to be_a(Staticky::Files::IOError)
          expect(exception.cause).to be_a(Errno::ENOENT)
          expect(exception.message).to include(path.to_s)
        end
    end
  end
end
