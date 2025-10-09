# frozen_string_literal: true

require "staticky/files/memory_file_system"

RSpec.describe Staticky::Files::MemoryFileSystem, "#join" do
  it "joins a single entry" do
    path = "path"
    expect(subject.join(path)).to eq(path)

    path = Pathname.new(path)
    expect(subject.join(path)).to eq(path.to_s)
  end

  it "joins multiple entries" do
    path = %w[path to file]
    expected = path.join(File::SEPARATOR)

    expect(subject.join(path)).to eq(expected)

    path = path.map { |p| Pathname.new(p) }
    expect(subject.join(path)).to eq(expected)
  end
end
