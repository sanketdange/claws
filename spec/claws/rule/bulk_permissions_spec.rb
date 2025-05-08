RSpec.describe Claws::Rule::BulkPermissions do
  before do
    load_detection
  end

  context "at the workflow level" do
    it "flags workflows that have write-all" do
      violations = analyze(<<~YAML)
        name: Deploy

        on:
          push:
            branches:
            - main

        permissions: write-all

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
      expect(violations[0].name).to eq("BulkPermissions")
    end

    it "flags workflows that have read-all" do
      violations = analyze(<<~YAML)
        name: Deploy

        on:
          push:
            branches:
            - main

        permissions: read-all

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
      expect(violations[0].name).to eq("BulkPermissions")
    end

    it "does not flag a workflow that specifies no permissions" do
      violations = analyze(<<~YAML)
        name: Deploy

        on:
          push:
            branches:
            - main

        jobs:
          build:
            runs-on: ubuntu-latest
            steps:
              - uses: action/checkout@v3
              - name: push
                run: rake release
      YAML

      expect(violations.count).to eq(0)
    end

    it "does not flag a workflow that has a specific permission" do
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

      expect(violations.count).to eq(0)
    end
  end

  context "at the job level" do
    it "flags jobs that have write-all" do
      violations = analyze(<<~YAML)
        name: Deploy

        on:
          push:
            branches:
            - main

        jobs:
          build:
            runs-on: ubuntu-latest
            permissions: write-all
            steps:
              - uses: action/checkout@v3
              - name: push
                run: rake release
      YAML

      expect(violations.count).to eq(1)
      expect(violations[0].line).to eq(11)
      expect(violations[0].name).to eq("BulkPermissions")
    end

    it "flags jobs that have read-all" do
      violations = analyze(<<~YAML)
        name: Deploy

        on:
          push:
            branches:
            - main

        jobs:
          build:
            runs-on: ubuntu-latest
            permissions: read-all
            steps:
              - uses: action/checkout@v3
              - name: push
                run: rake release
      YAML

      expect(violations.count).to eq(1)
      expect(violations[0].line).to eq(11)
      expect(violations[0].name).to eq("BulkPermissions")
    end

    it "does not flag a job that specifies no permissions" do
      violations = analyze(<<~YAML)
        name: Deploy

        on:
          push:
            branches:
            - main

        jobs:
          build:
            runs-on: ubuntu-latest
            steps:
              - uses: action/checkout@v3
              - name: push
                run: rake release
      YAML

      expect(violations.count).to eq(0)
    end

    it "does not flag a job that has a specific permission" do
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

      expect(violations.count).to eq(0)
    end
  end
end
