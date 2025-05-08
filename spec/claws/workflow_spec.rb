RSpec.describe Workflow do
  context "trigger normalizing" do
    it "a hash of triggers remains untouched" do
      workflow = described_class.load(<<~YAML)
        on:
          pull_request:
          push:
            branches: main

        jobs:
          deploy:
            steps:
              - id: merge this pull request
                name: automerge
                uses: "pascalgn/automerge-action@v0.15.5"
      YAML

      expect(workflow.meta["triggers"]).to eq(%w[pull_request push])
    end

    it "an array of triggers remains untouched" do
      workflow = described_class.load(<<~YAML)
        on: [pull_request, pull_request_target]

        jobs:
          deploy:
            steps:
              - id: merge this pull request
                name: automerge
                uses: "pascalgn/automerge-action@v0.15.5"
      YAML

      expect(workflow.meta["triggers"]).to eq(%w[pull_request pull_request_target])
    end

    it "a single string is normalized to an array" do
      workflow = described_class.load(<<~YAML)
        on:
          pull_request

        jobs:
          deploy:
            steps:
              - id: merge this pull request
                name: automerge
                uses: "pascalgn/automerge-action@v0.15.5"
      YAML

      expect(workflow.meta["triggers"]).to eq(["pull_request"])
    end
  end
end
