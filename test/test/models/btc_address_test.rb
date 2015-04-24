require 'test_helper'

class BtcAddressTest < ActiveSupport::TestCase
  def setup
    @btc_address = BtcAddress.new
  end

  def test_getting_new_key_before_validation
    key = '32423k4jk32j4lk'

    BitcoinPayments::Client.expects(:get_new_address).returns(key)
    @btc_address.valid?
    assert_equal(key, @btc_address.public_key)
  end
end
