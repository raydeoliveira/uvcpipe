class Uvcpipe < Formula
  desc "Cross-platform C17 USB UVC HDMI capture, live viewer, CH9329 serial HID CLI & MCP server"
  homepage "https://github.com/raydeoliveira/uvcpipe"
  version "0.1.0"
  license :cannot_represent

  on_macos do
    depends_on arch: :arm64
    depends_on macos: :sonoma
    url "https://github.com/raydeoliveira/uvcpipe/releases/download/v0.1.0/uvcpipe-0.1.0-macos-arm64.tar.gz"
    sha256 "fcb78fef5938ee5ed015b3fdf05f480505c2bdd32da101bdc54c41a660a698c8"
  end

  on_linux do
    depends_on arch: :x86_64
    url "https://github.com/raydeoliveira/uvcpipe/releases/download/v0.1.0/uvcpipe-0.1.0-linux-x86_64.tar.gz"
    sha256 "8d1273c85269a3b8fce088ed8f35b7de6c49371938dcf061b15784038b3d1bf4"
  end

  def install
    bin.install "uvcpipe"
    doc.install "README.md", "LICENSE", "SECURITY.md", "SKILL.md", "server.json", "mcp-configs.json"
    pkgshare.install "99-uvcpipe.rules" if File.exist?("99-uvcpipe.rules")
  end

  def caveats
    <<~EOS
      Free Core commands run without a license:
        uvcpipe probe --sim --json
        uvcpipe key --keys f2 --sim --dry-run --json

      Unlock Pro (capture, view, live HID, mcp) at $19 one-time:
        https://buy.polar.sh/polar_cl_ZYe4DgatGrujYxoXUQ80f2zwwuM71Jspoxdew1Iac1c
        uvcpipe license activate --key UVCP-XXXX-XXXX-XXXX --json
    EOS
  end

  test do
    assert_match "uvcpipe 0.1.0", shell_output("#{bin}/uvcpipe --version")
    describe_json = shell_output("#{bin}/uvcpipe --describe")
    assert_match "\"schema_version\":1", describe_json
    assert_match "\"sim\":true", shell_output("#{bin}/uvcpipe probe --sim --json")
    assert_match "\"dry_run\":true", shell_output("#{bin}/uvcpipe key --keys f2 --sim --dry-run --json")
    assert_match "\"tier\":", shell_output("#{bin}/uvcpipe license status --json")
  end
end
