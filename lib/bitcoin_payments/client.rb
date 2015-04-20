module BitcoinPayments
  class ApiError < StandardError; end

  module Client
    module_function

    def request(method, *args)
      args.map! { |a| a.is_a?(BigDecimal) ? a.to_f : a }

      res = HTTParty.post(
        BitcoinPayments.server[:url],
        basic_auth: {
          username: BitcoinPayments.server[:username],
          password: BitcoinPayments.server[:password],
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

    def get_new_address(account: BitcoinPayments.default_account)
      raise if Rails.env.test? || Rails.env.development?
      request(:getnewaddress, account)
    end

    def get_received_transactions(account: BitcoinPayments.default_account, page: 0)
      from = page * BitcoinPayments.default_transaction_count

      request(
        :listtransactions,
        account,
        BitcoinPayments.default_transaction_count,
        from,
      ).each do |transaction|
        transaction['amount'] = BigDecimal.new(transaction['amount'].to_s) if transaction['amount']
      end.find_all do |transaction|
        (transaction['category'] == 'receive' &&
         transaction['confirmations'] > 0 &&
         transaction['amount'] >= BitcoinPayments.minimum_amount)
      end.reverse
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

    def create_received_payments
      # TODO finish
      # TODO allow user to specify account
      page = 0

      while true
        transactions = get_received_transactions(page: page)
        return if transactions.size == 0

        transactions.each do |transaction|
          txid = transaction['txid']
          # already created payment for this transaction and all older ones
          return if Payment.where(txid: txid).count > 0

          ReceivedPayment.create!(
            payment: Payment.new(
              # payment from this address
              btc_address: BtcAddress.find_or_initialize_by(
                public_key: get_sender_address(txid)
              ),
              amount: transaction['amount'],
              txid: txid,
            ),
            # sent to this address
            btc_address: BtcAddress.find_or_initialize_by(public_key: transaction['address']),
          )
          # TODO log this
        end

        page += 1
      end
    end
  end
end