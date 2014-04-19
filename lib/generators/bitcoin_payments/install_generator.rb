require 'rails/generators'
require "rails/generators/active_record"

module BitcoinPayments
  module Generators
    class InstallGenerator < ActiveRecord::Generators::Base
      # ActiveRecord::Generators::Base inherits from Rails::Generators::NamedBase which requires a NAME parameter for the
      # new table name. Our generator always has the same model names so we just set a random name here.
      argument(:name, type: :string, default: 'random_name')

      source_root(File.expand_path("../../templates", __FILE__))

      def copy_initializer
        template('bitcoin_payments.rb', 'config/initializers/bitcoin_payments.rb')
      end

      def copy_models
        filenames = `ls #{File.expand_path('../../templates/models', __FILE__)}`.split("\n")
        filenames.each do |filename|
          copy_file("models/#{filename}", "app/models/#{filename}")
        end
      end

      def create_migrations
        filename = 'create_bitcoin_payments_models.rb'
        migration_template(filename, "db/migrate/#{filename}")
      end
    end
  end
end