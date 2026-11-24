# uvcpipe

> **Product Hub:** [raymonddeoliveira.com/software#uvcpipe](https://www.raymonddeoliveira.com/software#uvcpipe) · **Buy uvcpipe Pro ($19):** [Polar Checkout](https://buy.polar.sh/polar_cl_ZYe4DgatGrujYxoXUQ80f2zwwuM71Jspoxdew1Iac1c) · **Glama MCP:** [glama.ai/mcp/servers/raydeoliveira/uvcpipe](https://glama.ai/mcp/servers/raydeoliveira/uvcpipe) · **Official MCP Registry:** [io.github.raydeoliveira/uvcpipe](https://registry.modelcontextprotocol.io/v0.1/servers?search=raydeoliveira/uvcpipe) · **Free Core:** `brew install raydeoliveira/tap/uvcpipe`

Clean-room C17 CLI, localhost live MJPEG viewer, and stdio MCP server for USB UVC HDMI capture dongles (MS2109/MS2130, ShadowCast, Cam Link) and CH9329 USB-serial HID cables across macOS, Linux, and Windows.

Measured stripped release sizes and cold start: **230,528 bytes (~225 KB)** on macOS `arm64` (**19.45 ms** average `--version` cold start across 10 runs) and **207,056 bytes (~202 KB)** on Linux `x86_64`, with zero third-party runtime dependencies.

## What It Does / What It Does Not Do

| Capability | Supported | Notes / Limits |
|---|---|---|
| UVC discovery & capture (`probe`, `capture`) | Yes | AVFoundation (macOS `activeFormat` timing lock), V4L2 `/dev/video*` MJPEG/YUYV/RGB24 (Linux), Media Foundation MJPEG/YUY2/BGR24->RGB24 (Windows), plus deterministic `--sim` and `--fixture` (JPEG / P6 PPM `<= 32 MiB`). Outputs `jpeg`, `ppm` (uncompressed sources only; MJPEG-to-PPM exits `2`), or `base64`. |
| Localhost live viewer (`view`) | Yes | Loopback-only `127.0.0.1` / `localhost` HTTP/1.1 server (`/`, `/stream.mjpeg`, `/frame.jpg`, `/status.json`, `--port 0`) with an `8192`-byte header cap, `300 ms` request deadline, `Host`/`Origin` DNS-rebinding `403` filter, `X-Content-Type-Options: nosniff`, and strict CSP. |
| CH9329 serial HID (`key`, `type`, `mouse`, `release-all`/`restore`) | Yes | Mode 0 `0x57 0xAB` protocol (`9600`–`115200` baud), USB HID Page `0x07` BIOS keys (`F1`–`F12`, `Del`, `Esc`, `Enter`, arrows), US-ASCII typing, absolute (`0..4095`) and relative (`-127..127`) mouse press-hold-release, monotonic `sleep_ms` waits, `--dry-run` zero-TX preview, non-TTY `--yes` gate, and `SIGINT`/`SIGTERM` release-all. |
| AI-agent CLI & stdio MCP (`--describe`, `--json`, `mcp`) | Yes | Single-line `schema_version: 1` JSON envelopes and newline-delimited JSON-RPC 2.0 `uvcpipe mcp` negotiating `"2025-03-26"` or `"2024-11-05"` across 6 strict-schema tools with MCP tool `annotations` and `dry_run: true` default on all HID tools. |
| Commercial Pro license lifecycle (`license`) | Yes | `uvcpipe license status \| activate --key <KEY> \| validate \| deactivate [--force]` backed by Polar.sh HTTPS (or loopback HTTP for tests), storing cache (`0600`) with mandatory `validated_at` timestamp and 14-day offline grace. |
| Kernel drivers / unattached physical hardware checks | No | Zero kexts or vendor SDKs. Automated verification runs C17 ASan+UBSan suites, loopback HTTP/PTY tests, Polar loopback E2E, and 89/89 `--sim`/`--fixture` E2E tests on macOS `arm64`, Linux `x86_64`, and Windows `x86_64` CI; physical dongle/cable exchanges depend on host hardware and OS permissions. |

## Install & Uninstall

### Homebrew (macOS arm64 & Linux x86_64)
```bash
brew install raydeoliveira/tap/uvcpipe
brew uninstall uvcpipe
```

### Release Archives & Client Bundles
- macOS `arm64`: `uvcpipe-0.1.0-macos-arm64.tar.gz` and one-click Claude Desktop `.mcpb` (`uvcpipe-0.1.0-macos-arm64.mcpb`)
- Linux `x86_64`: `uvcpipe-0.1.0-linux-x86_64.tar.gz` (includes [99-uvcpipe.rules](packaging/udev/99-uvcpipe.rules) for non-root `/dev/video*` & `/dev/ttyUSB*` access)
- Windows `x86_64`: `uvcpipe-0.1.0-windows-x86_64.zip` (MSYS2 UCRT64 static C runtime + Media Foundation / Win32 serial)
- Ready-to-paste MCP client snippets: [mcp-configs.json](packaging/mcp-configs.json)

### Build From Source (macOS, Linux, Windows MSYS2 UCRT64)
```bash
make release               # Commercial build (.build/uvcpipe)
make release OSS=1         # Open-source build (-DOSS_EDITION)
make test                  # ASan + UBSan C, Polar E2E, and CLI/MCP suites
```

## Quick Start (Human & `--json` Agent Usage)

Inspect version, capability manifest, simulated hardware probe, and `--dry-run` HID packets:
```bash
uvcpipe --version --json
uvcpipe probe --sim --json
uvcpipe key --keys f2 --sim --dry-run --json
```

Activate a Commercial Pro license, capture a simulated frame, and start the localhost MJPEG viewer:
```bash
uvcpipe license activate --key UVCP-XXXX-XXXX-XXXX --json
uvcpipe capture --sim --format jpeg --out /tmp/bios.jpg --json
uvcpipe view --sim --port 0 --max-frames 30 --json
```

Run as a stdio MCP server (with `--dry-run` enforcing safe HID previews):
```bash
uvcpipe mcp --sim --dry-run
```

## Safety & Rollback

1. **Probe Before Write**: Live HID commands open the target CH9329 port and verify `CMD_GET_INFO` before transmitting key or mouse reports.
2. **Non-TTY Guard & Dry-Run**: Live `key`, `type`, `mouse`, and `release-all` commands fail closed with exit `2` on non-TTY `stdin` unless `--yes` or `--dry-run` is passed. All MCP HID tools default `dry_run` to `true`, and `mouse --button <btn>` sends press, interruptible hold, and button-release packets automatically.
3. **Symlink, Reparse & DNS-Rebinding Guards**: Snapshot `--out` and `license.json` reads check `lstat()` (`FILE_ATTRIBUTE_REPARSE_POINT` on Windows) and refuse symlinks with exit `4`. `view` binds only to `127.0.0.1` / `localhost` and rejects non-loopback or duplicate `Host` and non-loopback `Origin` headers with `403`.
4. **Signal Cleanup & Permissions**: `SIGINT`/`SIGTERM` aborts interruptible serial/V4L2 waits cleanly, releases held CH9329 inputs, and exits `130`. Denied macOS Camera TCC (`UVCPIPE_NO_TCC_PROMPT=1`), Linux `EACCES`, or Windows `E_ACCESSDENIED` exits `4`.

## Exit Codes & CLI Reference

Run `uvcpipe --help` for usage or `uvcpipe --describe` for the JSON capability manifest (see [SKILL.md](SKILL.md) for CLI and MCP schemas):
- `0`: Success
- `1`: Runtime, I/O, JPEG, or CH9329 protocol error
- `2`: Invalid usage, non-TTY mutating HID without `--yes`, non-loopback `--bind`, invalid `UVCPIPE_POLAR_API_URL`, or MJPEG-to-PPM conversion
- `3`: Hardware unavailable (no UVC dongle or CH9329 cable found)
- `4`: OS permission denied or symlink/reparse target refused
- `5`: Commercial license required or invalid (`license.json` in `UVCPIPE_CONFIG_DIR` or `~/.config/uvcpipe`; bypassed when built with `OSS=1`)
- `130`: Interrupted (`SIGINT`/`SIGTERM`) after HID release-all cleanup

## License & Security

- License: [LICENSE](LICENSE) (Free Core + `$19` Commercial Pro via [Polar.sh](https://buy.polar.sh/polar_cl_ZYe4DgatGrujYxoXUQ80f2zwwuM71Jspoxdew1Iac1c); `-DOSS_EDITION` compile switch unlocks all capabilities offline)
- Security policy: [SECURITY.md](SECURITY.md)
