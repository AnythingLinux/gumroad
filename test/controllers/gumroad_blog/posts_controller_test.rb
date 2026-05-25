# frozen_string_literal: true

require "test_helper"

class GumroadBlog::PostsControllerTest < ActionController::TestCase
  tests GumroadBlog::PostsController
  include Devise::Test::ControllerHelpers

  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @request.headers["X-Inertia"] = "true"
    @orig_protect = ActionController::Base.instance_method(:protect_against_forgery?)
    ActionController::Base.define_method(:protect_against_forgery?) { false }

    @blog_owner = users(:named_seller)
    @blog_owner.update!(username: "gumroad") unless @blog_owner.username == "gumroad"

    @orig_global = GlobalConfig.method(:get)
    orig = @orig_global
    GlobalConfig.singleton_class.send(:define_method, :get) do |name, *rest|
      next "gumroad" if name == "BLOG_OWNER_USERNAME"
      orig.call(name, *rest)
    end
  end

  teardown do
    ActionController::Base.define_method(:protect_against_forgery?, @orig_protect) if @orig_protect
    GlobalConfig.singleton_class.send(:remove_method, :get)
    GlobalConfig.define_singleton_method(:get, @orig_global) if @orig_global
  end

  def create_installment(name:, published_at:, slug:, shown_on_profile: true)
    inst = Installment.new(
      seller: @blog_owner,
      installment_type: "audience",
      name:, message: "Hello",
      slug:,
      published_at:,
      flags: shown_on_profile ? 128 : 0,
    )
    inst.save!(validate: false)
    inst
  end

  test "GET index renders only visible-on-profile posts ordered by published_at desc" do
    Installment.where(seller: @blog_owner).update_all(deleted_at: Time.current, flags: 0)
    p1 = create_installment(name: "First Blog Post",  published_at: 2.days.ago, slug: "gb-test-first")
    p2 = create_installment(name: "Second Blog Post", published_at: 1.day.ago,  slug: "gb-test-second")
    create_installment(name: "Hidden",       published_at: 3.days.ago, slug: "gb-test-hidden", shown_on_profile: false)
    create_installment(name: "Unpublished",  published_at: nil,        slug: "gb-test-unpub")

    get :index
    assert_response :ok
    page = JSON.parse(@response.body)
    assert_equal "GumroadBlog/Posts/Index", page["component"]
    slugs = page["props"]["posts"].map { |h| h["slug"] }
    assert_equal [p2.slug, p1.slug], slugs
  end

  test "GET show raises RecordNotFound for nonexistent slug" do
    assert_raises(ActiveRecord::RecordNotFound) do
      get :show, params: { slug: "nonexistent-slug-#{SecureRandom.hex(4)}" }
    end
  end

  test "GET show raises RecordNotFound for a post belonging to a different user" do
    other_user = users(:basic_user)
    inst = Installment.new(
      seller: other_user, installment_type: "audience",
      name: "Other", message: "Hello",
      slug: "gb-other-#{SecureRandom.hex(4)}",
      published_at: 1.day.ago, flags: 128,
    )
    inst.save!(validate: false)
    assert_raises(ActiveRecord::RecordNotFound) do
      get :show, params: { slug: inst.slug }
    end
  end
end
