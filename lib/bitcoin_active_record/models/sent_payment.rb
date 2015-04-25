module BitcoinActiveRecord::Models::SentPayment
  extend ActiveSupport::Concern

  included do
    belongs_to(:payment, inverse_of: :sent_payment, dependent: :destroy)

    validates(:payment, presence: true)
    validates(:payment_id, uniqueness: true)
  end
end
