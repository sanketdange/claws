RSpec.describe Claws::Rule::SpecialPermissions do
  before do
    load_detection
  end

  context "with a default configuration" do
    it "flags workflows that write to packages" do
      violations = analyze(<<~YAML)
        name: Deploy

        on:
          push:
            branches:
            - main

        permissions:
          packages: write

        jobs:
          build:
            runs-on: ubuntu-latest
            steps:
              - uses: action/checkout@v3
              - name: push
                run: rake release
      YAML

      expect(violations.count).to eq(1)
      expect(violations[0].line).to eq(8)
      expect(violations[0].name).to eq("SpecialPermissions")
    end

    it "flags jobs that write to packages" do
      violations = analyze(<<~YAML)
        name: Deploy

        on:
          push:
            branches:
            - main

        jobs:
          build:
            runs-on: ubuntu-latest
            permissions:
              packages: write
            steps:
              - uses: action/checkout@v3
              - name: push
                run: rake release
      YAML

      expect(violations.count).to eq(1)
      expect(violations[0].line).to eq(11)
      expect(violations[0].name).to eq("SpecialPermissions")
    end
  end
end
