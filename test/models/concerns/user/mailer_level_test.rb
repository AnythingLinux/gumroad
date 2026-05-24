require "test_helper"

class User::MailerLevelTest < ActiveSupport::TestCase
  setup do
    @creator = users(:named_seller)
    @redis_namespace = Redis::Namespace.new(:user_mailer_redis_namespace, redis: $redis)
    # Clean Memcached + Redis state for this user so each test starts fresh.
    Rails.cache.delete("creator_mailer_level_#{@creator.id}")
    @redis_namespace.del("creator_mailer_level_#{@creator.id}")
  end

  teardown do
    Rails.cache.delete("creator_mailer_level_#{@creator.id}")
    @redis_namespace.del("creator_mailer_level_#{@creator.id}")
  end

  # --- level_1 ---

  test "returns :level_1 when creator belongs to level_1" do
    # Short-circuit ES aggregations: real sales_cents_total reaches
    # User::Stats#revenue_as_seller which expects PurchaseSearchService aggregations
    # that the global EsClient stub doesn't fill in.
    @creator.stub(:sales_cents_total, 0) do
      assert_equal :level_1, @creator.mailer_level
    end
  end

  test "returns :level_1 for negative sales_cents_total" do
    @creator.stub(:sales_cents_total, -20_000_00) do
      assert_equal :level_1, @creator.mailer_level
    end
  end

  # --- level_2 ---

  test "returns :level_2 when creator belongs to level_2" do
    @creator.stub(:sales_cents_total, 60_000_00) do
      assert_equal :level_2, @creator.mailer_level
    end
  end

  test "returns :level_2 for very large sales_cents_total" do
    @creator.stub(:sales_cents_total, 800_000_000_00) do
      assert_equal :level_2, @creator.mailer_level
    end
  end

  # --- caching ---

  test "sets the level in redis" do
    @creator.stub(:sales_cents_total, 0) do
      @creator.mailer_level
    end
    assert_equal "level_1", @redis_namespace.get(@creator.send(:mailer_level_cache_key))
  end

  test "doesn't query sales_cents_total when level is available in redis" do
    @redis_namespace.set("creator_mailer_level_#{@creator.id}", "level_2")

    called = false
    @creator.define_singleton_method(:sales_cents_total) do |*_args, **_kwargs|
      called = true
      0
    end

    level = @creator.mailer_level
    assert_equal :level_2, level
    assert_equal false, called, "sales_cents_total should not be called when redis has cached level"
  end

  test "caches the level in Memcached" do
    @creator.stub(:sales_cents_total, 0) do
      @creator.mailer_level
    end
    assert_equal :level_1, Rails.cache.read("creator_mailer_level_#{@creator.id}")
  end
end
