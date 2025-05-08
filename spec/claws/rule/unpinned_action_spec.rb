RSpec.describe Claws::Rule::UnpinnedAction do
  before do
    load_detection
  end

  context "with default configuration" do
    it "flags reusable actions with no version" do
      violations = analyze(<<~YAML)
        name: CI

        on: push

        jobs:
          checkout:
            runs-on: ubuntu
            steps:
              - uses: actions/checkout
      YAML

      expect(violations.count).to eq(1)
      expect(violations[0].line).to eq(9)
      expect(violations[0].name).to eq("UnpinnedAction")
    end

    it "flags reusable actions set to main" do
      violations = analyze(<<~YAML)
        name: CI

        on: push

        jobs:
          checkout:
            runs-on: ubuntu
            steps:
              - uses: actions/checkout@main
      YAML

      expect(violations.count).to eq(1)
      expect(violations[0].line).to eq(9)
      expect(violations[0].name).to eq("UnpinnedAction")
    end

    it "flags reusable actions with tags" do
      violations = analyze(<<~YAML)
        name: CI

        on: push

        jobs:
          checkout:
            runs-on: ubuntu
            steps:
              - uses: actions/checkout@v3
      YAML

      expect(violations.count).to eq(1)
      expect(violations[0].line).to eq(9)
      expect(violations[0].name).to eq("UnpinnedAction")
    end

    it "flags reusable actions with a partial sha1 commit hash" do
      violations = analyze(<<~YAML)
        name: CI

        on: push

        jobs:
          checkout:
            runs-on: ubuntu
            steps:
              - uses: actions/checkout@c85c95e
      YAML

      expect(violations.count).to eq(1)
      expect(violations[0].line).to eq(9)
      expect(violations[0].name).to eq("UnpinnedAction")
    end

    it "doesn't flag reusable actions with a full sha1 commit hash" do
      violations = analyze(<<~YAML)
        name: CI

        on: push

        jobs:
          checkout:
            runs-on: ubuntu
            steps:
              - uses: actions/checkout@c85c95e3d7251135ab7dc9ce3241c5835cc595a9
      YAML

      expect(violations.count).to eq(0)
    end

    it "doesn't flag actions from the current repository" do
      violations = analyze(<<~YAML)
        name: CI

        on: push

        jobs:
          checkout:
            runs-on: ubuntu
            steps:
              - uses: ./.github/actions/something-useful.yml
      YAML

      expect(violations.count).to eq(0)
    end
  end

  context "with a config that allows specific authors" do
    let(:configuration) do
      { "trusted_authors" => ["actions"] }
    end

    before do
      load_detection
    end

    it "doesn't flag an unpinned action from a trusted author" do
      violations = analyze(<<~YAML)
        name: CI

        on: push

        jobs:
          checkout:
            runs-on: ubuntu
            steps:
              - uses: actions/checkout
      YAML

      expect(violations.count).to eq(0)
    end

    it "still flags authors not on the list" do
      violations = analyze(<<~YAML)
        name: CI

        on: push

        jobs:
          checkout:
            runs-on: ubuntu
            steps:
              - uses: maybemalware/maybenot
      YAML

      expect(violations.count).to eq(1)
      expect(violations[0].line).to eq(9)
      expect(violations[0].name).to eq("UnpinnedAction")
    end
  end
end
