# frozen_string_literal: true

require "staticky/files/memory_file_system"

RSpec.describe Staticky::Files::MemoryFileSystem, "#executable?" do
  it "returns true when file is executable" do
    path = subject.join("executable-exec")
    subject.touch(path)
    subject.chmod(path, 0o744)

    expect(subject.executable?(path)).to be(true)
  end

  it "returns false when file isn't executable" do
    path = subject.join("executable-non-exec")
    subject.touch(path)

    expect(subject.executable?(path)).to be(false)
  end

  it "returns false when file doesn't exist" do
    path = subject.join("executable-non-existing")

    expect(subject.executable?(path)).to be(false)
  end

  it "returns true for directory" do
    path = subject.join("executable-directory")
    subject.mkdir(path)

    expect(subject.executable?(path)).to be(true)
  end
end
