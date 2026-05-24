# frozen_string_literal: true

require "test_helper"

class InstallmentScopesTest < ActiveSupport::TestCase
  setup do
    @seller = users(:installment_scopes_seller)
    @scoped = Installment.where(seller_id: @seller.id)
  end

  test ".shown_on_profile returns installments shown on profile" do
    results = @scoped.shown_on_profile
    assert_equal 2, results.count
    assert_includes results, installments(:inst_scopes_shown_no_email)
    assert_includes results, installments(:inst_scopes_shown_with_email)
  end

  test ".profile_only returns installments shown only on profile (no email)" do
    results = @scoped.profile_only
    assert_equal 1, results.count
    assert_includes results, installments(:inst_scopes_shown_no_email)
  end

  test ".published returns published installments" do
    results = @scoped.published
    assert_includes results, installments(:inst_scopes_published)
    assert_not_includes results, installments(:inst_scopes_draft)
    assert_not_includes results, installments(:inst_scopes_scheduled)
  end

  test ".not_published returns unpublished installments" do
    results = @scoped.not_published
    assert_includes results, installments(:inst_scopes_draft)
    assert_includes results, installments(:inst_scopes_scheduled)
    assert_not_includes results, installments(:inst_scopes_published)
  end

  test ".scheduled returns scheduled installments" do
    results = @scoped.scheduled
    assert_includes results, installments(:inst_scopes_scheduled)
    assert_not_includes results, installments(:inst_scopes_published)
    assert_not_includes results, installments(:inst_scopes_draft)
  end

  test ".draft returns draft installments" do
    results = @scoped.draft
    assert_includes results, installments(:inst_scopes_draft)
    assert_not_includes results, installments(:inst_scopes_published)
    assert_not_includes results, installments(:inst_scopes_scheduled)
  end
end
