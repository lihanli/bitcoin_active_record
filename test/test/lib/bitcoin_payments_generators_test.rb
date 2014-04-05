require 'test_helper'

class BitcoinPaymentsGeneratorsTest < ActiveSupport::TestCase
  def test_install_generator
    initializer_file = 'config/initializers/bitcoin_payments.rb'
    system("mv #{initializer_file} #{initializer_file}.bak")
    system('bundle exec rails g bitcoin_payments:install')

    lambda do
      config_file_text = "BitcoinPayments.setup do |config|\n  config.server[:url] = 'http://127.0.0.1:8332'\n  config.server[:username] = ''\n  config.server[:password] = ''\nend"
      assert_equal(config_file_text, `cat #{initializer_file}`)
    end.()

    system("rm #{initializer_file}")
    system("mv #{initializer_file}.bak #{initializer_file}")
  end
end
