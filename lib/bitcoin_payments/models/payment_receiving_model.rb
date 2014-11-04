module BitcoinPayments::Models::PaymentReceivingModel
  extend ActiveSupport::Concern

  included do
    binding.pry; raise
    # belongs_to(:btc_address, inverse_of: :match_participant_bet, autosave: true, dependent: :destroy)
  end
end

# belongs_to(:match_participant, inverse_of: :match_participant_bets)
#   belongs_to(:bet_type, inverse_of: :match_participant_bets)
#   belongs_to(:btc_address, inverse_of: :match_participant_bet, autosave: true, dependent: :destroy)

#   has_many(:received_payments, inverse_of: :match_participant_bet, autosave: true)

#   validates(:match_participant, :bet_type, :btc_address, presence: true)
#   validates(:bet_type_id, uniqueness: { scope: :match_participant_id })
#   validate(:must_have_consistent_bet_type)

#   before_validation do
#     if btc_address.blank?
#       self.btc_address = BtcAddress.new
#     end
#   end
