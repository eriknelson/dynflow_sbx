module DynflowSbx
  module Actions
    class SubplanDemo < Dynflow::Action
      def plan
        DynHelper.nsklog.debug(
          "############################################################")
        DynHelper.nsklog.debug "SubplanDemo::plan"

        sequence do
          manage_content_subplan = plan_action ManageContentAsSubPlan

          concurrence do
            plan_action(
              AfterSubplanAction,
              manage_content_subplan.output[:content_skipped])
            plan_action(
              AfterSubplanAction,
              manage_content_subplan.output[:content_skipped])
          end
        end
      end

      def rescue_strategy
        Dynflow::Action::Rescue::Skip
      end

      def finalize
        DynHelper.nsklog.debug "SubplanDemo::finalize"
      end

      #def run
        # NOTE: run here is not going to run if the root hasn't planned itself!
      #end
    end

    class ManageContentAsSubPlan < Dynflow::Action
      include Dynflow::Action::WithSubPlans
      def plan
        DynHelper.nsklog.debug "ManageContentAsSubPlan::plan"
        super()
      end
      def run(event = nil)
        DynHelper.nsklog.debug "ManageContentAsSubPlan::run"

        if event === Dynflow::Action::Skip
          DynHelper.nsklog.debug "ManageContentAsSubPlan::skipbranch -- swallowing error!"
          output[:content_skipped] = true
        else
          DynHelper.nsklog.debug "ManageContentAsSubPlan::superbranch"
          output[:content_skipped] = false
          super
        end
      end
      def create_sub_plans
        DynHelper.nsklog.debug "ManageContentAsSubPlan::create_sub_plans"
        trigger ManageContent
      end
    end

    class ManageContent < Dynflow::Action
      def should_fail?
        should_fail = !@failed_once
        DynHelper.nsklog.debug "should_fail->#{should_fail}"

        if should_fail
          @failed_once = true
        end

        should_fail
      end
      def plan
        DynHelper.nsklog.debug "ManageContent::plan"
        super
      end
      def run
        DynHelper.nsklog.debug "ManageContent::run"
        if should_fail?
          DynHelper.nsklog.debug "ManageContent::!!RAISINGERROR!!"
          raise "ERROR-> ContentSync failed.."
        end
      end
      def finalize
        DynHelper.nsklog.debug "ManageContent::finalize"
      end
    end

    class AfterSubplanAction < Dynflow::Action
      def plan(content_skipped)
        DynHelper.nsklog.debug "AfterSubplanAction::plan"
        DynHelper.nsklog.debug "content_skipped -> #{content_skipped}"
        DynHelper.nsklog.debug "content_skipped.class -> #{content_skipped.class}"
        #plan_self content_skipped: content_skipped
        plan_self
      end
      def run
        DynHelper.nsklog.debug "AfterSubplanAction::run"
      end
      def finalize
        DynHelper.nsklog.debug "AfterSubplanAction::finalize"
      end
    end

  end
end

