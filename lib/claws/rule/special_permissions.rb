module Claws
  module Rule
    class SpecialPermissions < BaseRule
      # Unfortunately because `highlight` is a static key, we can't
      # dynamically highlight the specific, problematic permission.
      #
      # This means ignoring SpecialPermissions will ignore any new
      # special permissions that might be added at a later date.
      description <<~DESC
        Confirm whether this job needs these write permissions.

        For more information:
        https://github.com/betterment/claws/blob/main/README.md#specialpermissions
      DESC

      on_workflow %(
        count(intersection($workflow.meta.permissions.write, $data.sensitive_writes)) > 0
      ), highlight: "permissions"

      on_job %(
        count(intersection($job.meta.permissions.write, $data.sensitive_writes)) > 0
      ), highlight: "permissions"

      def data
        {
          sensitive_writes: %w[
            checks
            id-token
            packages
            security-events
            statuses
          ]
        }
      end
    end
  end
end
