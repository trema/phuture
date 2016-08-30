require 'e2mmap'

module Phut
  module OVSDB
    # OVSDB methods
    module Method
      extend Exception2MessageMapper

      def_exception :GetSchemaError, '%s'
      def_exception :TransactionError, '%s'

      def echo_reply
        json_async_send(id: 'echo', result: [], error: nil)
      end

      def transact(id, db_name, operations)
        data = json_send(
          id: id,
          method: 'transact',
          params: [db_name, *operations]
        )
        data[:result]
      end
    end
  end
end
