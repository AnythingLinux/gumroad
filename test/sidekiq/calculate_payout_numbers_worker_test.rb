# frozen_string_literal: true

require "test_helper"

class CalculatePayoutNumbersWorkerTest < ActiveSupport::TestCase
  setup do
    # The worker reads ES aggregations via PurchaseSearchService. The global
    # EsClient stub in test_helper.rb returns no aggregations, so stub the
    # service per-test to return a canned aggregation value object.
    @original_process = PurchaseSearchService.instance_method(:process)
  end

  teardown do
    PurchaseSearchService.send(:remove_method, :process) if PurchaseSearchService.instance_methods(false).include?(:process)
    PurchaseSearchService.define_method(:process, @original_process) if @original_process
    $redis.del(RedisKey.prev_week_payout_usd)
  end

  def stub_total_cents(cents)
    agg = Struct.new(:total_made).new(Struct.new(:value).new(cents))
    result = Struct.new(:aggregations).new(agg)
    PurchaseSearchService.define_method(:process) { result }
  end

  test "#perform stores the expected payout data in Redis" do
    expected_cents = 123_45 + 234_56 + 567_89 + 890_12
    stub_total_cents(expected_cents)

    CalculatePayoutNumbersWorker.new.perform

    assert_equal (expected_cents / 100).to_s, $redis.get(RedisKey.prev_week_payout_usd)
  end

  test "#perform stores zero in Redis when there is no data" do
    stub_total_cents(0)

    CalculatePayoutNumbersWorker.new.perform

    assert_equal "0", $redis.get(RedisKey.prev_week_payout_usd)
  end
end
