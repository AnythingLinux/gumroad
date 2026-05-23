# frozen_string_literal: true

module Mysql2
  class Client
    MISSING_TABLE_GRACE_PERIOD = 5.seconds
    MISSING_TABLE = /Table .* doesn't exist/
    FOREIGN_KEY_CONSTRAINT_BLOCKS_DROP = /Cannot drop table .* referenced by a foreign key constraint/

    alias original_query query
    def query(sql, options = {})
      foreign_key_checks_disabled = false
      original_query(sql, options)
    rescue Mysql2::Error => e
      if MISSING_TABLE.match?(e.message)
        warn "Error: missing table, retrying in #{MISSING_TABLE_GRACE_PERIOD} seconds..."
        sleep MISSING_TABLE_GRACE_PERIOD
        original_query(sql, options)
      elsif FOREIGN_KEY_CONSTRAINT_BLOCKS_DROP.match?(e.message)
        warn "Error: foreign key constraint blocked table drop, retrying with foreign key checks disabled..."
        original_query("SET FOREIGN_KEY_CHECKS = 0")
        foreign_key_checks_disabled = true
        original_query(sql, options)
      else
        raise
      end
    ensure
      original_query("SET FOREIGN_KEY_CHECKS = 1") if foreign_key_checks_disabled
    end
  end
end
