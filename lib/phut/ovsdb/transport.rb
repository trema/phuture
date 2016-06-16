require 'socket'

module Phut
  module OVSDB
    # OVSDB Transport Class
    class Transport
      attr_reader :host
      attr_reader :port
      attr_reader :options
      attr_reader :callback

      def initialize(host, port, klass, options = {})
        @options = options
        @host = host
        @port = port
        @callback = klass.method(:handle_tcp)
        signal_connect
        enter_loop
      end

      def send(data)
        @socket.write(data)
      rescue Errno::EPIPE
        signal_connect
      end

      def read
        @socket.readpartial(1000)
      end

      private

      def enter_loop
        Thread.abort_on_exception = true
        Thread.new do
          loop do
            begin
              handle_connection
            rescue => error
              raise error
            end
          end
        end
      end

      def signal_connect
        count = count.to_i + 1
        @socket = TCPSocket.open(host, port)
      rescue => error
        sleep reconnect_interval
        should_reconnect?(count) ? retry : raise(error)
      end

      def should_reconnect?(count)
        (reconnect && (reconnect_retry_limit > count))
      end

      def handle_connection
        callback.call(read)
      rescue EOFError
        signal_connect
      end

      def reconnect
        options[:reconnect] ||= false
      end

      def reconnect_interval
        options[:reconnect_interval] ||= 5
      end

      def reconnect_retry_limit
        options[:reconnect_retry_limit] ||= 10
      end
    end
  end
end
