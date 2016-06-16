require 'phut/ovsdb/method'
require 'phut/ovsdb/transport'
require 'yajl'

module Phut
  module OVSDB
    # OVSDB Client core
    class Client
      include Phut::OVSDB::Method

      attr_reader :transport
      attr_reader :database

      def initialize(host, port, options = {})
        @mut = Mutex.new
        @queue = Queue.new
        @transport = Transport.new(host, port, self, options)
        @database = options.fetch(:database, nil)
        initialize_codec
      end

      def handle_tcp(data)
        @parser << data
      end

      def handle_message(data)
        case data[:method]
        when 'echo'
          echo_reply
        else
          maybe_handle_reply(data)
        end
      end

      private

      def maybe_handle_reply(data)
        id = data[:id]
        case id
        when 'echo'
          :noop
        else
          @queue.enq(data)
        end
      end

      def initialize_codec
        @parser = Yajl::Parser.new(symbolize_keys: true)
        @parser.on_parse_complete = method(:handle_message)
        @encoder = Yajl::Encoder.new
      end

      def json_async_send(jsonable)
        json_data = @encoder.encode(jsonable)
        transport.send(json_data)
      end

      def json_send(jsonable)
        json_async_send(jsonable)
        th = Thread.new do
          result = nil
          continue = true
          while continue
            next if @queue.empty?
            @mut.synchronize { result = @queue.deq }
            continue = false
          end
          result
        end
        th.join.value
      end
    end
  end
end
