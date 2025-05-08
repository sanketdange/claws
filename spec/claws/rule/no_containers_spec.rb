RSpec.describe Claws::Rule::NoContainers do
  before do
    load_detection
  end

  context "with default configuration" do
    it "flags a job that uses a container image" do
      violations = analyze(<<~YAML)
        name: CI

        on:
          push:
            branches: [ main ]

        jobs:
          container-test-job:
            runs-on: ubuntu-latest
            test:
              1
            container:
              image: node:14.16
            steps:
              - name: Say Hello
                run: echo hello...
      YAML

      expect(violations.count).to eq(1)
      expect(violations[0].line).to eq(13)
      expect(violations[0].name).to eq("NoContainers")
    end

    it "doesn't flag a job if it does nothing with containers" do
      violations = analyze(<<~YAML)
        name: CI

        on:
          push:
            branches: [ main ]

        jobs:
          container-test-job:
            steps:
              - name: Say Hello
                run: echo hello...
      YAML

      expect(violations.count).to eq(0)
    end

    it "flags a step that specifies a docker container for an action" do
      violations = analyze(<<~YAML)
        name: CI

        on:
          push:
            branches: [ main ]

        jobs:
          use_image:
            steps:
              - name: My first step
                uses: docker://alpine:3.8
      YAML

      expect(violations.count).to eq(1)
      expect(violations[0].line).to eq(11)
      expect(violations[0].name).to eq("NoContainers")
    end
  end

  context "with a custom configuration" do
    let(:configuration) do
      { "approved_images" => ["node:14.16", "docker://alpine:3.8"] }
    end

    before do
      load_detection
    end

    it "doesn't flag a job if it uses an approved image" do
      violations = analyze(<<~YAML)
        name: CI

        on:
          push:
            branches: [ main ]

        jobs:
          container-test-job:
            runs-on: ubuntu-latest
            test:
              1
            container:
              image: node:14.16
            steps:
              - name: Say Hello
                run: echo hello...
      YAML

      expect(violations.count).to eq(0)
    end

    it "doesn't flag a step if the image it uses is an approved one" do
      violations = analyze(<<~YAML)
        name: CI

        on:
          push:
            branches: [ main ]

        jobs:
          use_image:
            steps:
              - name: My first step
                uses: docker://alpine:3.8
      YAML

      expect(violations.count).to eq(0)
    end
  end
end
