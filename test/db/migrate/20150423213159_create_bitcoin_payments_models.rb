class CreateBitcoinPaymentsModels < ActiveRecord::Migration
  def change
    create_table "payments" do |t|
      t.integer "btc_address_id", null: false
      t.decimal "amount",         null: false
      t.string  "txid",           null: false
      t.timestamps
    end
    add_index "payments", ["btc_address_id"]
    add_index "payments", ["txid"], unique: true

    create_table "btc_addresses" do |t|
      t.string  "public_key", null: false
      t.timestamps
    end
    add_index "btc_addresses", ["public_key"], unique: true

    create_table "received_payments" do |t|
      t.integer "payment_id", null: false
      t.integer "btc_address_id", null: false
      t.timestamps
    end
    add_index "received_payments", ["payment_id"], unique: true
    add_index :received_payments, :btc_address_id

    create_table "sent_payments" do |t|
      t.integer "payment_id", null: false
      t.timestamps
    end
    add_index "sent_payments", ["payment_id"], unique: true
  end
end