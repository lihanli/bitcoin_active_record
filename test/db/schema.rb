# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150429175618) do

  create_table "bitcoin_transactions", force: :cascade do |t|
    t.integer  "btc_address_id", null: false
    t.decimal  "amount",         null: false
    t.string   "txid",           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bitcoin_transactions", ["btc_address_id"], name: "index_bitcoin_transactions_on_btc_address_id"
  add_index "bitcoin_transactions", ["txid"], name: "index_bitcoin_transactions_on_txid", unique: true

  create_table "btc_addresses", force: :cascade do |t|
    t.string   "public_key", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "btc_addresses", ["public_key"], name: "index_btc_addresses_on_public_key", unique: true

  create_table "received_bitcoin_transactions", force: :cascade do |t|
    t.integer  "bitcoin_transaction_id", null: false
    t.integer  "btc_address_id",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "received_bitcoin_transactions", ["bitcoin_transaction_id"], name: "index_received_bitcoin_transactions_on_bitcoin_transaction_id", unique: true
  add_index "received_bitcoin_transactions", ["btc_address_id"], name: "index_received_bitcoin_transactions_on_btc_address_id"

  create_table "sent_bitcoin_transactions", force: :cascade do |t|
    t.integer  "bitcoin_transaction_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sent_bitcoin_transactions", ["bitcoin_transaction_id"], name: "index_sent_bitcoin_transactions_on_bitcoin_transaction_id", unique: true

end
