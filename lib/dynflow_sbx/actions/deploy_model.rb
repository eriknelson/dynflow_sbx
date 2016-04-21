module DynflowSbx
  module Actions

    class BaseAction < Dynflow::Action
      def plan
        DynHelper.nsklog.debug "#{self.class.name}::plan"
        super if exec_super_plan?
      end
      def run
        DynHelper.nsklog.debug "#{self.class.name}::run"
      end
      def finalize
        DynHelper.nsklog.debug "#{self.class.name}::finalize"
      end
      def exec_super_plan?
        true
      end
    end

    class BaseActionWithSubPlans < BaseAction
      include Dynflow::Action::WithSubPlans
      def create_sub_plans
        DynHelper.nsklog.debug "#{self.class.name}::create_sub_plans"
        super
      end
    end

    class DeployModel < BaseAction
      def plan
        DynHelper.nsklog.debug(
          "############################################################")
        plan_root_directly
        #plan_root_as_subplan
      end
      def plan_root_as_subplan
        plan_action FusorRootWrapperAsSubPlan
      end
      def plan_root_directly
        plan_action FusorRootWrapper
      end
    end

    class FusorRootWrapperAsSubPlan < BaseActionWithSubPlans
      def create_sub_plans
        trigger FusorRootWrapper
      end
    end

    class FusorRootWrapper < BaseAction
      def plan
        super
        sequence do
          plan_action ManageContentAsSubPlan
          concurrence do
            plan_action DeployAction
            plan_action DeployAction
          end
        end
      end
      def exec_super_plan?
        false
      end
    end

    class ManageContentAsSubPlan < BaseActionWithSubPlans
      def create_sub_plans
        trigger ManageContent
      end
    end

    class ManageContent < BaseAction
      def plan
        plan_action SyncRepositories
      end
      def exec_super_plan?
        false
      end
      def rescue_strategy_for_self
        DynHelper.nsklog.debug "rescue_strategy_for_self"
        Dynflow::Action::Rescue::Skip
      end
    end

    class SyncRepositories < BaseAction
      def plan
        (1..6).each{|i| plan_action SyncRepositoryAsSubPlan, i}
      end
      def exec_super_plan?
        false
      end
    end

    class SyncRepositoryAsSubPlan < BaseActionWithSubPlans
      def plan(repo_id)
        plan_self repo_id: repo_id
      end
      def create_sub_plans
        trigger KatelloSync, input[:repo_id]
      end
      def exec_super_plan?
        false
      end
    end

    class KatelloSync < BaseAction
      def plan(repo_id)
        DynHelper.nsklog.debug "KatelloSync::plan repo_id-> #{repo_id}"
        plan_self repo_id: repo_id
      end
      def run
        DynHelper.nsklog.debug "KatelloSync::run repo_id-> #{input[:repo_id]}"
        if input[:repo_id] == 3
          DynHelper.nsklog.debug "Blowing up repo 3..."
          raise "Katello blew up syncing #{input[:repo_id]}"
        end
      end
    end

    class DeployAction < BaseAction
    end

  end
end

