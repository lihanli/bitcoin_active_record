# bitcoin_active_record
Keep records of sent and received bitcoin transactions in your database using activerecord.  

## Quick start guide
* Start bitcoin-qt or bitcoind with these options set in bitcoin.conf
```
server=1
rpcuser=change_this
rpcpassword=change_this
txindex=1 # needed for getting transaction sender keys
```
* Add to gemfile, bundle install
* Run generator
```
rails g bitcoin_active_record:install
```
* Run db:migrate
* Create a bitcoin client
```ruby
client = BitcoinActiveRecord::Client.new(
  server: {
    url: 'http://127.0.0.1:8332',
    username: '',
    password: '',
  },
)
```
* Run client.create_received_payments to create records of received payments
* Run client.pay(public_key: public_key, amount: BigDecimal.new(1), comment: 'hello') to send a payment and save a record of it in the database

## Usage

This gem creates 4 models:

btc_address.rb

column_name | type | description
--- | --- | ---
public_key | string | public key of a bitcoin address

payment.rb

column_name | type | description
--- | --- | ---
btc_address_id | integer | foreign key
amount | decimal | transaction amount
txid | string | bitcoin transaction id

received_payment.rb  

column_name | type | description
--- | --- | ---
payment_id | integer | The btc address associated with this payment id is the address of the person who sent the payment
btc_address_id | integer | This is the address in your wallet that the payment was sent to

sent_payment.rb  

column_name | type | description
--- | --- | ---
payment_id | integer | foreign key

Sent payments are only recorded if you send them using the gem's api.

### BitcoinActiveRecord::Client

Initialize options

```ruby
client = BitcoinActiveRecord::Client.new(
  # required, bitcoind server credentials
  server: {
    url: 'http://127.0.0.1:8332',
    username: '',
    password: '',
  },
  # optional, amounts less than this will be ignored when running create_received_payments
  minimum_amount: BigDecimal.new('0.001'),
  # optional, the wallet account you want to look for received transactions in
  account: :foo,
)
```

* client.request(method, *args)

Send a request to the bitcoind server.  

```ruby
client.request(:getinfo)
client.request(:sendtoaddress, '1N2ZWQszjGDjaW5y3jAStuJQW23MbG1r4N', BigDecimal.new(1))
```

* client.get_new_address

Get a new public key from the server

* client.get_sender_address(txid)

Get the public key of the transaction sender for a transaction with id txid

* client.pay

Pay someone and save a record of it as a SentPayment

```ruby
client.pay(
  # required, public key you want to send BTC to
  public_key: '1N2ZWQszjGDjaW5y3jAStuJQW23MbG1r4N',
  # required, amount in BTC you want to send
  amount: BigDecimal.new('1.23'),
  # optional, transaction comment
  comment: 'foo',
) do |sent_payment|
  # adding a block is optional
  # modify the sent_payment record before it gets saved
  sent_payment.custom_attribute = 'foo'
end
```

* client.create_received_payments

Create a ReceivedPayment model for every transaction from client.account that's >= client.minimum_amount. If the latest transaction is already in the database it will assume all earlier transactions have already been saved.
