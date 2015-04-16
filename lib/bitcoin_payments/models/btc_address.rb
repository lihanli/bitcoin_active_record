module BitcoinPayments::Models::BtcAddress
  extend ActiveSupport::Concern

  included do
    has_many(:payments, inverse_of: :btc_address)
    has_many(:received_payments, inverse_of: :btc_address)

    validates(:public_key, presence: true, uniqueness: { case_sensitive: true })

    before_validation do
      if public_key.blank?
        self.public_key = BitcoinHelper.get_new_address
      end
    end
  end
end
