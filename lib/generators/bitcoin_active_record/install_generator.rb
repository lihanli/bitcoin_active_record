require 'rails/generators'
require "rails/generators/active_record"
require 'script_utils'

module BitcoinActiveRecord
  module Generators
    class InstallGenerator < ActiveRecord::Generators::Base
      # ActiveRecord::Generators::Base inherits from Rails::Generators::NamedBase which requires a NAME parameter for the
      # new table name. Our generator always has the same model names so we just set a random name here.
      argument(:name, type: :string, default: 'random_name')

      source_root(File.expand_path("../../templates", __FILE__))

      def copy_models
        ScriptUtils.file_names(File.expand_path('../../templates/models', __FILE__)).each do |file_name|
          copy_file("models/#{file_name}", "app/models/#{file_name}")
        end
      end

      def create_migrations
        filename = 'create_bitcoin_active_record_models.rb'
        migration_template(filename, "db/migrate/#{filename}")
      end
    end
  end
end
