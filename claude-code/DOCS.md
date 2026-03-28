# Home Assistant Add-on: Claude Code

This add-on runs [Claude Code][claude-code], Anthropic's CLI coding agent, inside
a container with a web terminal accessible from the Home Assistant dashboard. It
also runs `claude remote-control` automatically so you can connect and work from
your phone or any other device.

Supports both Claude Pro/Max subscriptions and API key authentication.

## Prerequisites: Network Storage

Set up your code directory as Network Storage in Home Assistant so the add-on
can access it:

1. Go to **Settings > System > Storage**
2. Click **Add Network Storage**
3. Configure:
   - **Name**: `code` (this determines the mount path inside add-ons)
   - **Server**: `192.168.2.5` (your Synology NAS IP)
   - **Usage**: Share
   - **Protocol**: NFS
   - **Remote share path**: `/volume1/code` (full NFS export path)
4. Click **Connect**

Your share will be available inside add-ons at `/share/code`.

**Note**: For NFS, make sure your Synology has an NFS permission rule for your
HA host IP (e.g. `192.168.2.6`) with Read/Write access on the shared folder.
(Synology: Control Panel > Shared Folder > Edit > NFS Permissions)

## Installation

1. Add this repository to your Home Assistant Add-on Store:

   [![Add Repository][repo-badge]][repo-add]

   Or manually add: `https://github.com/mekenthompson/hassio-addons`

2. Install **Claude Code** from the add-on store.
3. Configure the add-on (see Configuration below).
4. Start the add-on.
5. Click **OPEN WEB UI** to access the terminal.
6. Run `claude login` to authenticate with your Pro/Max subscription.
7. Remote-control will start automatically once logged in.

## Configuration

**Note**: _Restart the add-on after changing configuration._

### Example configuration

```yaml
auth_mode: subscription
workspace: /share/code
permission_mode: bypassPermissions
auto_start_remote_control: true
remote_workspaces:
  - /share/code/project-alpha
  - /share/code/project-beta
init_commands:
  - git config --global user.name "Ken"
  - git config --global user.email "ken@buildkite.com"
log_level: info
```

### Option: `auth_mode`

How Claude Code authenticates. Two options:

- **`subscription`** (default) - Use your Claude Pro or Max subscription. On first
  start, open the web terminal and run `claude login` to authenticate via OAuth.
  Your login tokens persist across restarts in `/data/claude-code/.claude/`.
- **`api_key`** - Use an Anthropic API key. Set `anthropic_api_key` below.

### Option: `anthropic_api_key`

Your Anthropic API key. Only needed when `auth_mode` is `api_key`.

### Option: `workspace`

The directory Claude Code uses as its working directory. Defaults to `/share/code`,
which maps to an HA Network Storage mount named "code" with usage type "Share".

You can point this at any directory available to the add-on (see Available
Directories below). If the directory does not exist, the add-on falls back to
`/homeassistant`.

### Option: `permission_mode`

Controls how Claude Code handles tool permissions for remote-control sessions
and the default mode for manual `claude` invocations. Options:

- **`bypassPermissions`** (default) - No prompts. Claude can use all tools
  (Bash, Edit, Write, MCP, etc.) without asking. Best for headless/server use.
- **`dontAsk`** - Similar to bypass but still respects deny rules in settings.
- **`acceptEdits`** - Auto-accepts file edits but prompts for shell commands.
- **`default`** - Prompts for dangerous operations.

All MCP tools (including ones added after boot) are automatically allowed
regardless of this setting.

### Option: `remote_workspaces`

A list of directories to run separate `claude remote-control` sessions in. Each
directory gets its own remote-control session, visible in claude.ai/code labeled
with the directory's name.

```yaml
remote_workspaces:
  - /share/code/project-alpha
  - /share/code/project-beta
  - /homeassistant
```

When empty (default), a single remote-control session runs in the `workspace`
directory. When populated, only the listed directories get remote-control sessions
(the `workspace` option is only used for the web terminal).

Each directory must exist and be accessible to the add-on (see Available
Directories below). Non-existent directories are skipped with a warning in the logs.

### Option: `auto_start_remote_control`

When `true` (default), the add-on automatically runs `claude remote-control` at
startup. This lets you connect from your phone or another device to interact with
Claude Code remotely.

In subscription mode, remote-control waits for you to complete `claude login`
before starting.

### Option: `init_commands`

Shell commands to run when the add-on starts. Useful for setting up git config
or installing additional tools.

### Option: `log_level`

Controls log verbosity. One of: `trace`, `debug`, `info`, `warning`, `error`, `fatal`.

## How It Works

The add-on runs two main services:

1. **Web Terminal (ttyd)** - Provides a browser-based terminal accessible via the
   HA sidebar. You can run `claude` commands directly here, or use it as a
   regular terminal for your code directory.

2. **Claude Remote Control** - Runs `claude remote-control` in the background,
   allowing you to connect from your phone or other devices and send tasks to
   Claude Code. If `remote_workspaces` is configured, a separate session runs
   for each directory, each labeled with the folder name in claude.ai/code.

The add-on also has full Home Assistant API and admin access, so Claude Code
can interact with your HA instance (read states, call services, manage add-ons)
via the `SUPERVISOR_TOKEN` environment variable.

## Available Directories

| Path | Description |
|------|-------------|
| `/share/code` | Your NAS code directory (via HA Network Storage, configurable) |
| `/homeassistant` | Home Assistant configuration directory |
| `/share` | Shared data accessible by all add-ons |
| `/media` | Media storage mounts |
| `/config` | Add-on specific configuration |
| `/ssl` | SSL certificates (read-only) |

## Troubleshooting

### Workspace directory not found

- Make sure Network Storage is configured and connected in HA (Settings > System > Storage)
- The mount name determines the path: a share named "code" with usage "Share" appears at `/share/code`
- For NFS: the remote share path must be the full export path (e.g. `/volume1/code` not just `code`)

### Claude Code reports authentication errors

**Subscription mode:**
- Open the web terminal and run `claude login`
- Follow the OAuth flow in your browser
- Your tokens persist across restarts, so you only do this once
- If tokens expire, run `claude login` again

**API key mode:**
- Make sure `anthropic_api_key` is set in the configuration
- Restart the add-on after changing the key

### Remote-control not working

- Check the add-on logs for connection details
- Ensure `auto_start_remote_control` is `true`
- In subscription mode, remote-control waits until you run `claude login`
- You need to authenticate via the Claude mobile app

## Support

- **Add-on Issues**: [GitHub Issues][addon-issues]
- **Claude Code Docs**: [Anthropic Documentation][claude-docs]

[addon-issues]: https://github.com/mekenthompson/hassio-addons/issues
[claude-code]: https://docs.anthropic.com/en/docs/claude-code
[claude-docs]: https://docs.anthropic.com/en/docs/claude-code
[repo-badge]: https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg
[repo-add]: https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fmekenthompson%2Fhassio-addons
