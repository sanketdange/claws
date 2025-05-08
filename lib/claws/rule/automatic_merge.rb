module Claws
  module Rule
    class AutomaticMerge < BaseRule
      description <<~DESC
        This workflow automatically merges user-supplied pull requests.
        Please review the workflow to ensure this is necessary and its logic is sound.

        For more information:
        https://github.com/betterment/claws/blob/main/README.md#automaticmerge
      DESC

      on_step %(
        contains_any($workflow.meta.triggers, $data.pr_events) && (
          $step.run =~ "gh\s*pr\s*merge"
        )
      ), highlight: "run"

      on_step %(
        contains_any($workflow.meta.triggers, $data.pr_events) && (
          $step.meta.action.name in $data.automerge_actions
        )
      ), highlight: "uses"

      def data
        {
          "automerge_actions":
            configuration.fetch("automerge_actions", default_automerge_actions),
          "pr_events":
            configuration.fetch("pr_events", default_pr_events)
        }
      end

      private

      def default_pr_events
        %w[
          push pull_request_target pull_request
          pull_request_comment pull_request_review
          pull_request_review_comment workflow_dispatch
          workflow_call
        ]
      end

      def default_automerge_actions
        ["reitermarkus/automerge", "pascalgn/automerge-action"]
      end
    end
  end
end
