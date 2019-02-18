require 'securerandom'
require 'nats_listener'
require 'nats_streaming_listener'
require 'ougai'
require 'connection_pool'

module Nats
  module Pain
    class Connection
      DEFAULT_NATS_SERVERS = 'nats://localhost:4222'.freeze
      DEFAULT_STAN_SERVERS = 'nats://localhost:4223'.freeze
      DEFAULT_SERVICE_NAME = 'painful_service'.freeze
      DEFAULT_STAN_CLUSTER_NAME = 'worki_cluster'.freeze

      attr_reader :nats_pool, :stan_pool

      def self.current
        @current ||= Nats::Pain::Connection.new
      end

      class << self
        attr_writer :current
      end

      # Structure of opts
      # @param [Hash] opts options to create connection
      # @option opts [Logger] :logger logger for connection
      # @option [Hash] :nats the options to be passed to nats listener.
      #   @option nats [Boolean] :enabled - flag to start nats or not
      #   @option nats [Integer] :pool_size - pool size
      #   @option nats [Integer] :pool_timeout - pool timeout
      #   @option nats [Boolean] :catch_errors - flag for catching errors
      #   @option nats [class] :catch_provider this class will be called with catch_provider.error(e)
      #   @option nats [String] :service_name - service name
      #   @option nats [Hash] :nats - nats-pure config for establishing connection
      # @option [Hash] :stan Hash for stan listener
      #   @option stan [Boolean] :enabled - flag to start stan or not
      #   @option stan [Integer] :pool_size - pool size
      #   @option stan [Integer] :pool_timeout - pool timeout
      #   @option stan [Boolean] :catch_errors - flag for catching errors
      #   @option stan [class] :catch_provider this class will be called with catch_provider.error(e)
      #   @option stan [String] :cluster_name - name of nats-streaming cluster that we connect to
      #   @option stan [String] :nats - nats connection info(example: ```{servers: 'nats://127.0.0.1:4223'}```)
      #   @option stan [String] :service_name - name of current service
      #   @option stan [String] :client_id - current service client id(optional)

      def initialize(opts = {})
        @logger = opts.fetch(:logger) { Ougai::Logger.new(STDOUT) }

        load_nats(opts.fetch(:nats) { {} })
        load_stan(opts.fetch(:stan) { {} })
      end

      def load_nats(opts = {})
        return unless opts.fetch(:enabled) { true }

        @nats_pool = ConnectionPool.new(size: opts.fetch(:pool_size) { 5 }, timeout: opts.fetch(:pool_timeout) { 5 }) do
          connection = NatsListener::Client.new(
            logger: @logger,
            skip: false,
            catch_errors: opts.fetch(:catch_errors) { false },
            catch_provider: opts.fetch(:catch_provider) { nil }
          )
          nats_config = opts.fetch(:nats) { { servers: opts.fetch(:nats_servers) { DEFAULT_NATS_SERVERS }.split(',') } }
          connection.establish_connection(
            service_name: opts.fetch(:service_name) { DEFAULT_SERVICE_NAME },
            nats: nats_config, # Options passed to nats connector
          )
          connection
        end
      end

      def load_stan(opts = {})
        return unless opts.fetch(:enabled) { true }

        @stan_pool = ConnectionPool.new(size: opts.fetch(:pool_size) { 5 }, timeout: opts.fetch(:pool_timeout) { 5 }) do
          connection = NatsStreamingListener::StreamingClient.new(
            logger: @logger,
            skip: false,
            catch_errors: opts.fetch(:catch_errors) { false },
            catch_provider: opts.fetch(:catch_provider) { nil }
          )
          nats_config = { servers: opts.fetch(:stan_servers) { DEFAULT_STAN_SERVERS }.split(',') }
          connection.establish_connection(
            service_name: opts.fetch(:nats_service_name) { DEFAULT_SERVICE_NAME },
            nats: opts.fetch(:nats) { nats_config }, # Options passed to nats connector
            cluster_name: opts.fetch(:stan_cluster_name) { DEFAULT_STAN_CLUSTER_NAME }, # Cluster of nats-streaming that you're connecting to
            client_id: opts.fetch(:client_id) { SecureRandom.hex(13).to_s } # Id of a client(nats-streaming works with unique client_id)
          )
          connection
        end
      end
    end
  end
end
