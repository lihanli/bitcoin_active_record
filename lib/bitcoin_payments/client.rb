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
  end
end