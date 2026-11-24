# Product Listing — uvcpipe Pro (macOS, Linux & Windows)

---

## Product Title
**uvcpipe Pro — Cross-Platform UVC HDMI Capture, Live Viewer & CH9329 Serial HID CLI + MCP Server**

## Price & Billing Model
- **$19 USD** — One-time perpetual license (`UVCP` key prefix, up to 3 activations).
- **Checkout Link**: <https://buy.polar.sh/polar_cl_ZYe4DgatGrujYxoXUQ80f2zwwuM71Jspoxdew1Iac1c>
- **Free Core Tier ("Free Eyes")** included in the single zero-dependency binary (**230,528 bytes** stripped macOS `arm64` / **207,056 bytes** stripped Linux `x86_64` / **199,168 bytes** Windows `x86_64`): `probe`, HDMI `capture`, live localhost `view` MJPEG browser KVM, `release-all`/`restore`, `license`, `--dry-run` on `key`/`type`/`mouse`, read-only/dry-run `mcp`, `--describe`, `--help`, and `--version`.
- **Open-Source Edition**: Compiling with `-DOSS_EDITION` (`make OSS=1`) unlocks all capabilities offline.

## Summary
Turn a ~$15 USB UVC HDMI capture dongle (MS2109/MS2130) and a ~$5 CH9329 USB-serial HID cable into bare-metal BIOS and OS eyes and hands for humans and AI coding agents (Claude Code, Codex, Antigravity) from one C17 CLI, localhost MJPEG viewer, and stdio MCP server.

## Quick Activation
```bash
uvcpipe license activate --key UVCP-XXXX-XXXX-XXXX --json
uvcpipe license status --json
```
Or pass `UVCPIPE_LICENSE_KEY` in headless MCP configurations (`packaging/mcp-configs.json` and `uvcpipe-0.2.0-macos-arm64.mcpb`). Cached grants reside at `$UVCPIPE_CONFIG_DIR/license.json`, `$XDG_CONFIG_HOME/uvcpipe/license.json`, `~/.config/uvcpipe/license.json`, or `%LOCALAPPDATA%\uvcpipe\license.json` with a 14-day offline validation window.

## Included Release Downloads
- `uvcpipe-0.2.0-macos-arm64.tar.gz` — macOS Apple Silicon binary + docs
- `uvcpipe-0.2.0-macos-arm64.mcpb` — One-click macOS MCP Bundle (`manifest_version: "0.3"`)
- `uvcpipe-0.2.0-linux-x86_64.tar.gz` — Linux `x86_64` binary + `99-uvcpipe.rules` udev rules + docs
- `uvcpipe-0.2.0-windows-x86_64.zip` — Windows `x86_64` (`uvcpipe.exe`) + docs
- `SHA256SUMS.txt` — Verified SHA-256 checksums across all release files

## Free Core vs. Pro Comparison

| Feature | Free Core | Pro ($19 one-time) |
|---|---|---|
| `probe` (UVC + CH9329 discovery, `--sim`, `--fixture`) | Included | Included |
| `capture` (`jpeg`, `ppm`, `base64`, atomic `lstat`-guarded `--out`) | Included | Included |
| `view` (localhost `127.0.0.1` HTTP/1.1 live MJPEG browser KVM) | Included | Included |
| `release-all` / `restore` (3-packet CH9329 release) | Included | Included |
| `key`, `type`, `mouse` with `--dry-run` (zero-TX hex preview) | Included | Included |
| `uvcpipe mcp` read-only (`probe`, `capture_frame`) & `dry_run: true` | Included | Included |
| `--describe`, `--help`, `--version`, `--json`, `license` | Included | Included |
| Live `key`, `type`, `mouse` CH9329 serial HID writes | — | Included |
| Live `uvcpipe mcp` HID writes (`dry_run: false`) | — | Included |

## Requirements & Honest Limits
- **OS & Hardware**: macOS 14+ (`AVFoundation`), Linux (`V4L2 /dev/video*` + `termios`), and Windows (`Media Foundation` + `Win32 COMx`).
- **Permissions**: macOS Camera TCC (`exit 4` on denied or non-TTY `notDetermined` with `UVCPIPE_NO_TCC_PROMPT=1`), Linux `video`/`dialout` device permissions (`99-uvcpipe.rules` included; `exit 4` on `EACCES`), and Windows Camera privacy access (`exit 4` on `E_ACCESSDENIED`).
- **Verification**: ASan/UBSan C suites, loopback Polar HTTP E2E, PTY `SIGINT` signal cleanup tests, and 89/89 `--sim`/`--fixture` E2E tests pass across macOS `arm64`, Linux `x86_64`, and Windows `x86_64` CI. Physical MS2109/MS2130/CH9329 hardware exchanges require attached host devices. Always preview HID inputs with `--dry-run` first.
