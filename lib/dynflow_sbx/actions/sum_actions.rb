module DynflowSbx
  module Actions

    class SumNumbers < Dynflow::Action
      def plan(numbers)
        DynHelper.nsklog.debug "SumNumbers::plan"
        plan_self numbers: numbers
      end
      def run
        # Looks like finalize actually isn't called at all if the task
        # doesn't define a run phase.
        DynHelper.nsklog.debug "SumNumbers::run"
        output.update sum: input[:numbers].reduce(&:+)
      end
      def finalize
        DynHelper.nsklog.debug "SumNumbersAction::finalize"
      end
    end

    class SumManyNumbers < Dynflow::Action
      def plan(numbers)
        DynHelper.nsklog.debug "############################################################"
        DynHelper.nsklog.debug "SumManyNumbers::plan"

        # Refs to planned actions
        planned_sub_sum_actions = numbers.each_slice(10).map do |numbers|
          plan_action SumNumbers, numbers
        end
        DynHelper.nsklog.debug "Got planned_sub_sum_actions"

        # Prepare array of output refs where each points to sum in the
        # output of particular action
        sub_sums = planned_sub_sum_actions.map do |action|
          action.output[:sum]
        end

        DynHelper.nsklog.debug "Got sub_sums"

        # One final planned action which will sum the sub_sums
        # Depends on all planned_sub_sum_actions because it uses their outputs
        final_one = plan_action SumNumbers, sub_sums

        #plan_action SumNumbers, [ final_one.output[:sum], 14 ] # Extra test
      end
    end

  end
end

