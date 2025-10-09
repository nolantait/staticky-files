# frozen_string_literal: true

require "staticky/files/memory_file_system"

RSpec.describe Staticky::Files::MemoryFileSystem, "#directory?" do
  it "returns true for directory" do
    path = subject.join("directory-dir")
    subject.mkdir(path)

    expect(subject.directory?(path)).to be(true)
  end

  it "returns false for file" do
    path = subject.join("directory-file")
    subject.touch(path)

    expect(subject.directory?(path)).to be(false)
  end

  it "returns false for non-existing path" do
    path = subject.join("directory-non-existing")

    expect(subject.directory?(path)).to be(false)
  end
end
