class SentPayment < ActiveRecord::Base
  BitcoinPayments.setup_model(self.name.underscore)
end