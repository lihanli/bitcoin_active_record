require 'test_helper'

class BitcoinPaymentsGeneratorsTest < ActiveSupport::TestCase
  def model_files
    `ls app/models/*.rb`.split("\n")
  end

  def setup
    # backup old files
    @initializer_file = 'config/initializers/bitcoin_payments.rb'
    system("mv #{@initializer_file} #{@initializer_file}.bak")

    model_files.each do |filename|
      system("mv #{filename} #{filename}.bak")
    end

    # run generator
    system('bundle exec rails g bitcoin_payments:install')
    @migration_file = "db/migrate/#{`ls db/migrate`.split("\n").last}"
  end

  def test_install_generator
    lambda do
      config_file_text = "BitcoinPayments.setup do |config|\n  config.server[:url] = 'http://127.0.0.1:8332'\n  config.server[:username] = ''\n  config.server[:password] = ''\nend"
      assert_equal(config_file_text, `cat #{@initializer_file}`)
    end.()

    lambda do
      migration_file_text = "class CreateBitcoinPaymentsModels < ActiveRecord::Migration\n  def change\n    create_table \"payments\" do |t|\n      t.integer \"btc_address_id\", null: false\n      t.decimal \"amount\",         null: false\n      t.string  \"txid\",           null: false\n    end\n    add_index \"payments\", [\"btc_address_id\"]\n    add_index \"payments\", [\"txid\"], unique: true\n\n    create_table \"btc_addresses\" do |t|\n      t.string  \"public_key\", null: false\n    end\n    add_index \"btc_addresses\", [\"public_key\"], unique: true\n\n    create_table \"received_payments\" do |t|\n      t.integer \"payment_id\", null: false\n    end\n    add_index \"received_payments\", [\"payment_id\"], unique: true\n\n    create_table \"sent_payments\" do |t|\n      t.integer \"payment_id\", null: false\n    end\n    add_index \"sent_payments\", [\"payment_id\"], unique: true\n  end\nend\n"
      assert_equal(migration_file_text, `cat #{@migration_file}`)
    end.()

    assert_equal(4, model_files.tap do |files|
      files.each do |filename|
        camel_case_model_name = `basename #{filename}`.gsub(".rb\n", '').camelize
        args = if camel_case_model_name == 'ReceivedPayment'
          "(payment_receiving_model: 'ModelName')"
        elsif camel_case_model_name == 'SentPayment'
          "(payment_sending_model: 'ModelName')"
        else
          ''
        end

        assert_equal("class #{camel_case_model_name} < ActiveRecord::Base\n  bitcoin_payments_model#{args}\nend\n", `cat #{filename}`)
      end
    end.size)
  end

  def teardown
    system("rm #{@initializer_file}")
    system("rm #{@migration_file}")
    system("mv #{@initializer_file}.bak #{@initializer_file}")

    model_files.each do |filename|
      system("rm #{filename}")
      system("mv #{filename}.bak #{filename}")
    end
  end
end
