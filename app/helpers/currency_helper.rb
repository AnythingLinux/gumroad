# frozen_string_literal: true

module CurrencyHelper
  include BasePrice::Recurrence
  # Note: To reference a currency in code, use Currency::[3-char-ref].
  # e.g. Currency::USD, Currency::CAD
  class CurrencyRateUnavailable < StandardError; end

  RATE_CACHE_TTL = 1.hour
  MAX_STALE_RATE_AGE = 24.hours
  UNSUPPORTED_RATE = "unsupported"

  def currency_namespace
    Redis::Namespace.new(:currencies, redis: $redis)
  end

  def symbol_for(type = :usd)
    currency = CURRENCY_CHOICES[type.to_sym] || CURRENCY_CHOICES[:usd]
    currency[:symbol]
  end

  def min_price_for(type = :usd)
    currency = CURRENCY_CHOICES[type.to_sym] || CURRENCY_CHOICES[:usd]
    currency[:min_price]
  end

  def currency_choices
    CURRENCY_CHOICES.map { |k, v| [v[:display_format], k, v[:symbol]] }
  end

  def string_to_price_cents(currency_type, price_string)
    sanitized = price_string.to_s.delete(",")
    if sanitized.count(".") > 1
      first_dot = sanitized.index(".")
      sanitized = sanitized[0..first_dot] + sanitized[(first_dot + 1)..].delete(".")
    end
    sanitized = "0" unless sanitized.match?(/\d/)
    (BigDecimal(sanitized.presence || 0) * (is_currency_type_single_unit?(currency_type) ? 1 : 100)).round
  end

  def query_rate(currency_type)
    rate = JSON.parse(URI.open(CURRENCY_SOURCE).read)["rates"][currency_type.to_s.upcase]
    rate.present? && rate.to_f.positive? ? rate : UNSUPPORTED_RATE
  rescue StandardError
    cached_rate(currency_type, allow_stale: true) || raise(CurrencyRateUnavailable, "No exchange rate for #{currency_type}")
  end

  def get_rate(currency_type)
    return "1.0" if currency_type.to_s == "usd" # Getting around an open exchange jankiness
    formatted_currency = currency_type.to_s.upcase
    raise CurrencyRateUnavailable, "Unsupported exchange rate for #{formatted_currency}" if currency_namespace.get(formatted_currency) == UNSUPPORTED_RATE

    rate = cached_rate(formatted_currency)
    return rate.to_f.to_s if rate.present?

    new_rate = query_rate(formatted_currency)
    if new_rate == UNSUPPORTED_RATE
      cache_rate(formatted_currency, UNSUPPORTED_RATE)
      raise CurrencyRateUnavailable, "Unsupported exchange rate for #{formatted_currency}"
    end

    cache_rate(formatted_currency, new_rate)
    new_rate.to_f.to_s
  end

  def get_usd_cents(currency_type, quantity, rate: nil)
    return quantity if currency_type.to_s == "usd" # Getting around an open exchange jankiness
    rate = get_rate(currency_type) if rate.nil?
    converted = BigDecimal(quantity) / rate.to_f
    if is_currency_type_single_unit?(currency_type)
      (converted * 100).round
    else
      converted.round
    end
  end

  # Converts USD cents to desired currency. Providing an optional explicit rate overrides the rate lookup by currency type
  #
  # currency_type - currency type denoted by abbreviated string
  # quantity - amount in USD cents
  # rate - optional. Uses this as the conversion rate instead of looking up by currency_type if present.
  def usd_cents_to_currency(currency_type, quantity, rate = nil)
    return quantity if currency_type.to_s == "usd" # Getting around an open exchange jankiness
    conversion_rate = rate.present? ? rate.to_f : get_rate(currency_type).to_f
    converted = BigDecimal(quantity) * conversion_rate
    if is_currency_type_single_unit?(currency_type)
      (converted / 100).round
    else
      converted.round
    end
  end

  def formatted_dollar_amount(amount_cents, with_currency: false, no_cents_if_whole: true)
    Money.new(amount_cents, "USD").format(with_currency:, no_cents_if_whole:)
  end

  def formatted_amount_in_currency(amount_cents, currency, no_cents_if_whole: true)
    Money.new(amount_cents, currency).format(symbol: false, no_cents_if_whole:, with_currency: true)
  end

  def format_just_price_in_cents(amount_cents, currency)
    price = formatted_price(currency, amount_cents)
    price == "$0.99" ? "99¢" : price
  end

  def formatted_price_with_recurrence(formatted_price, recurrence, charge_occurrence_count, format:)
    if recurrence
      formatted_price = \
        if format == :short
          "#{formatted_price} #{recurrence_short_indicator(recurrence)}"
        elsif format == :long
          "#{formatted_price} #{recurrence_long_indicator(recurrence)}"
        end
    end
    formatted_price += " x #{charge_occurrence_count}" if charge_occurrence_count.present?
    formatted_price
  end

  def formatted_price_in_currency_with_recurrence(amount_cents, currency, recurrence, charge_occurrence_count)
    formatted_price = format_just_price_in_cents(amount_cents, currency)
    formatted_price_with_recurrence(formatted_price, recurrence, charge_occurrence_count, format: :long)
  end

  def get_currency_by_type(currency_type)
    CURRENCY_CHOICES[currency_type.to_s.downcase] || CURRENCY_CHOICES["usd"]
  end

  def unit_scaling_factor(currency_type)
    is_currency_type_single_unit?(currency_type) ? 1 : 100
  end

  def cached_rate(currency_type, allow_stale: false)
    raw_rate = currency_namespace.get(currency_type.to_s.upcase)
    return if raw_rate.blank? || raw_rate == UNSUPPORTED_RATE

    cached_rate_entry(raw_rate, allow_stale:) || (raw_rate.to_f if raw_rate.to_f.positive?)
  end

  def cached_rate_entry(raw_rate, allow_stale:)
    entry = JSON.parse(raw_rate)
    return unless entry.is_a?(Hash)
    return if entry["rate"].blank? || entry["rate"].to_f <= 0

    cached_at = Time.zone.at(entry["cached_at"].to_i)
    max_age = allow_stale ? MAX_STALE_RATE_AGE : RATE_CACHE_TTL
    entry["rate"] if cached_at >= max_age.ago
  rescue JSON::ParserError
    nil
  end

  def cache_rate(currency_type, rate)
    payload = if rate == UNSUPPORTED_RATE
      UNSUPPORTED_RATE
    else
      { rate:, cached_at: Time.current.to_i }.to_json
    end
    currency_namespace.setex(currency_type.to_s.upcase, RATE_CACHE_TTL.to_i, payload)
  end

  def is_currency_type_single_unit?(currency_type = "usd")
    get_currency_by_type(currency_type).key?("single_unit")
  end

  def formatted_price(currency_type, price)
    MoneyFormatter.format(price, currency_type.to_s.downcase.to_sym, no_cents_if_whole: true, symbol: true)
  end

  # Should match PriceTag component
  def product_card_formatted_price(price:, currency_code:, is_pay_what_you_want:, recurrence:, duration_in_months:)
    recurrence_label = recurrence_label(recurrence, duration_in_months)
    safe_join(
      [
        formatted_price(currency_code, price),
        (is_pay_what_you_want ? "+" : nil),
        (recurrence_label ? " #{recurrence_label}" : nil),
      ].compact
    )
  end

  # Should match formatRecurrenceWithDuration
  def recurrence_label(recurrence, duration_in_months)
    return if recurrence.blank?
    number_of_months = BasePrice::Recurrence.number_of_months_in_recurrence(recurrence)
    base_formatted_label = recurrence_long_indicator(recurrence)
    return base_formatted_label if duration_in_months.blank?

    "#{base_formatted_label} x #{(duration_in_months / number_of_months).round}"
  end
end
