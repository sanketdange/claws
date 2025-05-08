RSpec.describe Claws::Rule::AutomaticMerge do
  before do
    load_detection
  end

  context "with default configuration" do
    it "flags a step that uses an automerge action" do
      violations = analyze(<<~YAML)
        name: Automerge via Github Action

        on:
          pull_request

        jobs:
          deploy:
            steps:
              - id: merge this pull request
                name: automerge
                uses: "pascalgn/automerge-action@v0.15.5"
      YAML

      expect(violations.count).to eq(1)
      expect(violations[0].line).to eq(11)
      expect(violations[0].name).to eq("AutomaticMerge")
    end

    it "flags a step that uses the CLI to merge a PR" do
      violations = analyze(<<~YAML)
        name: Automerge Non-code Changes

        on:
          - pull_request

        jobs:
          merge:
            runs-on: ubuntu-latest
            steps:
              - name: Merge Pull Request
                run: gh pr merge $PR --squash --auto --delete-branch
                env:
                  PR: ${{ github.event.issue.number }}
      YAML

      expect(violations.count).to eq(1)
      expect(violations[0].line).to eq(11)
      expect(violations[0].name).to eq("AutomaticMerge")
    end

    it "doesn't flag a step for using an unrelated action" do
      violations = analyze(<<~YAML)
        name: Something Else via Github Action

        on:
          - pull_request

        jobs:
          deploy:
            steps:
              - id: say hello
                name: automerge
                uses: "nonsense/hello@v1"
      YAML

      expect(violations.count).to eq(0)
    end

    it "doesn't flag a step for doing something unrelated with the CLI" do
      violations = analyze(<<~YAML)
        name: Automerge Non-code Changes

        on:
          - pull_request

        jobs:
          merge:
            runs-on: ubuntu-latest
            steps:
              - name: Comment on Pull Request
                run: gh pr comment $PR --body "great job"
                env:
                  PR: ${{ github.event.issue.number }}
      YAML

      expect(violations.count).to eq(0)
    end
  end

  context "with a custom configuration" do
    let(:configuration) { { "automerge_actions" => ["nonsense/hello"] } }

    it "flags a step that uses an automerge action" do
      violations = analyze(<<~YAML)
        name: Something Else via Github Action

        on:
          - pull_request

        jobs:
          deploy:
            steps:
              - id: say hello
                name: automerge
                uses: "nonsense/hello@v1"
      YAML

      expect(violations.count).to eq(1)
    end
  end
end
