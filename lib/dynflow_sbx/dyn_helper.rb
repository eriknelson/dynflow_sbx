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

      def create_world(options = {})
        options = default_world_options.merge(options)
        Dynflow::SimpleWorld.new(options)
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
        require 'dynflow/web_console'
        dynflow_console = Dynflow::WebConsole.setup do
          set :world, world
        end
        dynflow_console.run!
      end
    end
  end
end
