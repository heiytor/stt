# frozen_string_literal: true

require "dotenv"
require "spec_helper"
require "tempfile"

Root = File.expand_path("../..", __dir__)
Root_env = Tempfile.new(".env.test")

File.write(Root_env, File.read(File.join(Root, ".env.test")).gsub(%r{^SEGARANTE_}, ""))
Dotenv.load(Root_env)
Root_env.close

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"

abort("Rails isn't running in test environment") unless Rails.env.test?

require "rspec/rails"
require "factory_bot_rails"
require "webmock/rspec"

Rails.root.glob("spec/support/**/*.rb").each { |f| require f }

RSpec.configure do |config|
  config.fixture_paths = [Rails.root.join("spec", "fixtures")]
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include FactoryBot::Syntax::Methods
  config.include ActiveSupport::Testing::TimeHelpers

  config.before :suite do
    compose = Testcontainers::ComposeContainer.new(filepath: Root,
                                                   compose_filenames: ["docker-compose.test.yml"],
                                                   env_file: Root_env.path.to_s)

    compose.start
    # Aguarda os serviços registrem mensagens indicando que estão prontos. Adicionalmente, espera 2 segundos após os
    # logs aparecerem para evitar tentativas de conexão imediatas.
    compose.wait_for_logs(matcher: %r{database system is ready to accept connections}i) # Postgres
    sleep(2.seconds)

    begin
      ActiveRecord::Migration.maintain_test_schema!
    rescue ActiveRecord::PendingMigrationError => e
      abort e.to_s.strip
    end

    RSpec.configuration.instance_variable_set(:@compose, compose)
    WebMock.disable_net_connect!
  end

  config.after :suite do
    log_file = Rails.root.join("log", "test.log")
    log_file.truncate(0) if log_file.exist?

    compose = RSpec.configuration.instance_variable_get(:@compose)
    compose&.stop

    Root_env.unlink
    WebMock.allow_net_connect!
  end
end
