# frozen_string_literal: true

require "spec_helper"

describe PrewarmBuyerLocalCurrencyRateJob do
  it "delegates to the helper's synchronous refresh path" do
    job = described_class.new
    expect(job).to receive(:refresh_buyer_local_currency_rate!).with(from_currency: "usd", to_currency: "eur")
    job.perform("usd", "eur")
  end
end
