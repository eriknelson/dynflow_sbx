module DynflowSbx
  class MockExternalWorker
    def invoke(world, kwargs)
      sleepytime = kwargs[:sleepytime]
      @execution_plan_id = kwargs[:execution_plan_id]
      @step_id = kwargs[:step_id]

      Thread.new do
        DynHelper.nsklog.debug "MockExternalWorker:: Doing #{sleepytime}s of work"
        sleep sleepytime

        DynHelper.nsklog.debug(
          "MockExternalWorker:: #{sleepytime}s of work done. Triggering world event")

        world.event @execution_plan_id, @step_id,
                    worker_id: kwargs[:worker_id]
      end
    end

    def update_suspension(execution_plan_id, step_id)
      @execution_plan_id = execution_plan_id
      @step_id = step_id
    end
  end
end
