Gem::Specification.new do |gem|
  gem.name     = 'bitcoin_payments'
  gem.version  = '0.0.1'
  gem.summary  = 'bitcoin payment processor'
  gem.author   = 'Lihan Li'
  gem.email    = 'frankieteardrop@gmail.com'

  gem.add_dependency('httparty')

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_paths = ["lib"]
end