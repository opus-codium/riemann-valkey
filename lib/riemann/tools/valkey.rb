# frozen_string_literal: true

require "redis"

require "riemann/tools"

module Riemann
  module Tools
    class Valkey
      include Riemann::Tools

      attr_reader :redis

      def initialize
        @redis = Redis.new
      end

      def tick
        redis = Redis.new
        memory_info = redis.info("MEMORY")
        used_memory = memory_info["used_memory"].to_i
        maxmemory = memory_info["maxmemory"].to_i

        memory_usage = used_memory.to_f / maxmemory
        report({
          service: "valkey memory",
          metric: memory_usage,
          state: memory_state(memory_usage),
          description: format("%.2f %%", memory_usage * 100)
        })
      end

      def memory_state(metric)
        if metric > 0.95
          "critical"
        elsif metric > 0.8
          "warning"
        else
          "ok"
        end
      end
    end
  end
end
