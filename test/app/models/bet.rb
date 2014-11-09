class Bet < ActiveRecord::Base
  include BitcoinPayments::Models::PaymentReceivingModel
end
