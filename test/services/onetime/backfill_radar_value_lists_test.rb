# frozen_string_literal: true

require "test_helper"

class OnetimeBackfillRadarValueListsTest < ActiveSupport::TestCase
  setup do
    @value_list = Object.new
    @value_list.define_singleton_method(:id) { "rsl_123" }
    @retrieve_proc = ->(_id) { @value_list }
  end

  def with_stripe_stubs(create_proc: nil, &blk)
    create_proc ||= ->(_args) {}
    Stripe::Radar::ValueList.stub(:retrieve, @retrieve_proc) do
      Stripe::Radar::ValueListItem.stub(:create, ->(args) { create_proc.call(args) }) do
        yield
      end
    end
  end

  test "pushes all active blocked emails and cards regardless of date" do
    travel_to 1.year.ago do
      PlatformBlock.add!(object_type: PlatformBlock::TYPES[:email], object_value: "old@example.com")
      PlatformBlock.add!(object_type: PlatformBlock::TYPES[:charge_processor_fingerprint], object_value: "fpold")
    end

    calls = []
    with_stripe_stubs(create_proc: ->(args) { calls << args }) do
      Onetime::BackfillRadarValueLists.process
    end

    assert_includes calls, { value_list: "rsl_123", value: "old@example.com" }
    assert_includes calls, { value_list: "rsl_123", value: "fpold" }
  end

  test "skips unblocked entries" do
    blocked = PlatformBlock.add!(object_type: PlatformBlock::TYPES[:email], object_value: "unblocked@example.com")
    blocked.unblock!

    calls = []
    with_stripe_stubs(create_proc: ->(args) { calls << args }) do
      Onetime::BackfillRadarValueLists.process
    end

    refute calls.any? { |c| c[:value] == "unblocked@example.com" }
  end

  test "processes entries in batches" do
    3.times { |i| PlatformBlock.add!(object_type: PlatformBlock::TYPES[:email], object_value: "buyer-#{i}@example.com") }

    output = with_stripe_stubs { capture_io { Onetime::BackfillRadarValueLists.process(batch_size: 2) }.first }
    assert_match(/Radar email backfill: 2 pushed/, output)
    assert_match(/Radar email backfill: 3 pushed/, output)
  end

  test "ignores duplicate item errors" do
    PlatformBlock.add!(object_type: PlatformBlock::TYPES[:email], object_value: "dup@example.com")
    create_proc = ->(_args) do
      raise Stripe::InvalidRequestError.new("This value already exists", "value", code: "value_list_item_already_exists")
    end
    assert_nothing_raised do
      with_stripe_stubs(create_proc: create_proc) do
        Onetime::BackfillRadarValueLists.process
      end
    end
  end
end
