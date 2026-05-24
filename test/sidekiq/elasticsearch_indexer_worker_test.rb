# frozen_string_literal: true

require "test_helper"

# TODO: Migrate from RSpec. Skip-batched during the bulk fixtures-only migration.
# Original: spec/sidekiq/elasticsearch_indexer_worker_spec.rb (0 FactoryBot refs, 353 lines).
#
# Blocker for batch B backfill: Despite 0 FB refs, every test defines anonymous classes (`class TravelEvent; include Elasticsearch::Model; ...end`) and runs real `EsClient.indices.delete / index / search / get / update / delete_by_query` against a live ES cluster. The Minitest lane's global EsClient fake returns `{"hits"=>...,"count"=>0}` with no aggregation/index-management plumbing. Migrating requires either (a) a real ES cluster in CI, or (b) a fully-fledged Elasticsearch::Transport mock harness — both outside backfill scope.
class ElasticsearchIndexerWorkerTest < ActiveSupport::TestCase
  test "TODO: migrate from RSpec — fixture-hostile, requires manual rewrite" do
    skip "TODO: migrate spec/sidekiq/elasticsearch_indexer_worker_spec.rb — Despite 0 FB refs, every test defines anonymous classes (`class TravelEvent; include Elasticsearch::Model; ...end`) and runs real `EsClient.indices.delete / index / search / get / update / delete_by_query` against a live ES cluster. The Minitest lane's global EsClient fake returns `{'hits'=>...,'count'=>0}` with no aggregation/index-management p..."
  end
end
