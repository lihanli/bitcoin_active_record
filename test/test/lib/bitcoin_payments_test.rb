require 'test_helper'

class BitcoinPaymentsTest < ActiveSupport::TestCase
  def setup
    super
  end

  def test
    BitcoinPayments::Client.request(:getinfo)
    binding.pry; raise
  end
end
