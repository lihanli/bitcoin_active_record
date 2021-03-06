module BitcoinActiveRecord
  class ApiError < StandardError; end

  class Client
    attr_accessor(:minimum_amount)
    attr_accessor(:account)
    attr_reader(:server)

    def initialize(server: raise('server required'), minimum_amount: 0, account: '')
      @server = server
      @minimum_amount = minimum_amount
      @account = account
      @default_transaction_count = 25
    end

    def request(method, *args)
      args.map! { |a| a.is_a?(BigDecimal) ? a.to_f : a }
      raise 'payments disabled in test/development' if method.to_sym == :sendtoaddress && (Rails.env.test? || Rails.env.development?)

      res = HTTParty.post(
        @server[:url],
        basic_auth: {
          username: @server[:username],
          password: @server[:password],
        },
        headers: {
          'Content-Type' => 'application/json',
        },
        body: {
          method: method,
          params: args,
          id: 'jsonrpc',
        }.to_json,
      )
      raise ApiError.new(res) unless res['error'].nil?

      res['result']
    end

    def get_new_address
      raise if Rails.env.test?
      request(:getnewaddress, @account)
    end

    def get_sender_address(txid)
      addresses = []
      raw_tx = request('decoderawtransaction', request('getrawtransaction', txid))

      raw_tx['vin'].each do |input|
        input_raw_tx = request('decoderawtransaction', request('getrawtransaction', input['txid']))
        addresses << input_raw_tx['vout'][input['vout']]['scriptPubKey']['addresses'][0]
      end

      addresses[0]
    end

    def pay(public_key: raise('public key required'), amount: raise('amount required'), comment: '')
      raise('amount cant be zero or negative') unless amount > 0

      sent_bitcoin_transaction = SentBitcoinTransaction.new(
        bitcoin_transaction: BitcoinTransaction.new(
          btc_address: BtcAddress.find_or_initialize_by(public_key: public_key),
          amount: amount,
          txid: request(:sendtoaddress, public_key, amount, comment),
        ),
      )
      yield(sent_bitcoin_transaction) if block_given?

      sent_bitcoin_transaction.save!

      sent_bitcoin_transaction
    end

    def create_received_bitcoin_transactions
      page = 0

      while true
        transactions = get_received_transactions(page: page)
        return if transactions.size == 0

        transactions.each do |transaction|
          txid = transaction['txid']
          # already created record for this transaction and all older ones
          return if BitcoinTransaction.where(txid: txid).count > 0

          amount = transaction['amount']
          from_key = get_sender_address(txid)

          received_bitcoin_transaction = ReceivedBitcoinTransaction.create!(
            bitcoin_transaction: BitcoinTransaction.new(
              # payment from this address
              btc_address: BtcAddress.find_or_initialize_by(
                public_key: from_key
              ),
              amount: amount,
              txid: txid,
            ),
            # sent to this address
            btc_address: BtcAddress.find_or_initialize_by(public_key: transaction['address']),
          )

          puts("Received transaction #{amount} BTC from #{from_key}: #{received_bitcoin_transaction.inspect}")
        end

        page += 1
      end
    end

    private

    def get_received_transactions(page: 0)
      from = page * @default_transaction_count

      request(
        :listtransactions,
        @account,
        @default_transaction_count,
        from,
      ).each do |transaction|
        transaction['amount'] = BigDecimal.new(transaction['amount'].to_s) if transaction['amount']
      end.find_all do |transaction|
        (transaction['category'] == 'receive' &&
         transaction['confirmations'] > 0 &&
         transaction['amount'] >= @minimum_amount)
      end.reverse
    end
  end
end
