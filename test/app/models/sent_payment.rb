class SentPayment < ActiveRecord::Base
  bitcoin_payments_model(payment_sending_model: 'BettingRound')
end
