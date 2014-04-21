class Payment < ActiveRecord::Base
  setup_model(self.name.underscore)
end
