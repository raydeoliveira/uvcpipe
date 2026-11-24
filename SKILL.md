---
name: uvcpipe
description: >-
  Cross-platform USB UVC HDMI capture, localhost live MJPEG viewer, and CH9329
  serial HID bare-metal keyboard/mouse CLI and stdio MCP server (macOS, Linux,
  Windows). Use when probing capture dongles or CH9329 cables, grabbing BIOS/OS
  HDMI frames (--format jpeg|ppm|base64), serving the 127.0.0.1 MJPEG viewer,
  sending HID keys/text/mouse input with --dry-run and SIGINT release-all safety,
  or invoking uvcpipe mcp tools.
---

# Skill: uvcpipe (`uvcpipe`)

## Install & Discovery
```bash
brew install raydeoliveira/tap/uvcpipe
# Or build from source:
make -C projects/uvcpipe release
# Inspect capability manifest and build metadata:
uvcpipe --describe
uvcpipe --version --json
uvcpipe --help --json
```

## Safe Probe, Capture & Live Viewer Workflow
1. Discover attached UVC dongles and CH9329 cables (or deterministic `--sim` / `--fixture` devices, always Free):
   ```bash
   uvcpipe probe --json
   uvcpipe probe --sim --json
   uvcpipe probe --device sim-uvc-0 --port sim-ch9329-0 --baud 9600 --sim --json
   ```
2. Grab a single frame to file (`lstat`-guarded atomic write) or base64 JSON:
   ```bash
   uvcpipe capture --sim --width 1280 --height 720 --format jpeg --out /tmp/frame.jpg --json
   uvcpipe capture --sim --format base64 --timeout-ms 5000 --json
   ```
3. Launch the localhost-only HTTP/1.1 live MJPEG viewer (`/` HTML5 page, `/stream.mjpeg`, `/frame.jpg`, `/status.json`):
   ```bash
   uvcpipe view --sim --bind 127.0.0.1 --port 0 --max-frames 30 --timeout-ms 5000 --json
   ```

## Safe Bare-Metal HID Workflow (CH9329)
1. Preview planned CH9329 Mode 0 hex frames first (`--dry-run` performs zero serial writes and requires no commercial license):
   ```bash
   uvcpipe key --keys f2 --modifiers lctrl --hold-ms 50 --sim --dry-run --json
   uvcpipe type --text "boot" --delay-ms 10 --sim --dry-run --json
   uvcpipe mouse --abs 640,360 --screen 1280,720 --button left --wheel 0 --sim --dry-run --json
   uvcpipe mouse --rel 12,-8 --button none --sim --dry-run --json
   ```
2. Execute live HID input from non-TTY agent pipelines with explicit `--yes`:
   ```bash
   uvcpipe key --keys enter --port /dev/ttyUSB0 --baud 9600 --yes --json
   ```
3. Immediately release all held keys and mouse buttons at any time (Free; alias `restore`):
   ```bash
   uvcpipe release-all --sim --yes --json
   uvcpipe restore --sim --dry-run --json
   ```

## Exact CLI Reference (Subcommands, Flags, Nuances)
- **Metadata flags** (mutually exclusive with subcommands; `--json` works with `--help`/`--version`; `--describe` emits JSON):
  - `--help` (`-h`), `--version` (`-V`), `--describe`
- **Global flags**: `--json`, `--sim`, `--fixture <path>` (`probe`, `capture`, `view`, `mcp` only), `--dry-run` (`key`, `type`, `mouse`, `release-all`/`restore`, `mcp` only), `--yes` (`key`, `type`, `mouse`, `release-all`/`restore` only).
- **Subcommands**:
  - `probe`: `[--device <id>] [--port <serial_path>] [--baud 9600|19200|38400|57600|115200] [--fixture <path>]`
  - `capture`: `[--device <id>] [--width <1..16384> --height <1..16384>] [--format jpeg|jpg|ppm|base64] [--out <path>] [--timeout-ms <1..3600000>] [--fixture <path>]` (`--width` and `--height` must be paired; `ppm` rejects MJPEG sources with exit `2`)
  - `view`: `[--device <id>] [--bind 127.0.0.1|localhost] [--port <0..65535>] [--width <w> --height <h>] [--max-frames <n>] [--timeout-ms <ms>] [--fixture <path>]`
  - `key`: `--keys <k1,k2,...>` `[--modifiers <m1,...>] [--hold-ms <0..60000>] [--port <serial>] [--baud <rate>] [--dry-run] [--yes]`
  - `type`: `--text <ascii_1..511>` `[--delay-ms <0..60000>] [--port <serial>] [--baud <rate>] [--dry-run] [--yes]`
  - `mouse`: `(--abs <x,y> --screen <w,h> | --rel <dx,dy>)` `[--button none|left|right|middle] [--wheel <-127..127>] [--port <serial>] [--baud <rate>] [--dry-run] [--yes]`
  - `release-all` (alias `restore`): `[--port <serial>] [--baud <rate>] [--dry-run] [--yes]`
  - `license`: `[status|activate|validate|deactivate] [--key <polar_key>] [--force]` (`--key` on `activate`/`validate` or via `UVCPIPE_LICENSE_KEY`; `--force` clears local cache when remote Polar deactivation is unreachable)
  - `mcp`: `[--sim] [--fixture <path>] [--dry-run]` (`--dry-run` forces `dry_run: true` for all MCP HID calls)

