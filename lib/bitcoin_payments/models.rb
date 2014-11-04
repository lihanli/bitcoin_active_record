module BitcoinPayments
  module Models
    def bitcoin_payments_model(payment_receiving_model: nil, payment_sending_model: nil)
      include "BitcoinPayments::Models::#{self}".constantize

      %w(payment_receiving_model payment_sending_model).each do |type|
        model_name = eval(type)

        model_name.constantize.include("BitcoinPayments::Models::#{type.camelize}".constantize) if model_name.present?
      end
    end
  end
end

ActiveRecord::Base.extend(BitcoinPayments::Models)