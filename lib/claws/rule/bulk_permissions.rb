module Claws
  module Rule
    class BulkPermissions < BaseRule
      description <<~DESC
        Permissions should be requested based on access required for a job to complete instead of in bulk.

        For more information:
        https://github.com/betterment/claws/blob/main/README.md#bulkpermissions
      DESC

      on_workflow %(
        $workflow.permissions in ["write-all", "read-all"]
      ), highlight: "permissions"

      on_job %(
        $job.permissions in ["write-all", "read-all"]
      ), highlight: "permissions"
    end
  end
end
