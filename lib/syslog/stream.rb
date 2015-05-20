require "syslog/parser"
require "syslog/stream/octet_counting_framing"

module Syslog
  class Stream
    def initialize(framing, options={})
      @framing = framing
      @parser = options.fetch(:parser) { Syslog::Parser.new }
    end

    def messages
      return to_enum(__callee__) unless block_given?

      @framing.messages do |message|
        yield @parser.parse(message)
      end
    end
  end
end
