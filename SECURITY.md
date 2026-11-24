# Security Policy — uvcpipe

## Reporting a Vulnerability
Report security vulnerabilities privately via GitHub Security Advisories on `https://github.com/raydeoliveira/uvcpipe`.

## Security & Hardware Safety Model
- **C17 memory safety**: Compiled with `-std=c17 -Wall -Wextra -Werror -Wpedantic -Wshadow -Wconversion -Wformat=2 -fno-strict-aliasing` and tested under AddressSanitizer and UndefinedBehaviorSanitizer (`make test`).
- **Bounded inputs & network**: Fixture loading caps at `32 MiB`, JSON/JSON-RPC lines cap at `1 MiB`, `viewer_http` binds exclusively to loopback `127.0.0.1` (`localhost`) with an `8192`-byte header cap, `300 ms` slowloris request deadline, `Host`/`Origin` DNS-rebinding `403` check, `Content-Security-Policy`, `X-Content-Type-Options: nosniff`, and symlink/reparse rejection via `lstat()` (`exit 4`).
- **HID write safety**: Live mutating HID commands refuse non-TTY `stdin` without `--yes` (`exit 2`), `--dry-run` performs zero serial writes, `mcp` HID tools default `dry_run: true`, mouse clicks release held buttons automatically, and `SIGINT`/`SIGTERM` triggers clean CH9329 release-all (`exit 130`).
- **Commercial license transport & cache**: `polar_http` executes `curl --proto =https,http` without a shell, passes JSON request bodies over stdin (never argv), rejects non-HTTPS non-loopback `UVCPIPE_POLAR_API_URL` overrides (`exit 2`), enforces mandatory non-future `<= 14d` `validated_at` timestamps on cached `license.json` files (`0600`), and preserves local caches if remote deactivation fails unless `--force` is passed.
