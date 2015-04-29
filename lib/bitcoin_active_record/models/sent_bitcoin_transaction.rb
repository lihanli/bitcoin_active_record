module BitcoinActiveRecord::Models::SentBitcoinTransaction
  extend ActiveSupport::Concern

  included do
    belongs_to(:bitcoin_transaction, inverse_of: :sent_bitcoin_transaction, dependent: :destroy)

    validates(:bitcoin_transaction, presence: true)
    validates(:bitcoin_transaction_id, uniqueness: true)
  end
end
