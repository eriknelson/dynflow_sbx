module DynflowSbx
  module Actions
    class SubplanDemo < Dynflow::Action
      def plan
        DynHelper.nsklog.debug "############################################################"
        DynHelper.nsklog.debug "SubplanDemo::plan"

        sequence do
          plan_action ManageContentAsSubPlan
          concurrence do
            plan_action AfterSubplanAction, "foo"
            plan_action AfterSubplanAction, "bar"
          end
        end
      end

      def run
        # Looks like finalize actually isn't called at all if the task
        # doesn't define a run phase.
        DynHelper.nsklog.debug "SubplanDemo::run"
      end
      def finalize
        DynHelper.nsklog.debug "SubplanDemo::finalize"
      end
    end

    class ManageContentAsSubPlan < Dynflow::Action
      include Dynflow::Action::WithSubPlans
      def plan
        DynHelper.nsklog.debug "ManageContentAsSubPlan::plan"
        super()
      end
      def run(*args)
        DynHelper.nsklog.debug "ManageContentAsSubPlan::run"
        super(*args)
      end
      def create_sub_plans
        DynHelper.nsklog.debug "ManageContentAsSubPlan::create_sub_plans"
        trigger ManageContent
      end
    end

    class ManageContent < Dynflow::Action
      def plan
        DynHelper.nsklog.debug "ManageContent::plan"
        plan_self
      end
      def run
        DynHelper.nsklog.debug "ManageContent::run"
      end
      def finalize
        DynHelper.nsklog.debug "ManageContent::finalize"
      end
    end

    class AfterSubplanAction < Dynflow::Action
      def plan(action_id)
        DynHelper.nsklog.debug "AfterSubplanAction::plan"
        plan_self action_id: action_id
      end
      def run
        DynHelper.nsklog.debug "AfterSubplanAction::run"
        DynHelper.nsklog.debug "  action_id -> #{input[:action_id]}"
      end
      def finalize
        DynHelper.nsklog.debug "AfterSubplanAction::finalize"
      end
    end

  end
end

