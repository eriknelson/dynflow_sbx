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
            plan_action BarChildAction, foo_action.output[:foo]
            plan_action BarChildAction, foo_action.output[:foo]
            plan_action BarChildAction, foo_action.output[:foo]
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
        output[:foo] = "foo"
      end
      def finalize
        DynHelper.nsklog.debug "FooChildAction::finalize"
      end
    end

    class BarChildAction < Base
      def plan(foo_in)
        #DynHelper.nsklog.debug "BarChildAction::plan"
        #DynHelper.nsklog.debug "input: #{foo_in}"
        plan_self foo: foo_in
      end
      def run
        DynHelper.nsklog.debug "BarChildAction::run"
        DynHelper.nsklog.debug "[:foo] input -> #{input[:foo]}"
        output[:bar] = input[:foo] + "::bar"
      end
      def finalize
        DynHelper.nsklog.debug "BarChildAction::finalize"
      end
    end
  end
end
