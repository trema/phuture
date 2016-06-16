require 'e2mmap'

module Phut
  module OVSDB
    # OVSDB methods
    module Method
      extend Exception2MessageMapper

      def_exception :GetSchemaError, '%s'
      def_exception :TransactionError, '%s'

      def echo(id, params = [])
        data = json_send(id: id, method: 'echo', params: params)
        data[:result]
      end

      def echo_reply
        json_async_send(id: 'echo', result: [], error: nil)
      end

      def list_dbs(id)
        data = json_send(id: id, method: 'list_dbs', params: [])
        data[:result]
      end

      def get_schema(id, db_name = @database)
        data = json_send(
          id: id,
          method: 'get_schema',
          params: Array(db_name)
        )
        error = data[:error]
        if error
          raise(GetSchemaError, get_schema_errmsg(error))
        else
          data[:result]
        end
      end

      def transact(id, db_name, operations)
        data = json_send(
          id: id,
          method: 'transact',
          params: [db_name, *operations]
        )
        data[:result]
      end

      def cancel(id, params)
      end

      def monitor(id, params)
      end

      def update(id, params)
      end

      def monitor_cancel(id, params)
      end

      def lock(id, params)
      end

      def steal(id, params)
      end

      def unlock(id, params)
      end

      private

      def get_schema_errmsg(error)
        "error: #{error[:error]}, details: #{error[:details]}"
      end
    end
  end
end
