module BitcoinPayments::Models::BtcAddress
  extend ActiveSupport::Concern

  included do
    belongs_to(:user, inverse_of: :btc_addresses)

    has_many(:payments, inverse_of: :btc_address)

    validates(:public_key, presence: true, uniqueness: { case_sensitive: true })

    before_validation do
      if public_key.blank?
        self.public_key = BitcoinHelper.get_new_address
      end
    end
  end
end
