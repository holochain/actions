# actions
Actions for common tasks in Holochain repositories

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
        uses: holochain/actions/mattermost-notify@main
        with:
          mattermost_url: https://chat.example.com
          channel_id: your_channel_id
          message: Hello from GitHub Actions
          mattermost_personal_access_token: ${{ secrets.MATTERMOST_PERSONAL_ACCESS_TOKEN }}
```
