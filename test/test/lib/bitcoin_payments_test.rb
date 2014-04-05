require 'test_helper'

class BitcoinPaymentsTest < ActiveSupport::TestCase
  def setup
    super
  end

  def test
    assert_equal(false, BitcoinPayments::Client.request(:getinfo).nil?)
  end
end
