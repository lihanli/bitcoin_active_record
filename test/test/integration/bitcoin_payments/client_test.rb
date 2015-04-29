require 'test_helper'

class BitcoinActiveRecordClientTest < ActiveSupport::TestCase
  def setup
    super
    @client = BitcoinActiveRecord::Client.new(
      server: $bitcoin_server_info,
      account: :primary,
    )
    raise 'bitcoin client config error' if @client.request(:getinfo).nil?
  end

  def assert_one_transaction(txid, transaction_args: {})
    set_default_transaction_count(1)
    transactions = @client.send(:get_received_transactions, transaction_args)

    assert_equal(txid, transactions[0]['txid'])
    assert_equal(1, transactions.size)
  end

  def set_default_transaction_count(count)
    @client.instance_variable_set(:@default_transaction_count, count)
  end

  def test_create_received_bitcoin_transactions
    set_default_transaction_count(2)
    @client.account = :test

    @client.create_received_bitcoin_transactions
    received_bitcoin_transactions = ReceivedBitcoinTransaction.all.to_a
    assert_equal(3, received_bitcoin_transactions.size)

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
      received_bitcoin_transaction = received_bitcoin_transactions[i]
      bitcoin_transaction = received_bitcoin_transaction.bitcoin_transaction

      assert_equal(expected_values[:sender_key], bitcoin_transaction.btc_address.public_key)
      assert_equal(BigDecimal.new(expected_values[:amount]), bitcoin_transaction.amount)
      assert_equal(expected_values[:txid], bitcoin_transaction.txid)
      assert_equal(expected_values[:receiver_key], received_bitcoin_transaction.btc_address.public_key)
    end

    # running again shouldnt do anything
    @client.create_received_bitcoin_transactions
    assert_equal(3, ReceivedBitcoinTransaction.count)
  end

  def test_get_received_transactions
    @client.account = :test
    @client.minimum_amount = BigDecimal.new('0.001')
    # test right order
    transactions = @client.send(:get_received_transactions)

    assert_equal('e9c55c74670dd51530989fb39d020a9a39c4b3af75dcc6efc770151b680c8366', transactions[0]['txid'])
    assert_equal('ade4cf44b718b4c338f6962f2501a01dd7e203aa2e2df1bdab6383c1599e0aa6', transactions[1]['txid'])
    # if you get one transaction then it should give you the latest first
    assert_one_transaction('e9c55c74670dd51530989fb39d020a9a39c4b3af75dcc6efc770151b680c8366')
    # test pagination
    assert_one_transaction('ade4cf44b718b4c338f6962f2501a01dd7e203aa2e2df1bdab6383c1599e0aa6', transaction_args: { page: 1 })

    # setting minimum amount should work
    @client.minimum_amount = BigDecimal.new('0.002')
    assert_equal([], @client.send(:get_received_transactions))
  end

  def test_get_sender_address
    address = @client.get_sender_address('889c90a43a198ea1c851b621172861736007bc5e526024631eb05062a808b81d')
    assert_equal('1DdqT5jdq8smJMS7uoGZL84d566pLAvxsr', address)
  end

  def test_invalid_request
    exception = assert_raise(BitcoinActiveRecord::ApiError) { @client.request('dog') }
    assert_equal(true, exception.message.include?('Method not found'))
  end

  def test_payments_disabled_in_test
    exception = assert_raise(RuntimeError) { @client.request('sendtoaddress', 'abcd') }
    assert_equal('payments disabled in test/development', exception.message)
  end

  def test_pay
    public_key = 'abcd12423324'
    amount = BigDecimal.new(1)
    comment = 'foo'
    txid = 'kjdksfjlk2323'
    @client.expects(:request).with(:sendtoaddress, public_key, amount, comment).returns(txid)

    sent_bitcoin_transaction = @client.pay(public_key: public_key, amount: amount, comment: comment) do |sent_bitcoin_transaction|
      assert_equal(false, sent_bitcoin_transaction.persisted?)
    end

    bitcoin_transaction = sent_bitcoin_transaction.bitcoin_transaction

    assert_equal(true, sent_bitcoin_transaction.persisted?)
    assert_equal(public_key, bitcoin_transaction.btc_address.public_key)
    assert_equal(amount, bitcoin_transaction.amount)
    assert_equal(txid, bitcoin_transaction.txid)
  end
end
