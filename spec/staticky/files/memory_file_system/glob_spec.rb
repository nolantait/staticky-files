# frozen_string_literal: true

require "staticky/files/memory_file_system"

RSpec.describe Staticky::Files::MemoryFileSystem, "#glob" do
  it "returns all Ruby files in the memory file system" do
    subject.write("lib/deeper/file1.rb", "content")
    subject.write("lib/file2.rb", "content")
    subject.write("lib/file.txt", "content")
    subject.mkdir("lib/dir")
    subject.write("lib/dir/file3.rb", "content")
    subject.mkdir("lib/empty_dir")

    expect(subject.glob("/lib/**/*.rb")).to contain_exactly(
      "/lib/deeper/file1.rb",
      "/lib/file2.rb",
      "/lib/dir/file3.rb"
    )

    expect(subject.glob(Pathname.new("/lib/**/*.rb"))).to contain_exactly(
      "/lib/deeper/file1.rb",
      "/lib/file2.rb",
      "/lib/dir/file3.rb"
    )
  end

  it "returns an empty array if no files match the pattern" do
    subject.write("lib/file.txt", "content")

    expect(subject.glob("**/*.rb")).to eq([])
  end
end
