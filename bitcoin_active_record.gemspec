Gem::Specification.new do |gem|
  gem.name = 'bitcoin_active_record'
  gem.version = '0.0.1'
  gem.summary = 'bitcoin activerecord integration'
  gem.author = 'Lihan Li'
  gem.email = 'frankieteardrop@gmail.com'

  gem.add_dependency('httparty', '>= 0.13.1')
  gem.add_dependency('auto_strip_attributes', '>= 2.0.4')

  gem.files = `git ls-files`.split("\n")
  gem.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_paths = ["lib"]
end
