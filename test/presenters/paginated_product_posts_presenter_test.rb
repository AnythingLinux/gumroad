# frozen_string_literal: true

require "test_helper"

class PaginatedProductPostsPresenterTest < ActiveSupport::TestCase
  setup do
    @product = links(:ppp_presenter_product)
    @seller_post = installments(:ppp_presenter_seller_post)
    @workflow_post = installments(:ppp_presenter_workflow_post)
    @rule = installment_rules(:ppp_presenter_workflow_rule)
    PaginatedProductPostsPresenter.send(:remove_const, :PER_PAGE) if PaginatedProductPostsPresenter.const_defined?(:PER_PAGE, false)
    PaginatedProductPostsPresenter.const_set(:PER_PAGE, 1)
  end

  teardown do
    PaginatedProductPostsPresenter.send(:remove_const, :PER_PAGE) if PaginatedProductPostsPresenter.const_defined?(:PER_PAGE, false)
    PaginatedProductPostsPresenter.const_set(:PER_PAGE, 10)
  end

  def presenter(options: {})
    PaginatedProductPostsPresenter.new(product: @product, variant_external_id: nil, options:)
  end

  test "#index_props returns first page of paginated posts (workflow-rule date first)" do
    result = presenter.index_props
    assert_equal 2, result[:total]
    assert_equal 2, result[:next_page]
    assert_equal 1, result[:posts].size

    post = result[:posts].first
    assert_equal @workflow_post.external_id, post[:id]
    assert_equal @workflow_post.name, post[:name]
    assert_equal({ type: "workflow_email_rule", time_duration: @rule.displayable_time_duration, time_period: @rule.time_period }, post[:date])
    assert_equal @workflow_post.full_url, post[:url]
  end

  test "#index_props returns the second page (seller post, plain date)" do
    result = presenter(options: { page: 2 }).index_props
    assert_equal 2, result[:total]
    assert_nil result[:next_page]
    assert_equal 1, result[:posts].size

    post = result[:posts].first
    assert_equal @seller_post.external_id, post[:id]
    assert_equal @seller_post.name, post[:name]
    assert_equal({ type: "date", value: @seller_post.published_at }, post[:date])
    assert_equal @seller_post.full_url, post[:url]
  end

  test "#index_props raises Pagy::OverflowError when requested page exceeds total" do
    assert_raises(Pagy::OverflowError) do
      presenter(options: { page: 3 }).index_props
    end
  end
end
