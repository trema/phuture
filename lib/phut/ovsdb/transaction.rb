module Phut
  module OVSDB
    # Transaction
    module Transaction
      def select(table, conds, cols = nil)
        select = {
          op: :select,
          table: table,
          where: Array(conds)
        }
        select = { columns: Array(cols) }.merge(select) if cols
        select
      end

      def insert(table, row, uuid_name = nil)
        insert = {
          op: :insert,
          table: table,
          row: row
        }
        insert = { 'uuid-name' => uuid_name }.merge(insert) if uuid_name
        insert
      end

      def update(table, conds, row)
        {
          op: :update,
          table: table,
          where: Array(conds),
          row: row
        }
      end

      def delete(table, conds)
        {
          op: :delete,
          table: table,
          where: Array(conds)
        }
      end

      def mutate(table, conds, mutes)
        {
          op: :mutate,
          table: table,
          where: Array(conds),
          mutations: Array(mutes)
        }
      end

      def commit(mode = true)
        {
          op: :commit,
          durable: mode
        }
      end

      def abort
        {
          op: :abort
        }
      end

      def wait(table, cond, cols, until_cond, rows, timeout = nil)
        wait = {
          op: :wait,
          table: table,
          where: Array(cond),
          columns: Array(cols),
          until: until_cond,
          rows: Array(rows)
        }
        wait = { timeout: timeout }.merge(wait) if timeout
        wait
      end

      def comment(string)
        {
          op: :comment,
          comment: string
        }
      end

      def assert(lock_id)
        {
          op: :assert,
          lock: lock_id
        }
      end
    end
  end
end
