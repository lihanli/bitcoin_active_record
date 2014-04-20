require('active_support/dependencies')
require('httparty')
require('bigdecimal')

module BitcoinPayments
  module_function

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

  def setup_model
    file = __FILE__
    binding.pry; raise
  end
end

require('bitcoin_payments/client')
