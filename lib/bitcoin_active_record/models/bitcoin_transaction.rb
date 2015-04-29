module BitcoinActiveRecord::Models::BitcoinTransaction
  extend ActiveSupport::Concern

  included do
    # sender's address for received transactions
    # payee address for sent transactions
    belongs_to(:btc_address, inverse_of: :bitcoin_transactions)

    has_one(:received_bitcoin_transaction, inverse_of: :bitcoin_transaction)
    has_one(:sent_bitcoin_transaction, inverse_of: :bitcoin_transaction)

    validates(:txid, :btc_address, :amount, presence: true)
    validates(:amount, numericality: { greater_than_or_equal_to: 0 })
    validates(:txid, uniqueness: true)

    auto_strip_attributes(:txid)
  end
end
