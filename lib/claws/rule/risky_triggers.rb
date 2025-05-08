module Claws
  module Rule
    class RiskyTriggers < BaseRule
      description <<~DESC
        This flags workflows that may be using risky triggers to execute.

        For more information:
        https://github.com/betterment/claws/blob/main/README.md#riskytriggers
      DESC

      on_workflow %(
        contains($data.triggers, $workflow.meta.triggers) ||
        contains_any($workflow.meta.triggers, $data.triggers)
      ), highlight: "on"

      def data
        {
          'triggers': risky_triggers
        }
      end

      private

      def risky_triggers
        configuration.fetch(
          "risky_triggers",
          %w[pull_request_target workflow_dispatch]
        )
      end
    end
  end
end
