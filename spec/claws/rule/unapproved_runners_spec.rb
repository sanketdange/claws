RSpec.describe Claws::Rule::UnapprovedRunners do
  before do
    load_detection
  end

  context "with default configuration" do
    it "doesn't flag the use of ubuntu-latest" do
      violations = analyze(<<~YAML)
        name: introduce self

        on: push

        jobs:
          introductions:
            runs-on: ubuntu-latest
            steps:
              - name: say hello
                run: echo hello
      YAML

      expect(violations.count).to eq(0)
    end

    it "flags the use of anything else" do
      violations = analyze(<<~YAML)
        name: introduce self

        on: push

        jobs:
          introductions:
            runs-on: very-illegal-runner
            steps:
              - name: say hello
                run: echo hello
      YAML

      expect(violations.count).to eq(1)
      expect(violations[0].line).to eq(7)
      expect(violations[0].name).to eq("UnapprovedRunners")
    end
  end

  context "with a config that allows other runners" do
    let(:configuration) do
      { "allowed_runners" => ["very-illegal-runner"] }
    end

    before do
      load_detection
    end

    it "doesn't flag the other runner" do
      violations = analyze(<<~YAML)
        name: introduce self

        on: push

        jobs:
          introductions:
            runs-on: very-illegal-runner
            steps:
              - name: say hello
                run: echo hello
      YAML

      expect(violations.count).to eq(0)
    end
  end
end
