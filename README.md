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

## Mattermost notifier action

Composite action: `mattermost-notify/action.yml`

Inputs:
- `mattermost_url`: base URL for Mattermost (defaults to `https://chat.holochain.org`)
- `channel_id`: target Mattermost channel ID. This can be obtained by clicking the "(i)" icon at the top right of an open channel.
- `message`: message text to post
- `mattermost_personal_access_token`: Mattermost personal access token with permission to post in the channel.

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
