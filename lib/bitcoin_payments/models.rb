module BitcoinPayments
  module Models
    def bitcoin_payments_model(payment_receiving_model: nil, payment_sending_model: nil)
      include "BitcoinPayments::Models::#{self}".constantize
    end
  end
end

ActiveRecord::Base.extend(BitcoinPayments::Models)