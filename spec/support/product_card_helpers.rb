# frozen_string_literal: true

module ProductCardHelpers
  def find_product_card(product)
    page.find("article", text: product.name, visible: :visible)
  end

  def expect_product_cards_in_order(products)
    expect(page).to have_product_card(count: products.length)
    products.each_with_index do |product, index|
      expect(page).to have_selector("article:nth-of-type(#{index + 1})", text: product.name, visible: :visible)
    end
  end

  def expect_product_cards_with_names(*product_names)
    expect(page).to have_product_card(count: product_names.length)
    product_names.each do |product_name|
      expect(page).to have_selector("article", text: product_name, visible: :visible)
    end
  end
end

module Capybara
  module RSpecMatchers
    def have_product_card(product = nil, **rest)
      rest[:visible] = :visible unless rest.key?(:visible)
      have_selector("article header", text: product&.name, **rest)
    end
  end
end
