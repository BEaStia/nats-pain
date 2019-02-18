require 'securerandom'
require 'dry-configurable'
require 'nats_listener'
require 'nats_streaming_listener'
require 'ougai'
require 'connection_pool'

module Nats
  module Pain
    class Connection
      attr_reader :nats_pool, :stan_pool

      extend Dry::Configurable

      def self.current
        @current ||= Nats::Pain::Connection.new
      end

      class << self
        attr_writer :current
      end

      setting :nats_enabled, ENV.fetch('PAIN_NATS_ENABLED') { true }, reader: true
      setting :nats_pool_size, ENV.fetch('PAIN_NATS_POOL_SIZE') { 5 }, reader: true
      setting :nats_pool_timeout, ENV.fetch('PAIN_NATS_POOL_TIMEOUT') { 5 }, reader: true
      setting :nats_service_name, ENV.fetch('NATS_SERVICE_NAME') { 'painful_service' }, reader: true
      setting :nats_servers, ENV.fetch('NATS_SERVERS_URLS') { 'nats://localhost:4222' }, reader: true

      setting :stan_enabled, ENV.fetch('PAIN_STAN_ENABLED') { true }, reader: true
      setting :stan_pool_size, ENV.fetch('PAIN_STAN_POOL_SIZE') { 5 }, reader: true
      setting :stan_pool_timeout, ENV.fetch('PAIN_STAN_POOL_TIMEOUT') { 5 }, reader: true
      setting :stan_servers, ENV.fetch('STAN_SERVERS_URLS') { 'nats://localhost:4223' }, reader: true
      setting :stan_cluster_name, ENV.fetch('STAN_CLUSTER_NAME') { 'worki_cluster' }, reader: true

      def initialize(opts = {})
        @logger = Ougai::Logger.new(STDOUT)
        load_nats(opts)
        load_stan(opts)
      end

      def load_nats(opts = {})
        return unless opts.fetch(:nats_enabled) { Nats::Pain::Connection.nats_enabled }

        @nats_pool = ConnectionPool.new(size: Nats::Pain::Connection.nats_pool_size, timeout: Nats::Pain::Connection.nats_pool_timeout) do
          connection = NatsListener::Client.new(logger: @logger, skip: false, catch_errors: false)
          connection.establish_connection(
            service_name: opts.fetch(:nats_service_name) { Connection.nats_service_name },
            nats: { servers: opts.fetch(:nats_servers) { Connection.nats_servers }.split(',') }, # Options passed to nats connector
          )
          connection
        end
      end

      def load_stan(opts = {})
        return unless opts.fetch(:stan_enabled) { Nats::Pain::Connection.stan_enabled }

        @stan_pool = ConnectionPool.new(size: Nats::Pain::Connection.stan_pool_size, timeout: Nats::Pain::Connection.stan_pool_timeout) do
          connection = NatsStreamingListener::StreamingClient.new(logger: @logger, skip: false, catch_errors: false)
          connection.establish_connection(
            service_name: opts.fetch(:nats_service_name) { Connection.nats_service_name },
            nats: { servers: opts.fetch(:stan_servers) { Connection.stan_servers }.split(',') }, # Options passed to nats connector
            cluster_name: opts.fetch(:stan_cluster_name) { Connection.stan_cluster_name }, # Cluster of nats-streaming that you're connecting to
            client_id: SecureRandom.hex(13).to_s # Id of a client(nats-streaming works with unique client_id)
          )
          connection
        end
      end
    end
  end
end
