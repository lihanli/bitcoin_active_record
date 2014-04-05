require 'test_helper'

class BitcoinPaymentsTest < ActiveSupport::TestCase
  def setup
    super
    @client = BitcoinPayments::Client
  end

  def test_get_received_transactions
    BitcoinPayments.default_account = :test
    transactions = @client.get_received_transactions
    transactions.delete_at(0)
    # test right order
    assert_equal('ade4cf44b718b4c338f6962f2501a01dd7e203aa2e2df1bdab6383c1599e0aa6', transactions[0]['txid'])
    assert_equal('1ae4096365baa4164b8a6f19ff32b7bc0761bde1793e50d9949cec753585c696', transactions[1]['txid'])
    # if you get one transaction then it should give you the latest first
    BitcoinPayments.default_transaction_count = 1
    transactions = @client.get_received_transactions
    assert_equal('e9c55c74670dd51530989fb39d020a9a39c4b3af75dcc6efc770151b680c8366', transactions[0]['txid'])
    assert_equal(1, transactions.size)
  end
end
