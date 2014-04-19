class BtcAddress < ActiveRecord::Base
  BitcoinPayments.setup_model(self.name.underscore)
end
