# frozen_string_literal: true

require "staticky/files/memory_file_system"

RSpec.describe Staticky::Files::MemoryFileSystem, "#open" do
  context "when file doesn't exist" do
    it "creates file with empty content and yields node" do
      path = subject.join("open-new")

      subject.open(path, Staticky::Files::OPEN_MODE) do |file|
        expect(file).to be_a(Staticky::Files::MemoryFileSystem::Node)
      end

      expect(path).to have_file_contents("")
    end
  end

  context "when already exist" do
    it "creates file with empty content and yields node" do
      path = subject.join("open-non-existing")
      subject.write("open-non-existing", content = "foo")

      subject.open(path, Staticky::Files::OPEN_MODE) do |file|
        expect(file).to be_a(Staticky::Files::MemoryFileSystem::Node)
      end

      expect(path).to have_file_contents(content)
    end
  end

  context "when no block is given" do
    it "returns the open file object" do
      path = subject.join("open-new")

      file = subject.open(path, Staticky::Files::OPEN_MODE)
      expect(file).to be_a(Staticky::Files::MemoryFileSystem::Node)

      expect(path).to have_file_contents("")
    end
  end
end
