require 'active_support/dependencies'
require 'active_support/concern'
require 'httparty'
require 'bigdecimal'
require 'auto_strip_attributes'

module BitcoinPayments
  module_function

  autoload(:Client, 'bitcoin_payments/client')

  module Models
    lambda do
      path_prefix = 'bitcoin_payments/models/'

      Dir["#{File.dirname(__FILE__)}/#{path_prefix}*.rb"].map do |file|
        File.basename(file, '.rb')
      end.each do |file_name|
        autoload(file_name.camelize, "#{path_prefix}#{file_name}")
      end
    end.()
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