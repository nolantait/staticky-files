# frozen_string_literal: true

RSpec.describe Staticky::Files::Adapter do
  describe ".call" do
    let(:subject) { described_class.call(memory:) }

    context "memory: true" do
      let(:memory) { true }

      it "returns memory file system adapter" do
        expect(subject).to be_a(Staticky::Files::MemoryFileSystem)
      end
    end

    context "memory: false" do
      let(:memory) { false }

      it "returns real file system adapter" do
        expect(subject).to be_a(Staticky::Files::FileSystem)
      end
    end
  end
end
