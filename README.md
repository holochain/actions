# actions
Actions for common tasks in Holochain repositories

## Mattermost notifier action

Reusable workflow: `.github/workflows/mattermost-notify.yml`

Inputs:
- `mattermost_url`: base URL for Mattermost (defaults to `https://chat.holochain.org`)
- `channel_id`: target Mattermost channel ID. This can be obtained by clicking the "(i)" icon at the top right of an open channel.
- `message`: message text to post

Secret:
- `MATTERMOST_PERSONAL_ACCESS_TOKEN`: Mattermost personal access token with permission to post in the channel.

Example usage:

```yaml
name: Notify Mattermost

on:
  workflow_dispatch:

jobs:
  notify:
    uses: holochain/actions/.github/workflows/mattermost-notify.yml@main
    with:
      mattermost_url: https://chat.example.com
      channel_id: your_channel_id
      message: Hello from GitHub Actions
    secrets:
      MATTERMOST_PERSONAL_ACCESS_TOKEN: ${{ secrets.MATTERMOST_PERSONAL_ACCESS_TOKEN }}
```
