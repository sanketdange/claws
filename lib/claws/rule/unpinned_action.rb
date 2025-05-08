module Claws
  module Rule
    class UnpinnedAction < BaseRule
      description <<~DESC
        All reusable actions must be pinned to a full sha1 commit hash.

        For more information:
        https://github.com/betterment/claws/blob/main/README.md#unpinnedaction
      DESC

      on_step %(
        $step.meta.action != null &&
        (
          $step.meta.action.version == null ||
          !($step.meta.action.version =~ "^[a-fA-F0-9]{40}$")
        ) &&
        !contains($data.trusted_authors, $step.meta.action.author) &&
        !$step.meta.action.local
      ), highlight: "uses"

      def data
        {
          "trusted_authors": configuration.fetch("trusted_authors", [])
        }
      end
    end
  end
end
