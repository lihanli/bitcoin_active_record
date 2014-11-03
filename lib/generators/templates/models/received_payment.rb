class ReceivedPayment < ActiveRecord::Base
  bitcoin_payments_model(payment_receiving_model: 'ModelName')
end
