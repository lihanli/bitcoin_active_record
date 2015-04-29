class CreateBitcoinActiveRecordModels < ActiveRecord::Migration
  def change
    create_table "bitcoin_transactions" do |t|
      t.integer "btc_address_id", null: false
      t.decimal "amount",         null: false
      t.string  "txid",           null: false
      t.timestamps
    end
    add_index "bitcoin_transactions", ["btc_address_id"]
    add_index "bitcoin_transactions", ["txid"], unique: true

    create_table "btc_addresses" do |t|
      t.string  "public_key", null: false
      t.timestamps
    end
    add_index "btc_addresses", ["public_key"], unique: true

    create_table "received_bitcoin_transactions" do |t|
      t.integer "bitcoin_transaction_id", null: false
      t.integer "btc_address_id", null: false
      t.timestamps
    end
    add_index :received_bitcoin_transactions, :bitcoin_transaction_id, unique: true
    add_index :received_bitcoin_transactions, :btc_address_id

    create_table "sent_bitcoin_transactions" do |t|
      t.integer "bitcoin_transaction_id", null: false
      t.timestamps
    end
    add_index "sent_bitcoin_transactions", ["bitcoin_transaction_id"], unique: true
  end
end
