RSpec.describe Claws::Rule::RiskyTriggers do
  before do
    load_detection
  end

  context "with default configuration" do
    it "flags workflows that use pull_request_target" do
      violations = analyze(<<~YAML)
        name: yea

        on: pull_request_target

        jobs:
          rake:
            runs-on: ubuntu-latest
            steps:
              - name: Build
                run: echo Building :)
      YAML

      expect(violations.count).to eq(1)
      expect(violations[0].line).to eq(3)
      expect(violations[0].name).to eq("RiskyTriggers")
    end

    it "doesn't flag unrelated workflows" do
      violations = analyze(<<~YAML)
        name: yea

        on: pull_request

        jobs:
          rake:
            runs-on: ubuntu-latest
            steps:
              - name: Build
                run: echo Building :)
      YAML

      expect(violations.count).to eq(0)
    end
  end

  context "with a custom configuration" do
    let(:configuration) { { "risky_triggers" => ["milestone"] } }
    before do
      load_detection
    end

    it "doesn't flag uses of pull_request_target if it's not on the list" do
      violations = analyze(<<~YAML)
        name: yea

        on: pull_request_target

        jobs:
          rake:
            runs-on: ubuntu-latest
            steps:
              - name: Build
                run: echo Building :)
      YAML

      expect(violations.count).to eq(0)
    end

    it "flags workflows that use triggers from our configuration" do
      violations = analyze(<<~YAML)
        name: yea

        on: milestone

        jobs:
          rake:
            runs-on: ubuntu-latest
            steps:
              - name: Build
                run: echo wow,
      YAML

      expect(violations.count).to eq(1)
      expect(violations[0].line).to eq(3)
      expect(violations[0].name).to eq("RiskyTriggers")
    end
  end
end
