# bitcoin_active_record
Integrates bitcoind with activerecord to keep records of sent and received transactions in your database.  

## Quick start guide
* Add to gemfile, bundle install
* Run generator
```
rails g bitcoin_active_record:install
```
* Put server url/username/password in config/initializers/bitcoin_active_record.rb
* Run db:migrate
* Run BitcoinActiveRecord::Client.create_received_payments to create records of received payments
* Run BitcoinActiveRecord::Client.pay(public_key: public_key, amount: BigDecimal.new(1), comment: 'hello') to send a payment and save a record of it in the database

## Usage

This gem creates 4 models:

btc_address.rb

column_name | type | description
--- | --- | ---
public_key | string | public key of a bitcoin address

When creating a new btc_address model if the public_key is not set then it will get a new one generated from the bitcoind server.  

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

### BitcoinActiveRecord::Client methods
* request(method, *args)

Send a request to the bitcoind server.  

Examples:  
```
BitcoinActiveRecord::Client.request(:getinfo)
BitcoinActiveRecord::Client.request(:sendtoaddress, '1N2ZWQszjGDjaW5y3jAStuJQW23MbG1r4N', BigDecimal.new(1))
```

* get_new_address(account: BitcoinActiveRecord.default_account)

Get a new public key address from the server
