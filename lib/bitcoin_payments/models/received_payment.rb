module BitcoinPayments::Models::ReceivedPayment
  extend ActiveSupport::Concern

  included do
    belongs_to(:payment, inverse_of: :received_payment, dependent: :destroy)
    belongs_to(:btc_address, inverse_of: :received_payments) # payment to this address

    validates(:payment, presence: true)
    validates(:payment_id, uniqueness: true)
    validates(:amount, numericality: { greater_than_or_equal_to: BitcoinPayments.minimum_amount })

    delegate(:amount, to: :payment)
  end
end
