module Claws
  module Rule
    class UnapprovedRunners < BaseRule
      description <<~DESC
        This workflow is using an unapproved runner.

        For more information:
        https://github.com/betterment/claws/blob/main/README.md#unapprovedrunners
      DESC

      on_job %(
        $job.runs_on != null && !contains($data.allowed_runners, $job.runs_on)
      ), highlight: "runs_on"

      def data
        {
          'allowed_runners': allowed_runners
        }
      end

      private

      def allowed_runners
        configuration.fetch(
          "allowed_runners",
          %w[ubuntu-latest]
        )
      end
    end
  end
end
