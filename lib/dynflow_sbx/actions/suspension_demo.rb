module DynflowSbx
  module Actions
    class ExternalActionPlanner < Dynflow::Action
      def plan
        DynHelper.nsklog.debug "############################################################"
        DynHelper.nsklog.debug "BasicAction::plan"

        sequence do
          plan_action BarChildAction, "pre-foo"

          concurrence do
            plan_action ExternalFooChildAction
            plan_action ExternalFooChildAction
            plan_action ExternalFooChildAction
          end

          plan_action BarChildAction, "post-foo"
        end
      end
    end

    class ExternalFooChildAction < Base
      def plan
        DynHelper.nsklog.debug "ExternalFooChildAction::plan"
        plan_self
      end
      def run(*args)
        DynHelper.nsklog.debug "ExternalFooChildAction::run"
        DynHelper.nsklog.debug "Args length: #{args.length}"

        if args.length == 0 # First run
          DynHelper.nsklog.debug "ExternalFooChildAction:: first run"
          suspend do |invoker|
            DynHelper.nsklog.debug "ExternalFooChildAction:: invoking work"
            external_worker = MockExternalWorker.new
            external_worker.invoke(invoker, rand(6))
          end
        elsif args.length == 1 # Got event
          DynHelper.nsklog.debug "ExternalFooChildAction:: Woke up, got event!"
          if args.first == :done # got another
            DynHelper.nsklog.debug "ExternalFooChildAction:: Worker says its done!"
          else
            DynHelper.nsklog.debug "worker triggered something unknown"
          end
        else
          raise "Unknown event triggered" # wtf
        end
      end
      def finalize
        DynHelper.nsklog.debug "ExternalFooChildAction::finalize"
      end
    end

    class BarChildAction < Base
      def plan(name)
        DynHelper.nsklog.debug "BarChildAction::plan::#{name}"
        plan_self :name => name
      end
      def run
        DynHelper.nsklog.debug "BarChildAction::run::#{input[:name]}"
      end
      def finalize
        DynHelper.nsklog.debug "BarChildAction::finalize::#{input[:name]}"
      end
    end

  end
end
