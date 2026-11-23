# Configure tmux

## Workflow

1. Resolve the target dev box, account, configuration file, and server. See **Target**.
2. Check **Prerequisites** on the target host.
3. Merge **Settings** into the user configuration file.
4. Apply the defaults to the selected server if it is running. See **Apply to a Running Server**.
5. Run **Verification** and report the config path, live result, and any reattach needed.

If the task does not map cleanly to these steps, use the native planning tool to build a step-by-step plan from the target host, config sources, and verification steps, then execute the plan.

## Target

Run on the requested host as the account that runs tmux. Use the requested configuration file or the user file loaded by the selected server. Use `tmux display-message -p '#{config_files}'` to inspect the loaded files and `tmux display-message -p '#{socket_path}'` to identify the server. Use the corresponding `-L` or `-S` option when the user selects a custom server.

For a new setup, use `~/.tmux.conf` unless the account already uses an XDG tmux config. Follow existing links and includes to the source that controls these defaults.

## Prerequisites

Check `tmux -V` for tmux 3.4 or later and confirm that `infocmp tmux-256color` succeeds. The hyperlink rule is for OSC 8-capable terminals that identify as `xterm-256color`, including VS Code.

## Settings

Use the following block for a new file. In an existing file, keep unrelated directives and comments. Reuse equivalent entries and update or add only the directives needed to produce these defaults. Check the order of any later assignments or included files that affect the same settings. Append missing terminal rules so other array entries are preserved.

```tmux
# Enable mouse scrolling, selection, and resizing.
set -g mouse on

# Use 256 colors inside tmux and enable true color for clients.
set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",*:RGB"

# Remove NO_COLOR from the tmux server's global environment.
set-environment -g -u NO_COLOR

# Forward OSC 8 hyperlinks to VS Code's terminal.
set -as terminal-features ',xterm-256color:hyperlinks'
```

## Apply to a Running Server

Set `tmux_socket` to the selected server's socket path. Use the commands below to apply just these settings to that server. If there is no running server, the saved file takes effect on next startup.

```sh
(
    set -e
    tmux_server() {
        tmux -N -S "$tmux_socket" "$@"
    }

    overrides=$(tmux_server show-options -sv terminal-overrides)
    features=$(tmux_server show-options -sv terminal-features)

    tmux_server set-option -g mouse on
    tmux_server set-option -g default-terminal tmux-256color
    tmux_server set-environment -g -u NO_COLOR
    if ! printf '%s\n' "$overrides" | grep -Fxq -- '*:RGB'; then
        tmux_server set-option -as terminal-overrides ',*:RGB'
    fi
    if ! printf '%s\n' "$features" | grep -Fxq -- 'xterm-256color:hyperlinks'; then
        tmux_server set-option -as terminal-features ',xterm-256color:hyperlinks'
    fi
)
```

## Verification

On the selected server, confirm `show-options -gv mouse` is `on` and `show-options -gv default-terminal` is `tmux-256color`. Check that `show-options -sv terminal-overrides` includes `*:RGB` and `show-options -sv terminal-features` includes `xterm-256color:hyperlinks`. The command `show-environment -g NO_COLOR` should report that the variable is absent. For a config-only run, check the saved directives and verify the settings block on a disposable server using a temporary socket.

For a fresh VS Code attachment, check that `tmux display-message -p '#{client_termfeatures}'` includes `hyperlinks`. A client already attached when the settings were applied picks up hyperlink support after detaching and reattaching.
