module BitcoinPayments
  module Client
    module_function

    def request(method, *args)
      args.map! { |a| a.is_a?(BigDecimal) ? a.to_f : a }

      res = HTTParty.post(
        CONFIG[:bitcoind][:host],
        basic_auth: {
          username: CONFIG[:bitcoind][:username],
          password: CONFIG[:bitcoind][:password],
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
  end
end