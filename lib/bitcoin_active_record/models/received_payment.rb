module BitcoinActiveRecord::Models::ReceivedPayment
  extend ActiveSupport::Concern

  included do
    belongs_to(:payment, inverse_of: :received_payment, dependent: :destroy)
    belongs_to(:btc_address, inverse_of: :received_payments) # payment to this address

    validates(:payment, presence: true)
    validates(:payment_id, uniqueness: true)
  end
end
