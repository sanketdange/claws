module Claws
  module Rule
    class EmptyName < BaseRule
      description <<~DESC
        All workflows must have an easily identifiable name.

        For more information:
        https://github.com/betterment/claws/blob/main/README.md#emptyname
      DESC

      on_workflow "$workflow.name == null"
    end
  end
end
