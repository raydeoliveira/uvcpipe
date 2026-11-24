---
name: Hardware Compatibility Report
about: Report test results for a USB UVC HDMI capture dongle or CH9329 HID cable
title: "[Hardware]: <dongle or CH9329 cable> on <OS/arch>"
labels: hardware-report
---

**Hardware Tested**
- Capture dongle (e.g. MS2109, MS2130, ShadowCast, Cam Link 4K):
- CH9329 USB-serial HID cable / chip version (if tested):
- Host OS & architecture (e.g. macOS 15 arm64, Ubuntu 24.04 x86_64, Windows 11 x86_64):
- Target device (e.g. BIOS setup screen, Raspberry Pi, headless server):

**`uvcpipe --version` output**
```text

```

**`uvcpipe probe --json` output**
```json

```

**Commands Tested & Result**
- [ ] `uvcpipe capture --format jpeg --out frame.jpg --json`
- [ ] `uvcpipe view --port 0 --json`
- [ ] `uvcpipe key --keys f2 --dry-run --json`
- [ ] Live CH9329 HID (`key` / `type` / `mouse`)

**Observed Behavior / Notes**
- 
