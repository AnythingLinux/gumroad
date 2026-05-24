require "test_helper"

# TODO: Migrate from RSpec. Purchase::Receipt spec needs charges, customer_email_infos,
# gifts, url_redirects, product_files (pdf), plus stampable-pdf ActiveStorage
# attachments and Sidekiq job enqueue assertions across CustomerMailer /
# CustomerLowPriorityMailer / SendPdfStampingMailerJob. Out of scope for
# mechanical model backfill.
#
# Original spec: spec/models/concerns/purchase/receipt_spec.rb
class Purchase::ReceiptTest < ActiveSupport::TestCase
  test "TODO: migrate Purchase::Receipt spec" do
    skip "Needs many new fixture tables (charges, customer_email_infos, gifts, url_redirects, product_files w/ pdf) plus stampable-pdf ActiveStorage attachments + Sidekiq job enqueue assertions. Out of scope for mechanical model backfill."
  end
end
