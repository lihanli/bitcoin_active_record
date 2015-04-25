module BitcoinActiveRecord::Models::Payment
  extend ActiveSupport::Concern

  included do
    # sender's address for received payments
    # payee address for sent payments
    belongs_to(:btc_address, inverse_of: :payments)

    has_one(:received_payment, inverse_of: :payment)
    has_one(:sent_payment, inverse_of: :payment)

    validates(:txid, :btc_address, :amount, presence: true)
    validates(:amount, numericality: { greater_than_or_equal_to: 0 })
    validates(:txid, uniqueness: true)

    auto_strip_attributes(:txid)
  end
end