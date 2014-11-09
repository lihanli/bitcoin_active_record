module BitcoinPayments::Models::PaymentReceivingModel
  extend ActiveSupport::Concern

  included do
    model_name = self.to_s.underscore.to_sym

    belongs_to(:btc_address, inverse_of: model_name, autosave: true, dependent: :destroy)
    has_many(:received_payments, inverse_of: model_name, autosave: true)

    validates(:btc_address, presence: true)

    before_validation do
      if btc_address.blank?
        self.btc_address = BtcAddress.new
      end
    end
  end

  def amount
    return ZERO if received_payments.size == 0
    received_payments.map(&:amount).reduce(:+)
  end
end
