# frozen_string_literal: true

class CreateChargeBuyerCurrencyAmounts < ActiveRecord::Migration[7.1]
  def change
    create_table :charge_buyer_currency_amounts do |t|
      t.bigint :charge_id, null: false
      t.string :buyer_currency, limit: 3, null: false
      t.bigint :buyer_currency_amount_cents
      t.bigint :buyer_currency_gumroad_amount_cents
      t.decimal :buyer_currency_exchange_rate, precision: 20, scale: 10
      t.timestamps

      t.index :charge_id, unique: true
      t.index :buyer_currency
    end
  end
end
