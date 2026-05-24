# frozen_string_literal: true

module ControllerSellerAuthHelpers
  # Per-test boot: wire devise.mapping and disable CSRF. Safe to call from
  # setup whether or not the test actually signs anyone in.
  def boot_controller_test!
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @orig_protect_against_forgery ||= ActionController::Base.instance_method(:protect_against_forgery?)
    ActionController::Base.define_method(:protect_against_forgery?) { false }
  end

  # Sign in `user` and set `seller` as the active seller. The Sellers::*
  # controllers read `current_seller` from `cookies.encrypted[:current_seller_id]`
  # (see `CurrentSeller#current_seller`), so the session approach used by
  # admin-side controllers does not work here.
  def sign_in_as_seller(user, seller = user)
    boot_controller_test!
    sign_in user
    @request.cookie_jar.encrypted[:current_seller_id] = seller.id
  end

  def restore_protect_against_forgery!
    return unless @orig_protect_against_forgery

    ActionController::Base.define_method(:protect_against_forgery?, @orig_protect_against_forgery)
    @orig_protect_against_forgery = nil
  end
end
