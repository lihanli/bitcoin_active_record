require 'test_helper'

class BitcoinPaymentsTest < ActiveSupport::TestCase
  def setup
    super
    @client = BitcoinPayments::Client
    raise 'bitcoin client config error' if @client.request(:getinfo).nil?
    BitcoinPayments.default_account = :primary
  end

  def assert_one_transaction(txid, transaction_args: {})
    BitcoinPayments.default_transaction_count = 1
    transactions = @client.get_received_transactions(transaction_args)

    assert_equal(txid, transactions[0]['txid'])
    assert_equal(1, transactions.size)
  end

  def test_get_received_transactions
    BitcoinPayments.default_account = :test
    # test right order
    transactions = @client.get_received_transactions

    assert_equal('e9c55c74670dd51530989fb39d020a9a39c4b3af75dcc6efc770151b680c8366', transactions[0]['txid'])
    assert_equal('ade4cf44b718b4c338f6962f2501a01dd7e203aa2e2df1bdab6383c1599e0aa6', transactions[1]['txid'])
    # if you get one transaction then it should give you the latest first
    assert_one_transaction('e9c55c74670dd51530989fb39d020a9a39c4b3af75dcc6efc770151b680c8366')
    # test pagination
    assert_one_transaction('ade4cf44b718b4c338f6962f2501a01dd7e203aa2e2df1bdab6383c1599e0aa6', transaction_args: { page: 1 })
  end

  def test_get_sender_address
    address = @client.get_sender_address('889c90a43a198ea1c851b621172861736007bc5e526024631eb05062a808b81d')
    assert_equal('1DdqT5jdq8smJMS7uoGZL84d566pLAvxsr', address)
  end

  def test_move_to_fees
    amount = BigDecimal.new('0.0001')
    assert_equal(true, @client.move_to_fees(amount))
    # move fee back to default account
    @client.request(:move, :fees, BitcoinPayments.default_account, amount)
    assert_equal(BitcoinPayments::ZERO, @client.request(:getbalance, :fees))
  end

  def teardown
    BitcoinPayments.default_transaction_count = 25
  end
end
