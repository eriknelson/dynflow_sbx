module DynflowSbx
  class MockExternalWorker
    def invoke(invoker, sleepytime)
      DynHelper.nsklog.debug "MockExternalWorker::invoke"

      Thread.new do
        DynHelper.nsklog.debug "MockExternalWorker:: Doing #{sleepytime}s of work"
        sleep sleepytime
        DynHelper.nsklog.debug(
          "MockExternalWorker:: #{sleepytime}s of work done. Triggering invoker")
        invoker << :done
      end
    end
  end
end
