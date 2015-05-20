module Syslog
  class Stream
    class OctetCountingFraming
      def initialize(io)
        @io = io
      end

      def messages
        loop do
          length = ""
          octet = ""

          until octet == " " do
            if @io.read(1, octet) == nil
              return
            end

            length << octet
          end

          yield @io.read(Integer(length)).force_encoding("UTF-8")
        end
      end
    end
  end
end
