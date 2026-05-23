# frozen_string_literal: true

require "test_helper"

class AccountingMailerTest < ActionMailer::TestCase
  # vat_report
  test "vat_report has the s3 link in the body" do
    mail = AccountingMailer.vat_report(3, 2015, "https://test_vat_link.at.s3")
    assert_includes mail.body.to_s, "VAT report Link: https://test_vat_link.at.s3"
  end

  test "vat_report subject indicates quarter and year" do
    mail = AccountingMailer.vat_report(3, 2015, "https://test_vat_link.at.s3")
    assert_equal "VAT report for Q3 2015", mail.subject
  end

  test "vat_report is sent to the team" do
    mail = AccountingMailer.vat_report(3, 2015, "https://test_vat_link.at.s3")
    assert_equal [ApplicationMailer::PAYMENTS_EMAIL], mail.to
  end

  # gst_report
  test "gst_report has the s3 link in the body" do
    mail = AccountingMailer.gst_report("AU", 3, 2015, "https://test_vat_link.at.s3")
    assert_includes mail.body.to_s, "GST report Link: https://test_vat_link.at.s3"
  end

  test "gst_report subject indicates quarter and year" do
    mail = AccountingMailer.gst_report("AU", 3, 2015, "https://test_vat_link.at.s3")
    assert_equal "Australia GST report for Q3 2015", mail.subject
  end

  test "gst_report is sent to the team" do
    mail = AccountingMailer.gst_report("AU", 3, 2015, "https://test_vat_link.at.s3")
    assert_equal [ApplicationMailer::PAYMENTS_EMAIL], mail.to
  end

  # funds_received_report
  test "funds_received_report attaches CSV and renders header text" do
    last_month = Time.current.last_month
    mail = AccountingMailer.funds_received_report(last_month.month, last_month.year)
    assert_equal 2, mail.body.parts.size
    assert_equal(
      ["text/html; charset=UTF-8", "text/csv; filename=funds-received-report-#{last_month.month}-#{last_month.year}.csv"].sort,
      mail.body.parts.map(&:content_type).sort
    )
    html = mail.body.parts.find { |p| p.content_type.include?("html") }.body
    assert_includes html.to_s, "Funds Received Report"
    assert_includes html.to_s, "Sales"
    assert_includes html.to_s, "total_transaction_cents"
  end

  # deferred_refunds_report
  test "deferred_refunds_report attaches CSV and renders header text" do
    last_month = Time.current.last_month
    mail = AccountingMailer.deferred_refunds_report(last_month.month, last_month.year)
    assert_equal 2, mail.body.parts.size
    assert_equal(
      ["text/html; charset=UTF-8", "text/csv; filename=deferred-refunds-report-#{last_month.month}-#{last_month.year}.csv"].sort,
      mail.body.parts.map(&:content_type).sort
    )
    html = mail.body.parts.find { |p| p.content_type.include?("html") }.body
    assert_includes html.to_s, "Deferred Refunds Report"
    assert_includes html.to_s, "Sales"
    assert_includes html.to_s, "total_transaction_cents"
  end

  # stripe_currency_balances_report
  test "stripe_currency_balances_report attaches CSV" do
    last_month = Time.current.last_month
    balances_csv = "Currency,Balance\nusd,997811.63\n"
    mail = AccountingMailer.stripe_currency_balances_report(balances_csv)
    assert_equal 2, mail.body.parts.size
    assert_equal(
      ["text/html; charset=UTF-8", "text/csv; filename=stripe_currency_balances_#{last_month.month}_#{last_month.year}.csv"].sort,
      mail.body.parts.map(&:content_type).sort
    )
    html = mail.body.parts.find { |p| p.content_type.include?("html") }.body
    assert_includes html.to_s, "Stripe currency balances CSV is attached."
    assert_includes html.to_s, "These are the currency balances for Gumroad's Stripe platform account."
  end

  # us_states_sales_summary_report_failed
  test "us_states_sales_summary_report_failed sends to payments notification email" do
    mail = AccountingMailer.us_states_sales_summary_report_failed(
      ["WA", "WI"], 4, 2026, "ActiveRecord::StatementTimeout", "maximum statement execution time exceeded"
    )
    assert_equal [PAYMENTS_NOTIFICATION_EMAIL], mail.to
  end

  test "us_states_sales_summary_report_failed subject includes period" do
    mail = AccountingMailer.us_states_sales_summary_report_failed(
      ["WA", "WI"], 4, 2026, "ActiveRecord::StatementTimeout", "maximum statement execution time exceeded"
    )
    assert_includes mail.subject, "US States Sales Summary Report failed - 4/2026"
    refute_includes mail.subject, "[TaxJar]"
  end

  test "us_states_sales_summary_report_failed tags TaxJar errors" do
    mail = AccountingMailer.us_states_sales_summary_report_failed(
      ["WA", "WI"], 4, 2026, "Taxjar::Error::ServerError", "Couldn't parse response as JSON."
    )
    assert_includes mail.subject, "[TaxJar] US States Sales Summary Report failed - 4/2026"
  end

  test "us_states_sales_summary_report_failed body contains context" do
    mail = AccountingMailer.us_states_sales_summary_report_failed(
      ["WA", "WI"], 4, 2026, "ActiveRecord::StatementTimeout", "maximum statement execution time exceeded"
    )
    body = mail.body.encoded
    assert_includes body, "4/2026"
    assert_includes body, "WA, WI"
    assert_includes body, "ActiveRecord::StatementTimeout"
    assert_includes body, "maximum statement execution time exceeded"
  end

  # ytd_sales_report
  test "ytd_sales_report sends email to correct recipient with subject and CSV attachment" do
    csv_data = "country,state,sales\\nUSA,CA,100\\nUSA,NY,200"
    recipient_email = "test@example.com"
    mail = AccountingMailer.ytd_sales_report(csv_data, recipient_email)

    assert_equal [recipient_email], mail.to
    assert_equal "Year-to-Date Sales Report by Country/State", mail.subject
    assert_equal 1, mail.attachments.length
    attachment = mail.attachments[0]
    assert_equal "ytd_sales_by_country_state.csv", attachment.filename
    assert_equal "text/csv; filename=ytd_sales_by_country_state.csv", attachment.content_type
    assert_equal csv_data, Base64.decode64(attachment.body.encoded)
  end
end
