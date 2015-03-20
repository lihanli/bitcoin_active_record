module BitcoinPayments
  module Models
    def bitcoin_payments_model
      include "BitcoinPayments::Models::#{self}".constantize
    end
  end
end

ActiveRecord::Base.extend(BitcoinPayments::Models)