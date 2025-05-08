RSpec.describe Claws::Rule::UnsafeCheckout do
  before do
    load_detection
  end

  context "with default configuration" do
    it "flags unsafe dispatches leading to RCE" do
      violations = analyze(<<~YAML)
        name: Unsafe Workflow Dispatch that Leads to RCE

        # while only maintainers can pull this attack off
        # workflow_dispatch doesn't leave as visible a
        # paper trail like pull_request would
        on:
          workflow_dispatch:
            inputs:
              branch:
                description: 'Which branch to test?'
                required: true

        jobs:
          build:
            name: Build
            runs-on: ubuntu-latest
            steps:
            # check out the attacker controlled branch with their code
            - uses: actions/checkout@v2
              with:
                ref: ${{ github.event.inputs.branch }}

            # set up the environment and run specs
            # because Rakefile comes from the attacker's branch
            # we end up executing their code, even though they don't
            # control the command here
            - run: |
                rake setup
                rake spec
      YAML

      expect(violations.count).to eq(1)
      expect(violations[0].line).to eq(21)
      expect(violations[0].name).to eq("UnsafeCheckout")
    end

    it "flags unsafe checkouts leading to RCE" do
      violations = analyze(<<~YAML)
        name: Unsafe Checkout that Leads to RCE

        on: [pull_request_target]

        jobs:
          build:
            name: Build
            runs-on: ubuntu-latest
            steps:
            # check out the attacker controlled branch with their code
            - uses: actions/checkout@v2
              with:
                ref: ${{ github.event.pull_request.head.sha }}

            # set up the environment and run specs
            # because Rakefile comes from the attacker's branch
            # we end up executing their code, even though they don't
            # control the command here
            - run: |
                rake setup
                rake spec
      YAML

      expect(violations.count).to eq(1)
      expect(violations[0].line).to eq(13)
      expect(violations[0].name).to eq("UnsafeCheckout")
    end

    it "flags unsafe checkouts leading to info leaks" do
      violations = analyze(<<~YAML)
        name: Unsafe Checkout that can Leak Info

        on: pull_request_target

        jobs:
          release:
            runs-on: ubuntu-latest
            steps:
            # check out the attacker controlled branch
            - name: Checkout
              uses: actions/checkout@v3
              with:
                ref: ${{ github.event.pull_request.head.sha }}

            # grab the version number from the VERSION file
            # however... because we're getting the contents of the file
            # from the attacker's branch, and because git allows symlinks
            # the attacker can symlink VERSION to any other file on the system
            # to leak its contents.
            - name: Get PR Version
              id: version_number
              run: echo "::set-output name=version::$(cat VERSION)"

            # Dump the version number into a Github comment for everyone to see
            - name: Comment the new version
              uses: peter-evans/create-or-update-comment@v2
              with:
                issue-number: ${{ github.event.pull_request.number }}
                comment-author: 'github-actions[bot]'
                body: |
                  Version was updated to
                  ```${{ steps.version_number.outputs.version }}```
                  bye now...
      YAML

      expect(violations.count).to eq(1)
      expect(violations[0].line).to eq(13)
      expect(violations[0].name).to eq("UnsafeCheckout")
    end

    it "ignores unsafe checkouts for relatively safe triggers" do
      violations = analyze(<<~YAML)
        name: Unsafe Checkout that Leads to RCE

        # only maintainers can pull off this attack
        # they wouldn't do that though, would they?
        on: [pull_request]

        jobs:
          build:
            name: Build
            runs-on: ubuntu-latest
            steps:
            # check out the user supplied branch with their code
            - uses: actions/checkout@v2
              with:
                ref: ${{ github.event.pull_request.head.sha }}

            # set up the environment and run specs
            # because Rakefile comes from the attacker's branch
            # we end up executing their code, even though they don't
            # control the command here
            - run: |
                rake setup
                rake spec
      YAML

      expect(violations.count).to eq(0)
    end
  end

  context "with a custom list of unsafe triggers" do
    let(:configuration) do
      { "risky_events" => ["pull_request"] }
    end

    before do
      load_detection
    end

    it "ignores unsafe checkouts for relatively safe triggers" do
      violations = analyze(<<~YAML)
        name: Unsafe Checkout that Leads to RCE

        # maybe because the way your org uses github, maintainers
        # are not automatically excluded from the risk.
        # so let's flag this too.
        on: [pull_request]

        jobs:
          build:
            name: Build
            runs-on: ubuntu-latest
            steps:
            # check out the user supplied branch with their code
            - uses: actions/checkout@v2
              with:
                ref: ${{ github.event.pull_request.head.sha }}

            # set up the environment and run specs
            # because Rakefile comes from the attacker's branch
            # we end up executing their code, even though they don't
            # control the command here
            - run: |
                rake setup
                rake spec
      YAML

      expect(violations.count).to eq(1)
      expect(violations[0].line).to eq(16)
      expect(violations[0].name).to eq("UnsafeCheckout")
    end
  end
end
