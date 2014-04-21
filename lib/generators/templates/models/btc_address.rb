class BtcAddress < ActiveRecord::Base
  setup_model(self.name.underscore)
end
