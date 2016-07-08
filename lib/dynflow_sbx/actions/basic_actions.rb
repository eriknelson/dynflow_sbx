module DynflowSbx
  module Actions
    class Base < Dynflow::Action
      # Base class used to simulate an Action that's doing some amount of work
      def nsksleep(time)
        sleep(rand(time))
      end
    end

    class BasicAction < Dynflow::Action
      def plan
        DynHelper.nsklog.debug "############################################################"
        DynHelper.nsklog.debug "BasicAction::plan"

        sequence do
          foo_action = plan_action(FooChildAction)
          concurrence do
            plan_action BarChildAction, foo_action.output[:password]
            plan_action BarChildAction, foo_action.output[:password]
            plan_action BarChildAction, foo_action.output[:password]
          end
        end
      end

      def run
        # Looks like finalize actually isn't called at all if the task
        # doesn't define a run phase.
        DynHelper.nsklog.debug "BasicAction::run"
      end
      def finalize
        DynHelper.nsklog.debug "BasicAction::finalize"
      end
    end

    class FooChildAction < Base
      def plan
        DynHelper.nsklog.debug "FooChildAction::plan"
        plan_self
      end
      def run
        DynHelper.nsklog.debug "FooChildAction::run"
        output[:password] = "hunter2"
      end
      def finalize
        DynHelper.nsklog.debug "FooChildAction::finalize"
      end
    end

    class ScrubPasswordMiddleware < ::Dynflow::Middleware
      def present
        DynHelper.nsklog.debug "Scrubbing Middleware!"
        action.input[:password] = '** INPUT TOP SECRET **'
        action.output[:password] = '** OUTPUT TOP SECRET **'
      end
    end

    class BarChildAction < Base
      middleware.use ScrubPasswordMiddleware

      def plan(password)
        plan_self password: password
      end
      def run
        DynHelper.nsklog.debug "BarChildAction::run"
        DynHelper.nsklog.debug "internal password -> #{input[:password]}"
        output[:password] = input[:password]
      end
      def finalize
        DynHelper.nsklog.debug "BarChildAction::finalize"
      end
    end
  end
end
