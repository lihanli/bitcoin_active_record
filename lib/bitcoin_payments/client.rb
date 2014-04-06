module BitcoinPayments
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
      raise res.inspect unless res['error'].nil?

      res['result']
    end

    def get_new_address
      raise if Rails.env.test? || Rails.env.development?
      request(:getnewaddress, :primary)
    end

    def get_received_transactions(account: BitcoinPayments.default_account)
      request(:listtransactions, account, BitcoinPayments.default_transaction_count).each do |transaction|
        transaction['amount'] = BigDecimal.new(transaction['amount'].to_s) if transaction['amount']
      end.find_all do |transaction|
        (transaction['category'] == 'receive' &&
         transaction['confirmations'] > 0 &&
         transaction['amount'] >= BitcoinPayments.minimum_amount)
      end.reverse
    end

    def move_to_fees(amount)
      request(:move, BitcoinPayments.default_account, :fees, amount)
    end
  end
end