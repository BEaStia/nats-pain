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

      def self.current
        @current ||= Nats::Pain::Connection.new
      end

      class << self
        attr_writer :current
      end

      def initialize(opts = {})
        @logger = Ougai::Logger.new(STDOUT)
        load_nats(opts)
        load_stan(opts)
      end

      def load_nats(opts = {})
        return unless opts.fetch(:nats_enabled) { true }

        @nats_pool = ConnectionPool.new(size: opts.fetch(:nats_pool_size) { 5 }, timeout: opts.fetch(:nats_pool_timeout) { 5 }) do
          connection = NatsListener::Client.new(logger: @logger, skip: false, catch_errors: false)
          connection.establish_connection(
            service_name: opts.fetch(:nats_service_name) { 'painful_service' },
            nats: { servers: opts.fetch(:nats_servers) { 'nats://localhost:4222' }.split(',') }, # Options passed to nats connector
          )
          connection
        end
      end

      def load_stan(opts = {})
        return unless opts.fetch(:stan_enabled) { true }

        @stan_pool = ConnectionPool.new(size: opts.fetch(:stan_pool_size) { 5 }, timeout: opts.fetch(:stan_pool_timeout) { 5 }) do
          connection = NatsStreamingListener::StreamingClient.new(logger: @logger, skip: false, catch_errors: false)
          connection.establish_connection(
            service_name: opts.fetch(:nats_service_name) { 'painful_service' },
            nats: { servers: opts.fetch(:stan_servers) { 'nats://localhost:4223' }.split(',') }, # Options passed to nats connector
            cluster_name: opts.fetch(:stan_cluster_name) { 'worki_cluster' }, # Cluster of nats-streaming that you're connecting to
            client_id: SecureRandom.hex(13).to_s # Id of a client(nats-streaming works with unique client_id)
          )
          connection
        end
      end
    end
  end
end
