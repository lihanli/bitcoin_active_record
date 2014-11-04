class AddBetAndBettingRoundTables < ActiveRecord::Migration
  def change
    create_table "bets" do |t|
      t.integer "btc_address_id", null: false
    end
    add_index "bets", ["btc_address_id"]

    create_table 'betting_rounds' do |t|
      t.boolean('paid', default: false, null: false)
    end
  end
end
