module BitcoinActiveRecord::Models::BtcAddress
  extend ActiveSupport::Concern

  included do
    has_many(:payments, inverse_of: :btc_address)
    has_many(:received_payments, inverse_of: :btc_address)

    validates(:public_key, presence: true, uniqueness: { case_sensitive: true })

    auto_strip_attributes(:public_key)
  end
end
