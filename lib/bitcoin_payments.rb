require('active_support/dependencies')

module BitcoinPayments
  mattr_accessor(:server)
  @@server = {
    url: nil,
    username: nil,
    password: nil,
  }

  def setup
    yield(self)
  end
end

require('bitcoin_payments/client')
