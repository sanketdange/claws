module Claws
  module Rule
    class NoContainers < BaseRule
      description <<~DESC
        This job uses non-standard container images.

        For more information:
        https://github.com/betterment/claws/blob/main/README.md#nocontainers
      DESC

      on_job %(
        $job.meta.container != null &&
        !contains($data.approved_images, $job.meta.container.full)
      ), highlight: "container.image"

      on_step %(
        $step.uses =~ "^docker://" &&
        !contains($data.approved_images, $step.uses)
      ), highlight: :uses

      def data
        {
          'approved_images': configuration.fetch("approved_images", [])
        }
      end
    end
  end
end
