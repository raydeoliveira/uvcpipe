class Uvcpipe < Formula
  desc "UVC HDMI capture, live KVM viewer, CH9329 HID CLI and MCP server for BIOS/OS control"
  homepage "https://github.com/raydeoliveira/uvcpipe"
  version "0.2.0"
  license :cannot_represent

  on_macos do
    depends_on arch: :arm64
    depends_on macos: :sonoma
    url "https://github.com/raydeoliveira/uvcpipe/releases/download/v0.2.0/uvcpipe-0.2.0-macos-arm64.tar.gz"
    sha256 "aa0d44c14bce9a0cba39d97e234dc4de723445316d6883a972e38412e7e02819"
  end

  on_linux do
    depends_on arch: :x86_64
    url "https://github.com/raydeoliveira/uvcpipe/releases/download/v0.2.0/uvcpipe-0.2.0-linux-x86_64.tar.gz"
    sha256 "169aee7f67e833e1ee189e28f67e71761719926943b17eb78058fba7ceedc13c"
  end

  def install
    bin.install "uvcpipe"
    doc.install "README.md", "LICENSE", "SECURITY.md", "SKILL.md", "server.json", "mcp-configs.json"
    pkgshare.install "99-uvcpipe.rules" if File.exist?("99-uvcpipe.rules")
  end

  def caveats
    <<~EOS
      Free Core ("Eyes", no license needed):
        uvcpipe probe --json
        uvcpipe capture --sim --format jpeg --out /tmp/frame.jpg --json
        uvcpipe view --sim --port 0 --json
        uvcpipe mcp --sim --dry-run

      Unlock Pro Live CH9329 HID Writes ($19 one-time):
        https://buy.polar.sh/polar_cl_ZYe4DgatGrujYxoXUQ80f2zwwuM71Jspoxdew1Iac1c
        uvcpipe license activate --key UVCP-XXXX-XXXX-XXXX --json
    EOS
  end

  test do
    assert_match "uvcpipe 0.2.0", shell_output("#{bin}/uvcpipe --version")
    describe_json = shell_output("#{bin}/uvcpipe --describe")
    assert_match "\"schema_version\":1", describe_json
    assert_match "\"sim\":true", shell_output("#{bin}/uvcpipe probe --sim --json")
    assert_match "\"format\":\"jpeg\"", shell_output("#{bin}/uvcpipe capture --sim --format base64 --json")
    assert_match "\"dry_run\":true", shell_output("#{bin}/uvcpipe key --keys f2 --sim --dry-run --json")
    assert_match "\"tier\":", shell_output("#{bin}/uvcpipe license status --json")
  end
end
