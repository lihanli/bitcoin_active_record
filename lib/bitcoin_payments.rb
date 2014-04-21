require 'active_support/dependencies'
require 'active_support/concern'
require 'httparty'
require 'bigdecimal'

module BitcoinPayments
  module_function

  autoload(:Client, 'bitcoin_payments/client')

  module Models
    autoload(:Payment, 'bitcoin_payments/models/payment')
  end

  ZERO = BigDecimal.new(0)

  mattr_accessor(:server) do
    {
      url: nil,
      username: nil,
      password: nil,
    }
  end
  mattr_accessor(:minimum_amount) { BigDecimal.new('0.001') }
  mattr_accessor(:default_transaction_count) { 25 }
  mattr_accessor(:default_account) { '' }

  def setup
    yield(self)
  end
end

require 'bitcoin_payments/models'