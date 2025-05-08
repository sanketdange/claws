module Claws
  module Rule
    class InheritedSecrets < BaseRule
      description <<~DESC
        All workflows must explicitly state the secrets necessary for them to function properly.

        For more information:
        https://github.com/betterment/claws/blob/main/README.md#inheritedsecrets
      DESC

      on_job %(
        contains($workflow.meta.triggers, "workflow_call") &&
        $job.secrets == "inherit"
      ), highlight: "secrets"
    end
  end
end