## Commercial Licensing (Polar.sh)
Checkout ($19 one-time, `UVCP` key prefix, 3 activations): <https://buy.polar.sh/polar_cl_ZYe4DgatGrujYxoXUQ80f2zwwuM71Jspoxdew1Iac1c>
```bash
uvcpipe license status --json
uvcpipe license activate --key UVCP-XXXX-XXXX-XXXX --json
uvcpipe license validate --json
uvcpipe license deactivate --json
uvcpipe license deactivate --force --json
```

## Native MCP Mode (`uvcpipe mcp`)
Newline-delimited JSON-RPC 2.0 on `stdin`/`stdout`, negotiating `protocolVersion` `"2025-03-26"` or `"2024-11-05"`, silent on notifications without `"id"`. Every `inputSchema` sets `additionalProperties: false`, sets MCP tool `annotations`, and all 4 HID tools default `dry_run` to `true`:

| Tool | Required Args | Optional Args & Defaults | Behavior |
|---|---|---|---|
| `uvcpipe_probe` | none | `sim`, `device`, `serial_port`, `baud` | Returns JSON text listing `uvc_devices` and `hid_devices`. |
| `uvcpipe_capture_frame` | none | `sim`, `device`, `width`, `height`, `format` (`"jpeg"`\|`"base64"`) | Returns `image` (`image/jpeg` base64) + `text` metadata JSON. |
| `uvcpipe_hid_key` | `keys` (`string[]`, 1..6) | `modifiers` (`string[]`), `hold_ms` (`0`), `serial_port`, `baud` (`9600`), `sim`, `dry_run` (`true`) | Sends or previews CH9329 keyboard chord + release. |
| `uvcpipe_hid_type` | `text` (`string`, 1..511) | `delay_ms` (`0`), `serial_port`, `baud` (`9600`), `sim`, `dry_run` (`true`) | Types printable US-ASCII text via CH9329. |
| `uvcpipe_hid_mouse` | `mode` (`"abs"`\|`"rel"`) | `x`, `y`, `screen_width`, `screen_height`, `dx`, `dy`, `button` (`"none"`), `wheel` (`0`), `serial_port`, `baud` (`9600`), `sim`, `dry_run` (`true`) | Dispatches absolute or relative mouse input. |
| `uvcpipe_hid_release_all` | none | `serial_port`, `baud` (`9600`), `sim`, `dry_run` (`true`) | Emits 3 CH9329 release-all packets (`0x02`, `0x04`, `0x05`). |

## Requirements, Environment Variables & Honest Limits
- **Environment**: `UVCPIPE_CONFIG_DIR` (directory containing `license.json` for commercial `capture`, `view`, live HID, and `mcp` modes; falls back to `XDG_CONFIG_HOME/uvcpipe`, `~/.config/uvcpipe`, or `%LOCALAPPDATA%\uvcpipe`), `UVCPIPE_LICENSE_KEY` (validated online via `/validate`), `UVCPIPE_POLAR_API_URL` (HTTPS or loopback HTTP override for Polar API), `UVCPIPE_NO_TCC_PROMPT=1` (macOS non-interactive Camera TCC fail-closed `exit 4`).
- **Limits**: Built and verified with `--sim`, `--fixture`, loopback HTTP/TCP mocks, PTY signals, and ASan/UBSan suites across macOS `arm64`, Linux `x86_64`, and Windows `x86_64` CI; physical USB UVC dongles and CH9329 cables require host OS camera/serial permissions.

## Exit Codes
- `0` ok | `1` runtime/I/O error | `2` usage/validation/non-TTY confirm required | `3` hardware unavailable | `4` OS permission or symlink (`lstat`) denied | `5` commercial license required/invalid (bypassed in `-DOSS_EDITION`) | `130` interrupted (`SIGINT`/`SIGTERM`) after HID release
