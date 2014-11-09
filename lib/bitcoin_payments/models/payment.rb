module BitcoinPayments::Models::Payment
  extend ActiveSupport::Concern

  included do
    belongs_to(:btc_address, inverse_of: :payments, dependent: :destroy, autosave: true)

    has_one(:received_payment, inverse_of: :payment)
    has_one(:sent_payment, inverse_of: :payment)

    validates(:txid, :btc_address, :amount, presence: true)
    validates(:amount, numericality: { greater_than_or_equal_to: BitcoinPayments::ZERO })
    validates(:txid, uniqueness: true)

    auto_strip_attributes(:txid)
  end
end