# uvcpipe

> **Product Hub:** [raymonddeoliveira.com/software#uvcpipe](https://www.raymonddeoliveira.com/software#uvcpipe) · **Buy Pro Live HID ($19):** [Polar Checkout](https://buy.polar.sh/polar_cl_ZYe4DgatGrujYxoXUQ80f2zwwuM71Jspoxdew1Iac1c) · **Glama MCP:** [glama.ai/mcp/servers/raydeoliveira/uvcpipe](https://glama.ai/mcp/servers/raydeoliveira/uvcpipe) · **Official MCP Registry:** [io.github.raydeoliveira/uvcpipe](https://registry.modelcontextprotocol.io/v0.1/servers?search=raydeoliveira/uvcpipe) · **Free Core:** `brew install raydeoliveira/tap/uvcpipe`

Clean-room C17 CLI, localhost live MJPEG viewer, and stdio MCP server turning a ~$15 USB UVC HDMI capture dongle (MS2109/MS2130, ShadowCast, Cam Link) and a ~$5 CH9329 USB-serial HID cable into bare-metal BIOS and OS eyes and hands across macOS, Linux, and Windows.

**Free local HDMI capture and viewing.** Capture frames from a USB UVC dongle or simulation, open the localhost MJPEG viewer, and use read-only MCP tools, HID previews or emergency release without a key. Upgrade to the one-time USD $19 Pro license (up to three devices) to send live keyboard and mouse input over the optional CH9329 cable from the CLI or MCP. The license covers original v0.2.0 downloads, including copies containing the older terms. [UVCpipe license](LICENSE)

Measured stripped release sizes: **230,528 bytes (~225 KB)** on macOS `arm64` (**19.45 ms** avg cold start), **207,056 bytes (~202 KB)** on Linux `x86_64`, and **199,168 bytes (~195 KB)** on Windows `x86_64`, with zero runtime dependencies.

## ~$20 Hardware Bill of Materials

1. **Video Capture ("Eyes") — ~$10–$15**: Any USB 2.0/3.0 UVC HDMI capture dongle based on **MS2109** / **MS2130** (or Genki ShadowCast, Elgato Cam Link). Connect target machine HDMI out → capture dongle → host USB port.
2. **Keyboard & Mouse Cable ("Hands") — ~$5**: A **CH9329** USB-to-USB HID serial bridge cable (default Mode 0 `0x57 0xAB` @ `9600`–`115200` baud). Connect serial end to host USB (`/dev/cu.usbserial-*`, `/dev/ttyUSB0`, `COMx`) and HID USB-A end to target BIOS/PC.

## Try HDMI capture without a dongle

Install UVCpipe on the computer where you will connect the capture dongle. On Apple Silicon macOS or x86_64 Linux, use Homebrew. Windows x86_64 users can extract `uvcpipe.exe` from the [release archive](https://github.com/raydeoliveira/uvcpipe/releases/download/v0.2.0/uvcpipe-0.2.0-windows-x86_64.zip).

```sh
brew install raydeoliveira/tap/uvcpipe
uvcpipe probe --sim --json
```

Look for `sim-uvc-0` in `data.uvc_devices`. To capture a 160 × 90 test image, run `uvcpipe capture --sim --width 160 --height 90 --format base64 --json`. The image is in `data.data_base64`. Both checks run locally and require no license key.

To give your agent the CLI instructions, install the [UVCpipe skill](SKILL.md) from your project directory. Ask it to run `uvcpipe probe --sim --json` to list the simulated device.

```sh
npx skills add raydeoliveira/uvcpipe
```

## Connect an MCP client

Connect Claude Code, Cursor, Codex, or Antigravity with zero license required to inspect devices, capture target HDMI frames, and preview `--dry-run` keystrokes:

```bash
claude mcp add uvcpipe -- uvcpipe mcp
```

Claude Desktop on Apple Silicon can open the [v0.2.0 desktop bundle](https://github.com/raydeoliveira/uvcpipe/releases/download/v0.2.0/uvcpipe-0.2.0-macos-arm64.mcpb). Other clients can use the [configuration examples](packaging/mcp-configs.json).

## Free Core vs. $19 Pro vs. Alternatives

| Tool | Hardware + SW Cost | Target Control Scope | Scriptable `--json` + MCP | Binary Footprint |
|---|---|---|---|---|
| **uvcpipe Free Core** | ~$15–$20 cables + **$0** | `probe`, HDMI `capture`, `view` MJPEG KVM, `--dry-run` HID, `release-all`, free capture/dry-run `mcp` | Yes (`--describe`, MCP `2025-03-26`) | ~194–225 KB C17 |
| **uvcpipe Pro** | ~$20 cables + **$19 one-time** | Adds live CH9329 `key`, `type`, `mouse` & MCP `dry_run: false` (3 devices, 14d offline cache) | Yes (same single binary) | ~194–225 KB C17 |
| Dedicated IP-KVM Box | $90–$300 hardware | Web UI / VNC / ATX hardware appliance | Rare / proprietary HTTP | Separate Linux SBC |
| OBS / `ffplay` | ~$15 capture dongle | Desktop GUI video preview only (no HID or MCP) | No CLI/HID/MCP | ~100+ MB + deps |

## Install & Uninstall

### Homebrew (macOS arm64 & Linux x86_64)
```bash
brew install raydeoliveira/tap/uvcpipe
brew uninstall uvcpipe
```

### Checksum-Verified Release Archives (`v0.2.0`)
Download from [GitHub Releases](https://github.com/raydeoliveira/uvcpipe/releases/tag/v0.2.0) and verify with `SHA256SUMS.txt`:
- **macOS `arm64`**: `uvcpipe-0.2.0-macos-arm64.tar.gz` and one-click Claude Desktop bundle `uvcpipe-0.2.0-macos-arm64.mcpb`
  ```bash
  curl -fsSLO https://github.com/raydeoliveira/uvcpipe/releases/download/v0.2.0/uvcpipe-0.2.0-macos-arm64.tar.gz
  curl -fsSLO https://github.com/raydeoliveira/uvcpipe/releases/download/v0.2.0/SHA256SUMS.txt
  shasum -a 256 -c SHA256SUMS.txt --ignore-missing
  tar -xzf uvcpipe-0.2.0-macos-arm64.tar.gz
  ```
- **Linux `x86_64`**: `uvcpipe-0.2.0-linux-x86_64.tar.gz` (includes [99-uvcpipe.rules](packaging/udev/99-uvcpipe.rules) for non-root `/dev/video*` & `/dev/ttyUSB*` access)
- **Windows `x86_64`**: `uvcpipe-0.2.0-windows-x86_64.zip` (`uvcpipe.exe`, MSYS2 UCRT64 static C runtime + Media Foundation)

### Build from a source checkout

The public repository distributes release binaries and client configuration. The following commands apply to a separate checkout containing the UVCpipe Makefile.

```bash
make release               # Commercial build (.build/uvcpipe)
make release OSS=1         # Open-source build (-DOSS_EDITION)
make test                  # ASan + UBSan C, Polar E2E, and CLI/MCP suites
```

## Quick Start (CLI & Live Viewer)

Free Core — inspect devices, capture an HDMI frame, start the loopback KVM viewer, and preview HID hex packets:
```bash
uvcpipe probe --json
uvcpipe capture --width 1280 --height 720 --format jpeg --out /tmp/bios.jpg --json
uvcpipe view --port 0 --json
uvcpipe key --keys f2 --sim --dry-run --json
```

Unlock Pro live HID keyboard/mouse writes (`$19` one-time at [Polar.sh](https://buy.polar.sh/polar_cl_ZYe4DgatGrujYxoXUQ80f2zwwuM71Jspoxdew1Iac1c)):
```bash
uvcpipe license activate --key UVCP-XXXX-XXXX-XXXX --json
uvcpipe key --keys f2 --port /dev/ttyUSB0 --yes --json
```

## Safety & Honest Limits

1. **Probe Before Write**: Live HID commands verify `CMD_GET_INFO` before transmitting key or mouse packets.
2. **Non-TTY Guard & Dry-Run**: Live `key`, `type`, `mouse`, and `release-all` exit `2` on non-TTY `stdin` without `--yes` or `--dry-run`. MCP HID tools default `dry_run` to `true`; `mouse --button <btn>` sends press, interruptible monotonic hold, and button-release automatically.
3. **Symlink, Reparse & DNS-Rebinding Guards**: Snapshot `--out` and `license.json` reads check `lstat()` (`FILE_ATTRIBUTE_REPARSE_POINT` on Windows) and exit `4` on symlinks. `view` binds only to `127.0.0.1`/`localhost` with an `8192`-byte header cap, `300 ms` deadline, `Host`/`Origin` `403` filter, `nosniff`, and CSP.
4. **Signal Cleanup & Hardware Scope**: `SIGINT`/`SIGTERM` aborts serial/V4L2 waits cleanly, releases held CH9329 inputs, and exits `130`. macOS/Linux/Windows CI verifies ASan+UBSan suites, loopback Polar E2E, PTY signal cleanup, and `89/89` `--sim`/`--fixture` E2E tests; physical capture/HID exchanges require attached hardware and OS camera/serial permissions (`exit 4` on macOS TCC deny / Linux `EACCES` / Windows `E_ACCESSDENIED`).

## Hardware Reports & Exit Codes

Tested a specific HDMI capture dongle (MS2109, MS2130, ShadowCast, Cam Link) or CH9329 cable? Share your `uvcpipe probe --json` output in [Hardware Compatibility Issues](https://github.com/raydeoliveira/uvcpipe/issues/new?template=hardware-report.md).

Run `uvcpipe --describe` or inspect [SKILL.md](SKILL.md) for JSON schemas. Exit codes: `0` ok, `1` runtime/I/O error, `2` usage/validation/non-TTY, `3` hardware unavailable, `4` permission/symlink denied, `5` Pro license required for live HID, `130` interrupted (`SIGINT`/`SIGTERM`) after HID release.

## License & Security

- License: [LICENSE](LICENSE) (Free Core Eyes + `$19` Pro Live HID via [Polar.sh](https://buy.polar.sh/polar_cl_ZYe4DgatGrujYxoXUQ80f2zwwuM71Jspoxdew1Iac1c); `-DOSS_EDITION` compile switch unlocks all capabilities offline)
- Security policy: [SECURITY.md](SECURITY.md)
