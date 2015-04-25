require 'rails/generators'
require "rails/generators/active_record"

module BitcoinActiveRecord
  module Generators
    class InstallGenerator < ActiveRecord::Generators::Base
      # ActiveRecord::Generators::Base inherits from Rails::Generators::NamedBase which requires a NAME parameter for the
      # new table name. Our generator always has the same model names so we just set a random name here.
      argument(:name, type: :string, default: 'random_name')

      source_root(File.expand_path("../../templates", __FILE__))

      def copy_initializer
        template('bitcoin_active_record.rb', 'config/initializers/bitcoin_active_record.rb')
      end

      def copy_models
        filenames = `ls #{File.expand_path('../../templates/models', __FILE__)}`.split("\n")
        filenames.each do |filename|
          copy_file("models/#{filename}", "app/models/#{filename}")
        end
      end

      def create_migrations
        filename = 'create_bitcoin_active_record_models.rb'
        migration_template(filename, "db/migrate/#{filename}")
      end
    end
  end
end