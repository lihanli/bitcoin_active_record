require 'active_support/dependencies'
require 'active_support/concern'
require 'httparty'
require 'bigdecimal'
require 'auto_strip_attributes'
require 'bitcoin_active_record/models'

module BitcoinActiveRecord
  module_function

  autoload(:Client, 'bitcoin_active_record/client')

  module Models
    lambda do
      path_prefix = 'bitcoin_active_record/models/'

      Dir["#{File.dirname(__FILE__)}/#{path_prefix}*.rb"].map do |file|
        File.basename(file, '.rb')
      end.each do |file_name|
        autoload(file_name.camelize, "#{path_prefix}#{file_name}")
      end
    end.()
  end
end
