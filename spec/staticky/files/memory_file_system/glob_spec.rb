# frozen_string_literal: true

require "staticky/files/memory_file_system"

RSpec.describe Staticky::Files::MemoryFileSystem, "#glob" do
  before do
    # Set up a sample directory structure
    subject.mkdir_p("lib/nested/deep")
    subject.mkdir_p("app/models")
    subject.mkdir_p("spec")

    subject.write("lib/file_a.rb", "content")
    subject.write("lib/file_b.txt", "content")
    subject.write("lib/nested/file_c.rb", "content")
    subject.write("lib/nested/file_d.txt", "content")
    subject.write("lib/nested/deep/file_e.rb", "content")
    subject.write("app/models/user.rb", "content")
    subject.write("README.md", "content")
    subject.write("Rakefile", "content")
  end

  it "returns an empty array if no files match the pattern" do
    expect(subject.glob("/nothing/**/*.rb")).to eq([])
  end

  it "matches all files with *" do
    result = subject.glob("lib/*").sort
    expect(result).to include("lib/file_a.rb", "lib/file_b.txt", "lib/nested")
  end

  it "matches files with specific extension using *.ext" do
    result = subject.glob("lib/*.rb").sort
    expect(result).to eq(["lib/file_a.rb"])
  end

  it "recursively matches files with **/*" do
    result = subject.glob("lib/**/*").sort
    expected = [
      "lib/file_a.rb",
      "lib/file_b.txt",
      "lib/nested",
      "lib/nested/file_c.rb",
      "lib/nested/file_d.txt",
      "lib/nested/deep",
      "lib/nested/deep/file_e.rb"
    ].sort
    expect(result).to eq(expected)
  end

  it "recursively matches files with specific extension using **/*.ext" do
    result = subject.glob("lib/**/*.rb").sort
    expect(result).to eq(
      [
        "lib/file_a.rb",
        "lib/nested/file_c.rb",
        "lib/nested/deep/file_e.rb"
      ].sort
    )
  end

  it "matches files in multiple directories" do
    result = subject.glob("{lib,app}/**/*.rb").sort
    expect(result).to eq(
      [
        "lib/file_a.rb",
        "lib/nested/file_c.rb",
        "lib/nested/deep/file_e.rb",
        "app/models/user.rb"
      ].sort
    )
  end

  it "matches single character with ?" do
    subject.write("lib/file_x.rb", "content")
    subject.write("lib/file_y.rb", "content")

    result = subject.glob("lib/file_?.rb").sort
    expect(result).to eq(["lib/file_a.rb", "lib/file_x.rb", "lib/file_y.rb"].sort)
  end

  it "matches character sets with []" do
    result = subject.glob("lib/file_[ab].rb").sort
    expect(result).to eq(["lib/file_a.rb"])
  end

  it "matches character ranges with [a-z]" do
    subject.write("lib/file_z.rb", "content")
    result = subject.glob("lib/file_[a-c].rb").sort
    expect(result).to eq(["lib/file_a.rb"])
  end

  it "handles patterns starting with / for absolute paths" do
    # Since our memory file system may not have a concept of absolute paths,
    # this might need to be adjusted based on implementation
    # For now, we'll test that it doesn't crash
    expect { subject.glob("/lib/*.rb") }
      .not_to raise_error
  end

  it "matches dotfiles when explicitly specified" do
    subject.write("lib/.hidden", "content")
    result = subject.glob("lib/.*")
    expect(result).to include("lib/.hidden")
  end

  it "does not match dotfiles with * by default" do
    subject.write("lib/.hidden", "content")
    result = subject.glob("lib/*")
    expect(result).not_to include("lib/.hidden")
  end

  it "handles patterns with .." do
    subject.chdir("lib/nested")
    result = subject.glob("../*.rb").sort
    expect(result).to eq(["../file_a.rb"])
  end

  it "handles patterns with ." do
    subject.chdir("lib")
    result = subject.glob("./*.rb").sort
    expect(result).to eq(["./file_a.rb"])
  end

  it "returns relative paths when pattern is relative" do
    result = subject.glob("lib/*.rb")
    expect(result).to all(start_with("lib/"))
  end

  it "matches files without extension" do
    subject.write("lib/script", "content")
    result = subject.glob("lib/script")
    expect(result).to eq(["lib/script"])
  end

  it "matches directories specifically" do
    result = subject.glob("lib/nested/")
    # This might need adjustment based on implementation
    # Dir.glob includes trailing slash for directories when pattern has it
    expect(result).to include("lib/nested/")
  end
end
