require('active_support/dependencies')
require('httparty')
require('bigdecimal')

module BitcoinPayments
  module_function

  mattr_accessor(:server)
  @@server = {
    url: nil,
    username: nil,
    password: nil,
  }

  mattr_accessor(:minimum_amount)
  @@minimum_amount = BigDecimal.new('0.001')

  mattr_accessor(:default_transaction_count)
  @@default_transaction_count = 25

  mattr_accessor(:default_account)
  @@default_account = ''

  def setup
    yield(self)
  end
end

require('bitcoin_payments/client')
