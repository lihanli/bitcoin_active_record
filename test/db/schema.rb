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

ActiveRecord::Schema.define(version: 20140419032843) do

  create_table "btc_addresses", force: true do |t|
    t.string "public_key", null: false
  end

  add_index "btc_addresses", ["public_key"], name: "index_btc_addresses_on_public_key", unique: true

  create_table "payments", force: true do |t|
    t.integer "btc_address_id", null: false
    t.decimal "amount",         null: false
    t.string  "txid",           null: false
  end

  add_index "payments", ["btc_address_id"], name: "index_payments_on_btc_address_id"
  add_index "payments", ["txid"], name: "index_payments_on_txid", unique: true

  create_table "received_payments", force: true do |t|
    t.integer "payment_id", null: false
  end

  add_index "received_payments", ["payment_id"], name: "index_received_payments_on_payment_id", unique: true

  create_table "sent_payments", force: true do |t|
    t.integer "payment_id", null: false
  end

  add_index "sent_payments", ["payment_id"], name: "index_sent_payments_on_payment_id", unique: true

end
