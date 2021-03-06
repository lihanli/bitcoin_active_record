require 'test_helper'

class BitcoinActiveRecordGeneratorsTest < ActiveSupport::TestCase
  def setup
    # backup old files
    @model_files = `ls app/models/*.rb`.split("\n")
    @model_files.each do |filename|
      system("mv #{filename} #{filename}.bak")
    end

    # run generator
    system('bin/rails g bitcoin_active_record:install')

    @migration_file = 'db/migrate/' + `ls db/migrate`.split("\n").find_all do |filename|
      filename.include?('create_bitcoin_active_record_models')
    end[0]
  end

  def test_install_generator
    lambda do
      migration_file_text = "class CreateBitcoinActiveRecordModels < ActiveRecord::Migration\n  def change\n    create_table \"bitcoin_transactions\" do |t|\n      t.integer \"btc_address_id\", null: false\n      t.decimal \"amount\",         null: false\n      t.string  \"txid\",           null: false\n      t.timestamps\n    end\n    add_index \"bitcoin_transactions\", [\"btc_address_id\"]\n    add_index \"bitcoin_transactions\", [\"txid\"], unique: true\n\n    create_table \"btc_addresses\" do |t|\n      t.string  \"public_key\", null: false\n      t.timestamps\n    end\n    add_index \"btc_addresses\", [\"public_key\"], unique: true\n\n    create_table \"received_bitcoin_transactions\" do |t|\n      t.integer \"bitcoin_transaction_id\", null: false\n      t.integer \"btc_address_id\", null: false\n      t.timestamps\n    end\n    add_index :received_bitcoin_transactions, :bitcoin_transaction_id, unique: true\n    add_index :received_bitcoin_transactions, :btc_address_id\n\n    create_table \"sent_bitcoin_transactions\" do |t|\n      t.integer \"bitcoin_transaction_id\", null: false\n      t.timestamps\n    end\n    add_index \"sent_bitcoin_transactions\", [\"bitcoin_transaction_id\"], unique: true\n  end\nend\n"
      assert_equal(migration_file_text, File.read(@migration_file))
    end.()

    %w(btc_address bitcoin_transaction received_bitcoin_transaction sent_bitcoin_transaction).each do |model_name|
      camel_case_model_name = model_name.camelize
      filename = "app/models/#{model_name}.rb"

      assert_equal("class #{camel_case_model_name} < ActiveRecord::Base\n  bitcoin_active_record_model\nend\n", File.read(filename))
    end
  end

  def teardown
    @model_files.each do |filename|
      system("rm #{filename}") if File.exists?(filename)
      system("mv #{filename}.bak #{filename}")
    end
  end
end
