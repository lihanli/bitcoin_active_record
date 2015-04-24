module BitcoinPayments
  class ApiError < StandardError; end

  module Client
    module_function

    def request(method, *args)
      args.map! { |a| a.is_a?(BigDecimal) ? a.to_f : a }
      raise 'payments disabled in test/development' if method.to_sym == :sendtoaddress && (Rails.env.test? || Rails.env.development?)

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
      raise if Rails.env.test?
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

    def pay(public_key: nil, amount: nil, comment: '')
      raise 'amount required' if amount.nil?
      raise 'amount cant be zero or negative' unless amount > 0
      raise 'public key required' if public_key.blank?

      sent_payment = SentPayment.new(
        payment: Payment.new(
          btc_address: BtcAddress.find_or_initialize_by(public_key: public_key),
          amount: amount,
          txid: request(:sendtoaddress, public_key, amount, comment),
        ),
      )
      yield(send_payment) if block_given?

      sent_payment.save!

      sent_payment
    end

    def create_received_payments(account: BitcoinPayments.default_account)
      page = 0

      while true
        transactions = get_received_transactions(page: page, account: account)
        return if transactions.size == 0

        transactions.each do |transaction|
          txid = transaction['txid']
          # already created payment for this transaction and all older ones
          return if Payment.where(txid: txid).count > 0

          amount = transaction['amount']
          from_key = get_sender_address(txid)

          received_payment = ReceivedPayment.create!(
            payment: Payment.new(
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

          # TODO log to stdout
          Rails.logger.info("Received payment #{amount} BTC from #{from_key}: #{received_payment.inspect}")
        end

        page += 1
      end
    end
  end
end
