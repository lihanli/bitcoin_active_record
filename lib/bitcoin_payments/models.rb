module BitcoinPayments
  module Models
    def setup_model(name)
      include "BitcoinPayments::Models::#{name.camelize}".constantize
    end
  end
end

ActiveRecord::Base.extend(BitcoinPayments::Models)