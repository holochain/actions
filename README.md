# actions

Actions for common tasks in Holochain repositories

## Referencing actions and workflows

All actions and reusable workflows in this repo can be referenced with three
levels of stability:

| Ref | Example | Behaviour |
| --- | --- | --- |
| `@main` | `holochain/actions/mattermost-notify@main` | Latest development state. May include unreleased or breaking changes. |
| `@stable` | `holochain/actions/mattermost-notify@stable` | Latest stable release. Moves forward on each new release. |
| `@vX.Y.Z` | `holochain/actions/mattermost-notify@v1.15.0` | A specific release. Never changes. |

For use in production, pin to a specific version tag or `@stable`.

## Release process

Releases are created by running the
[Release Actions](https://github.com/holochain/actions/actions/workflows/release-actions.yml)
workflow from the `main` branch. Provide the new version number (e.g. `1.15.0`)
as the input.

The workflow will:

1. Reset the `stable` branch to the current state of `main`
2. Replace all internal `@main` action references with `@vX.Y.Z`
3. Commit and force-push the `stable` branch
4. Create a GitHub release (which also creates the version tag)

> [!Important]
> Internal action refs in `.github/workflows/` must always use `@main` on
> development branches. The PR check enforces this. The release workflow
> handles pinning them to the release version.

<!-- -->

> [!Warning]
> The `stable` branch is reset to `main` upon every release meaning that it
> does not contain a history of all releases. Instead, each release is kept by
> the tag reference. Because of this, no manual changes should be made to the
> `stable` branch as they will be dropped on the next release.

## Node.js release process

This repo provides two reusable workflows for releasing Node.js packages.
They implement a two-step process:

1. Prepare a release PR that bumps the version and generates the changelog
   using git-cliff.
1. Publishes the release as an npm package and GitHub release once the prepare
   release PR is merged.

### Reusable workflows

#### `nodejs-prepare-release`

Determines the next version (via [git-cliff](https://git-cliff.org/) or a
manual override), bumps the versions of all packages, generates a changelog,
and opens a release PR with the `hra-release` label.

```yaml
jobs:
  prepare:
    uses: holochain/actions/.github/workflows/nodejs-prepare-release.yml@stable
    with:
      # required: URL to the git-cliff config to use, the usual one for Holochain projects is
      cliff_config_url: https://raw.githubusercontent.com/holochain/release-integration/refs/heads/main/pre-1.0-cliff.toml
      # force_version: "1.2.3"    # optional: skip version auto-detection and set version to this
      # node_version: "24"        # default: 24
      # package_manager: "npm"    # default: npm. One of: npm, yarn, pnpm
      # install_deps: false       # default: false. Required by some process such as napi-rs projects
    secrets:
      GH_TOKEN: ${{ secrets.GH_TOKEN }} # Used to create the PR and trigger the CI workflows so must not use the default GitHub token.
```

#### `nodejs-publish-release`

Runs on every push to `main`. If the triggering commit came from a PR with the
`hra-release` label, it installs dependencies, builds, publishes to npm, and
creates a GitHub release. Non-release merges are skipped automatically.

```yaml
on:
  push:
    branches: [main]

jobs:
  publish:
    uses: holochain/actions/.github/workflows/nodejs-publish-release.yml@stable
    with:
      # node_version: "24"         # default: 24
      # package_manager: "npm"    # default: npm. One of: npm, yarn, pnpm
      # build_script: "build"      # default: build
      # workspace_main_package: "packages/pkg-1/package.json"  # required for workspace projects
    secrets:
      NPM_TOKEN: ${{ secrets.NPM_TOKEN }}  # omit if using npm Trusted Publishers
```

Pre-release versions (those containing a `-` in the version string, e.g.
`1.0.0-alpha.1`) are published with the `next` tag on npm and marked as
pre-releases on GitHub.

### Using the individual actions

For more complex workflows, the underlying composite actions can be used directly:

- `holochain/actions/nodejs-setup@stable` — validates the package manager and
  sets up Node.js, optionally installing dependencies
- `holochain/actions/nodejs-build@stable` — runs the build script
- `holochain/actions/nodejs-publish@stable` — checks the version, creates the
  GitHub release, and publishes to npm

### Workspace assumptions

> [!Important]
> Currently, only npm is supported as the package manager for workspace projects.

- **Root `package.json` required**: the workspace must have a root
  `package.json` with a `workspaces` field so the tooling can detect that it is
  a workspace project.
- **`workspace_main_package`**: the path to one package's `package.json` (e.g.
  `packages/pkg-1/package.json`) must be provided. This package's `name` and
  `version` are used to check whether the release has already been published to
  npm.
- **Shared version**: all packages in the workspace are expected to share the
  same version. The prepare workflow bumps all packages to the same version
  using `npm version --workspaces <version-number>`.

## Mattermost notifier action

Composite action: `mattermost-notify/action.yml`

Inputs:

- `mattermost_url`: base URL for Mattermost (defaults to `https://chat.holochain.org`)
- `channel_id`: target Mattermost channel ID. This can be obtained by
  clicking the "(i)" icon at the top right of an open channel.
- `message`: message text to post
- `mattermost_personal_access_token`: Mattermost personal access token
  with permission to post in the channel.

Example usage:

```yaml
name: Notify Mattermost

on:
  workflow_dispatch:

jobs:
  notify:
    runs-on: ubuntu-latest
    steps:
      - name: Send Mattermost message
        uses: holochain/actions/mattermost-notify@stable
        with:
          mattermost_url: https://chat.example.com
          channel_id: your_channel_id
          message: Hello from GitHub Actions
          mattermost_personal_access_token: ${{ secrets.MATTERMOST_PERSONAL_ACCESS_TOKEN }}
```
