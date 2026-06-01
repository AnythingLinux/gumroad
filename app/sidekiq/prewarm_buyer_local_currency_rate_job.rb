# frozen_string_literal: true

# Refreshes the buyer-local currency rate cache out of band. Triggered on cache misses
# from the render path so visitor requests never block on an external HTTP call.
# The render path is stale-while-revalidate: a cache miss serves the previous rate (or
# omits the local price on a cold miss) and enqueues this job to warm the pair.
class PrewarmBuyerLocalCurrencyRateJob
  include Sidekiq::Job
  include CurrencyHelper

  sidekiq_options queue: :default, retry: 3, dead: false, lock: :until_executed, lock_ttl: 60

  def perform(from_currency, to_currency)
    refresh_buyer_local_currency_rate!(from_currency:, to_currency:)
  end
end
