# frozen_string_literal: true

require "riemann/tools/valkey"

RSpec.describe Riemann::Tools::Valkey do
  subject(:tool) { described_class.new }

  let(:info) do
    {
      "used_memory" => "67956200",
      "maxmemory" => "128000000"
    }
  end

  before do
    redis = double
    allow(redis).to receive(:info).and_return(info)

    allow(Redis).to receive(:new).and_return(redis)
  end

  describe "#tick" do
    before do
      allow(tool).to receive(:report)
      tool.tick
    end

    context "with low memory usage" do
      it "report correct state" do
        expect(tool).to have_received(:report).with({metric: 0.5309078125, description: "53.09 %", service: "valkey memory", state: "ok"})
      end
    end

    context "with intemediate memory usage" do
      let(:info) do
        {
          "used_memory" => "120000000",
          "maxmemory" => "128000000"
        }
      end

      it "report correct state" do
        expect(tool).to have_received(:report).with({metric: 0.9375, description: "93.75 %", service: "valkey memory", state: "warning"})
      end
    end

    context "with intemediate memory usage" do
      let(:info) do
        {
          "used_memory" => "127000000",
          "maxmemory" => "128000000"
        }
      end

      it "report correct state" do
        expect(tool).to have_received(:report).with({metric: 0.9921875, description: "99.22 %", service: "valkey memory", state: "critical"})
      end
    end
  end
end
