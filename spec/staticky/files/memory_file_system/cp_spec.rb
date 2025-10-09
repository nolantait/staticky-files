# frozen_string_literal: true

require "staticky/files/memory_file_system"

RSpec.describe Staticky::Files::MemoryFileSystem, "#cp" do
  let(:source) { subject.join("..", "source") }

  before do
    subject.rm(source) if subject.exist?(source)
  end

  it "creates a file with given contents" do
    subject.write(source, "the source")

    destination = subject.join("cp")
    subject.cp(source, destination)

    expect(destination).to be_found
    expect(destination).to have_file_contents("the source")
  end

  it "creates intermediate directories" do
    source = subject.join("..", "source")
    subject.write(source, "the source for intermediate directories")

    destination = subject.join("cp", "destination")
    subject.cp(source, destination)

    expect(destination).to be_found
    expect(destination).to have_file_contents("the source for intermediate directories")
  end

  it "overrides already existing file" do
    source = subject.join("..", "source")
    subject.write(source, "the source")

    destination = subject.join("cp")
    subject.write(destination, "the destination")
    subject.cp(source, destination)

    expect(destination).to be_found
    expect(destination).to have_file_contents("the source")
  end

  it "raises error when source cannot be found" do
    source = subject.join("missing-source")
    destination = subject.join("cp")

    expect { subject.cp(source, destination) }
      .to raise_error do |exception|
        expect(exception).to be_a(Staticky::Files::IOError)
        expect(exception.cause).to be_a(Errno::ENOENT)
        expect(exception.message).to include(source.to_s)
      end
  end
end
