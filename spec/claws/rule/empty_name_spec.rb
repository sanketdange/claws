RSpec.describe Claws::Rule::EmptyName do
  before do
    load_detection
  end

  context "with default configuration" do
    let(:configuration) { "omar" }

    it "flags a workflow with a missing name" do
      violations = analyze(<<~YAML)
        on: push
        jobs:
          build:
            steps:
              - name: executes a bogus command
                id: command
                run: echo hello world
      YAML

      expect(violations.count).to eq(1)
      expect(violations[0].line).to eq(0)
      expect(violations[0].name).to eq("EmptyName")
    end

    it "does not flag a workflow if it has a name" do
      violations = analyze(<<~YAML)
        name: cool workflow!
        on: push
        jobs:
          build:
            steps:
              - name: executes a bogus command
                id: command
                run: echo hello world
      YAML

      expect(violations.count).to eq(0)
    end
  end
end
