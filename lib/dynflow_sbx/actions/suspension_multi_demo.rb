Database = {}

module DynflowSbx
  module Actions
    class MultiExternalActionPlanner < Dynflow::Action
      Database = {}

      def plan
        DynHelper.nsklog.debug "############################################################"
        DynHelper.nsklog.debug "BasicAction::plan"

        sequence do
          plan_action BarChildAction, "pre-foo"

          plan_action ExternalFooChildAction, ['24', '25', '26']

          plan_action BarChildAction, "post-foo"
        end
      end
    end

    class ExternalFooChildAction < Base
      def plan(worker_ids)
        DynHelper.nsklog.debug "ExternalFooChildAction::plan"
        DynHelper.nsklog.debug "pworker ids #{worker_ids}"
        plan_self worker_ids: worker_ids
      end
      def run(event = nil)
        worker_ids = input[:worker_ids]

        case event
        when nil # First run
          DynHelper.nsklog.debug "ExternalFooChildAction:: first run"

          # Build worker manifest to track what work has completed
          worker_ids.each do |worker_id|
            Database[worker_id.to_s] = {
              completed: false,
            }
          end

          suspend do |suspended_action|
            worker_ids.each do |worker_id|
              external_worker = MockExternalWorker.new
              Database[worker_id.to_s][:worker] = external_worker
              external_worker.invoke(world, {
                sleepytime: rand(6),
                worker_id: worker_id,
                execution_plan_id: suspended_action.execution_plan_id,
                step_id: suspended_action.step_id
              })
            end
          end
        when Hash
          # Worker is reporting. Need to log the status update to the manifest
          # and then determine if we need to go back to sleep or we're done with
          # all outstanding work
          completed_worker_id = event.fetch(:worker_id).to_s
          DynHelper.nsklog.debug "Got completed worker id: #{completed_worker_id}"

          if output.key?(:completed_workers)
            output[:completed_workers] << completed_worker_id
          else
            output[:completed_workers] = [completed_worker_id]
          end

          # If all the workers have finished, we're done here, otherwise, go
          # back to sleep. Make sure to alert the outstanding workers of
          # new suspension handles
          outstanding_worker_ids = worker_ids - output[:completed_workers]

          unless outstanding_worker_ids.length == 0
            suspend do |suspended_action|
              outstanding_worker_ids.each do |id|
                Database[id][:worker].update_suspension(
                  suspended_action.execution_plan_id,
                  suspended_action.step_id,
                )
              end
            end
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
