# frozen_string_literal: true

require "test_helper"

class OnetimeBackfillPriceCheckerIndexFieldsTest < ActiveSupport::TestCase
  test ".process scrolls Link.index_name and enqueues SendToElasticsearchWorker for each hit" do
    scroll_id_1 = "scroll-id-1"
    scroll_id_2 = "scroll-id-2"
    initial_hits = [{ "_id" => "11" }, { "_id" => "12" }]

    search_calls = []
    scroll_calls = []
    clear_calls = []
    push_bulk_calls = []

    search_proc = ->(args) { search_calls << args; { "hits" => { "hits" => initial_hits }, "_scroll_id" => scroll_id_1 } }
    scroll_proc = ->(args) { scroll_calls << args; { "hits" => { "hits" => [] }, "_scroll_id" => scroll_id_2 } }
    clear_proc  = ->(args) { clear_calls << args; nil }

    EsClient.stub(:search, search_proc) do
      EsClient.stub(:scroll, scroll_proc) do
        EsClient.stub(:clear_scroll, clear_proc) do
          Sidekiq::Client.stub(:push_bulk, ->(args) { push_bulk_calls << args; nil }) do
            Onetime::BackfillPriceCheckerIndexFields.process
          end
        end
      end
    end

    assert_equal Link.index_name, search_calls.first[:index]
    assert_equal "1m", search_calls.first[:scroll]
    assert_equal({ query: { match_all: {} } }, search_calls.first[:body])
    assert_equal Onetime::BackfillPriceCheckerIndexFields::SCROLL_SIZE, search_calls.first[:size]

    assert_equal 1, push_bulk_calls.size
    pb = push_bulk_calls.first
    assert_equal SendToElasticsearchWorker, pb["class"]
    assert_equal "low", pb["queue"]
    attrs = Onetime::BackfillPriceCheckerIndexFields::ATTRIBUTES_TO_UPDATE
    assert_equal [[11, "update", attrs], [12, "update", attrs]], pb["args"]

    assert_equal [{ scroll_id: scroll_id_2 }], clear_calls
  end
end
