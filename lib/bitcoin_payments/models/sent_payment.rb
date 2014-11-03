module BitcoinPayments::Models::SentPayment
  extend ActiveSupport::Concern

  included do
    belongs_to(:payment, inverse_of: :sent_payment, autosave: true)
    belongs_to(:bet_type, inverse_of: :sent_payments)

    validates(:payment, :match, :bet_type, presence: true)
    validates(:payment_id, uniqueness: true)
  end
end
