RSpec.describe Claws::Rule::InheritedSecrets do
  before do
    load_detection
  end

  context "with default configuration" do
    it "flags a workflow that inherits all its caller's secrets" do
      violations = analyze(<<~YAML)
        on: [workflow_call]
        name: yea
        jobs:
          rake:
            runs-on: ubuntu-latest
            secrets: inherit
            steps:
              - name: Build
                run: rake
                env:
                  GITHUB_TOKEN: ${{ github.token }}
                  YOINK: ${{ secrets.FLAG }}
                  STATIC_STR: "yep"
                  STATIC_INT: 420
      YAML

      expect(violations.count).to eq(1)
      expect(violations[0].line).to eq(6)
      expect(violations[0].name).to eq("InheritedSecrets")
    end

    it "doesn't flag a workflow that doesn't inherit any secrets" do
      violations = analyze(<<~YAML)
        on: [workflow_call]
        name: yea
        jobs:
          rake:
            runs-on: ubuntu-latest
            steps:
              - name: Build
                run: rake
                env:
                  GITHUB_TOKEN: ${{ github.token }}
                  YOINK: ${{ secrets.FLAG }}
                  STATIC_STR: "yep"
                  STATIC_INT: 420
      YAML

      expect(violations.count).to eq(0)
    end
  end
end
