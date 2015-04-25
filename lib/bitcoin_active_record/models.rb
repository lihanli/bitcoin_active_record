module BitcoinActiveRecord
  module Models
    def bitcoin_active_record_model
      include "BitcoinActiveRecord::Models::#{self}".constantize
    end
  end
end

ActiveRecord::Base.extend(BitcoinActiveRecord::Models)