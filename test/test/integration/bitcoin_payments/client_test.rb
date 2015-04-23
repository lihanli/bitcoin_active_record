require 'test_helper'

class BitcoinPaymentsClientTest < ActiveSupport::TestCase
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

  def test_create_received_payments
    BitcoinPayments.default_account = :test
    BitcoinPayments.default_transaction_count = 1

    @client.create_received_payments
    received_payments = ReceivedPayment.all.to_a
    assert_equal(3, received_payments.size)

    [
      {
        sender_key: '15fRQywgNeF2JDVADbMQTE4sftxLAnGfhn',
        amount: '0.001',
        txid: 'e9c55c74670dd51530989fb39d020a9a39c4b3af75dcc6efc770151b680c8366',
        receiver_key: '1AC8jNajH7zYikxRzRKT3otNW72B9qVDFa',
      },
      {
        sender_key: '12rARqgZBz1hHeESvknLn2Wt2cJc9ddp1y',
        amount: '0.001',
        txid: 'ade4cf44b718b4c338f6962f2501a01dd7e203aa2e2df1bdab6383c1599e0aa6',
        receiver_key: '1AC8jNajH7zYikxRzRKT3otNW72B9qVDFa',
      },
      {
        sender_key: '1G1ravYqGnpM68CUhp2ckD9PXkvtYit23f',
        amount: '0.001',
        txid: '1ae4096365baa4164b8a6f19ff32b7bc0761bde1793e50d9949cec753585c696',
        receiver_key: '1AC8jNajH7zYikxRzRKT3otNW72B9qVDFa',
      },
    ].each_with_index do |expected_values, i|
      received_payment = received_payments[i]
      payment = received_payment.payment

      assert_equal(expected_values[:sender_key], payment.btc_address.public_key)
      assert_equal(BigDecimal.new(expected_values[:amount]), payment.amount)
      assert_equal(expected_values[:txid], payment.txid)
      assert_equal(expected_values[:receiver_key], received_payment.btc_address.public_key)
    end

    # running again shouldnt do anything
    @client.create_received_payments
    assert_equal(3, ReceivedPayment.count)
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

  def test_invalid_request
    rescue_called = false

    begin
      @client.request('dog')
    rescue BitcoinPayments::ApiError => e
      rescue_called = true
      assert_equal(true, e.message.include?('Method not found'))
    end

    assert_equal(true, rescue_called)
  end

  def teardown
    BitcoinPayments.default_transaction_count = 25
  end
end
