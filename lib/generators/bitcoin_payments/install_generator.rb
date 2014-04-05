require 'rails/generators/base'

module BitcoinPayments
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root(File.expand_path("../../templates", __FILE__))

      desc("Creates a Bitcoin Payments initializer")

      def copy_initializer
        template('bitcoin_payments.rb', 'config/initializers/bitcoin_payments.rb')
      end
    end
  end
end