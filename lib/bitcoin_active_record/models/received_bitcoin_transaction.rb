module BitcoinActiveRecord::Models::ReceivedBitcoinTransaction
  extend ActiveSupport::Concern

  included do
    belongs_to(:bitcoin_transaction, inverse_of: :received_bitcoin_transaction, dependent: :destroy)
    belongs_to(:btc_address, inverse_of: :received_bitcoin_transactions) # payment to this address

    validates(:bitcoin_transaction, presence: true)
    validates(:bitcoin_transaction_id, uniqueness: true)
  end
end
