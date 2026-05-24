# frozen_string_literal: true

require "test_helper"

class Balance::SearchableTest < ActiveSupport::TestCase
  setup do
    @balance = balances(:searchable_balance)
  end

  test "#as_indexed_json includes all fields" do
    assert_equal(
      {
        "user_id" => @balance.user_id,
        "amount_cents" => 123,
        "state" => "unpaid",
      },
      @balance.as_indexed_json
    )
  end

  test "#as_indexed_json allows only a selection of fields to be used" do
    assert_equal({ "amount_cents" => 123 }, @balance.as_indexed_json(only: ["amount_cents"]))
  end

  test ".amount_cents_sum_for returns sum of unpaid balance in cents" do
    skip "Elasticsearch-bound (.amount_cents_sum_for uses ES aggregations + :elasticsearch_wait_for_refresh); ES infra is skip-batch per skill."
  end
end
