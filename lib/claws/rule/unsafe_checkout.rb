module Claws
  module Rule
    class UnsafeCheckout < BaseRule
      description <<~DESC
        This workflow checks out a user supplied branch, which could be risky if any code is executed using it.

        For more information:
        https://github.com/betterment/claws/blob/main/README.md#unsafecheckout
      DESC

      on_step %(
        contains_any($workflow.meta.triggers, $data.risky_events) &&
        $step.meta.action.name == "actions/checkout" &&
        (
          contains($step.with.ref, "github.event") ||
          contains($step.with.ref, "inputs.")
        )
      ), highlight: "with.ref"

      def data
        {
          "risky_events": risky_events
        }
      end

      private

      def risky_events
        configuration.fetch(
          "risky_events",
          %w[pull_request_target workflow_dispatch]
        )
      end
    end
  end
end
