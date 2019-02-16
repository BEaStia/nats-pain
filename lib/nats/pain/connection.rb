require 'securerandom'
require 'dry-configurable'
require 'nats_listener'
require 'nats_streaming_listener'
require 'ougai'
require 'connection_pool'

module Nats
  module Pain
    class Connection
      attr_reader :nats_client, :stan_client

      extend Dry::Configurable

      setting :pool, ENV.fetch('PAIN_POOL_SIZE') { 5 }, reader: true
      setting :pool_timeout, ENV.fetch('PAIN_POOL_TIMEOUT') { 5 }, reader: true
      setting :nats_service_name, ENV.fetch('NATS_SERVICE_NAME') { 'painful_service' }, reader: true
      setting :nats_servers, ENV.fetch('NATS_SERVERS_URLS') { 'nats://localhost:4222' }, reader: true
      setting :stan_servers, ENV.fetch('STAN_SERVERS_URLS') { 'nats://localhost:4223' }, reader: true
      setting :stan_cluster_name, ENV.fetch('STAN_CLUSTER_NAME') { 'worki_cluster' }, reader: true

      def self.current
        pool_size = Nats::Pain::Connection.pool
        pool_timeout = Nats::Pain::Connection.pool_timeout
        @current ||= ConnectionPool.new(size: pool_size, timeout: pool_timeout) do
          Nats::Pain::Connection.new
        end
      end

      def self.current=(val)
        pool_size = Nats::Pain::Connection.pool
        pool_timeout = Nats::Pain::Connection.pool_timeout
        @current = ConnectionPool.new(size: pool_size, timeout: pool_timeout) do
          val
        end
      end

      def initialize
        @logger = Ougai::Logger.new(STDOUT)

        @nats_client = NatsListener::Client.new(logger: @logger, skip: false, catch_errors: false)
        @stan_client = NatsStreamingListener::StreamingClient.new(logger: @logger, skip: false, catch_errors: false)

        establish_connections
      end

      def establish_connections
        @nats_client.establish_connection(
          service_name: Connection.nats_service_name,
          nats: { servers: Connection.nats_servers.split(',') }, # Options passed to nats connector
        )

        @stan_client.establish_connection(
          service_name: Connection.nats_service_name,
          nats: { servers: Connection.stan_servers.split(',') }, # Options passed to nats connector
          cluster_name: Connection.stan_cluster_name, # Cluster of nats-streaming that you're connecting to
          client_id: SecureRandom.hex(13).to_s # Id of a client(nats-streaming works with unique client_id)
        )
      end
    end
  end
end
