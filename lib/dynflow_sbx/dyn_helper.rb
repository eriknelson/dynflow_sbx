require 'logger'

module DynflowSbx
  class DynHelper
    # Creates class singleton methods, adding these methods to
    # the DynHelper's eigenclass
    class << self
      def nsklog
        @nsklog ||= create_nsklog
      end

      def create_nsklog
        Logger.new('nsklog.log', 'monthly')
      end

      def world
        @world ||= create_world
      end

      def create_world
        config = Dynflow::Config.new
        config.persistence_adapter = persistence_adapter
        config.logger_adapter      = logger_adapter
        config.auto_rescue         = false
        yield config if block_given?
        Dynflow::World.new(config).tap do |world|
          puts "World #{world.id} started..."
        end
      end

      def persistence_adapter
        Dynflow::PersistenceAdapters::Sequel.new persistence_conn_string
      end

      def persistence_conn_string
        ENV['DB_CONN_STRING'] || 'sqlite://dynsbx.db'
      end

      def default_world_options
        {
          logger_adapter: logger_adapter,
          persistence_adapter: persistence_adapter
        }
      end

      def logger_adapter
        Dynflow::LoggerAdapters::Simple.new $stderr, 4
      end

      def run_web_console(world = DynHelper.world)
        require 'dynflow/web'
        dynflow_console = Dynflow::Web.setup do
          set :world, world
        end
        Rack::Server.new(:app => dynflow_console, :Port => 4567).start
      end

      def terminate
        @world.terminate.wait if @world
      end

    end
  end
end

at_exit { DynflowSbx::DynHelper.terminate }
