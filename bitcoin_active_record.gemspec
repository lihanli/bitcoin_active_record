Gem::Specification.new do |gem|
  gem.name = 'bitcoin_active_record'
  gem.version = '0.1.0'
  gem.summary = 'bitcoin activerecord integration'
  gem.author = 'Lihan Li'
  gem.email = 'frankieteardrop@gmail.com'
  gem.homepage = 'https://github.com/lihanli/bitcoin_active_record'

  gem.add_dependency('httparty', '>= 0.13.1')
  gem.add_dependency('auto_strip_attributes', '>= 2.0.4')
  gem.add_dependency('script_utils', '0.0.3')

  gem.files = `git ls-files`.split("\n")
  gem.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_paths = ["lib"]
end
