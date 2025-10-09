# frozen_string_literal: true

require "staticky/files/memory_file_system"

RSpec.describe Staticky::Files::MemoryFileSystem, "#exist?" do
  it "returns true for file" do
    path = subject.join("exist-file")
    subject.touch(path)

    expect(subject.exist?(path)).to be(true)
  end

  it "returns true for directory" do
    path = subject.join("exist-dir")
    subject.mkdir(path)

    expect(subject.exist?(path)).to be(true)
  end

  it "returns false for non-existing file" do
    path = subject.join("exist-non-existing")

    expect(subject.exist?(path)).to be(false)
  end
end
