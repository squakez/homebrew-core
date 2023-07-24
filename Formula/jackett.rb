class Jackett < Formula
  desc "API Support for your favorite torrent trackers"
  homepage "https://github.com/Jackett/Jackett"
  url "https://github.com/Jackett/Jackett/archive/refs/tags/v0.21.514.tar.gz"
  sha256 "61cec4c5802faf529ec191bf3dd6dc95a886ac0c74e4f7f028946cbaa648a1b4"
  license "GPL-2.0-only"
  head "https://github.com/Jackett/Jackett.git", branch: "master"

  bottle do
    sha256 cellar: :any,                 arm64_ventura:  "dfa712073962f51b528b30d12ec57be32115ca8fe1f9980fe401a3235b241018"
    sha256 cellar: :any,                 arm64_monterey: "ff79cf076630e4067cb7c36537a0d1cc60e89df5e9a1fad1a14c20f1b49c9e99"
    sha256 cellar: :any,                 arm64_big_sur:  "005551703c6e6355b5bfd9bc9d3870ba22eab864d43ceb61f8f3804f026e482e"
    sha256 cellar: :any,                 ventura:        "8860cdbb444f939ec7d72333e0ac0b09b4a53b3ba078760bebc5df5d589cb3ec"
    sha256 cellar: :any,                 monterey:       "80977471f1a0d829ca200b18a166a3f8e77690d42db28d5fa40fc5c4212e38ce"
    sha256 cellar: :any,                 big_sur:        "b6c868503ef018918b028b602d151338f7b248ea687bdd76fdd1b9ef0c209ac7"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "5b5118f47e3f25e3a9d8ab0fbb67c47ce2375f0a38da55b529729a2411a313a6"
  end

  depends_on "dotnet@6"

  def install
    dotnet = Formula["dotnet@6"]
    os = OS.mac? ? "osx" : OS.kernel_name.downcase
    arch = Hardware::CPU.intel? ? "x64" : Hardware::CPU.arch.to_s

    args = %W[
      --configuration Release
      --framework net#{dotnet.version.major_minor}
      --output #{libexec}
      --runtime #{os}-#{arch}
      --no-self-contained
    ]
    if build.stable?
      args += %W[
        /p:AssemblyVersion=#{version}
        /p:FileVersion=#{version}
        /p:InformationalVersion=#{version}
        /p:Version=#{version}
      ]
    end

    system "dotnet", "publish", "src/Jackett.Server", *args

    (bin/"jackett").write_env_script libexec/"jackett", "--NoUpdates",
      DOTNET_ROOT: "${DOTNET_ROOT:-#{dotnet.opt_libexec}}"
  end

  service do
    run opt_bin/"jackett"
    keep_alive true
    working_dir opt_libexec
    log_path var/"log/jackett.log"
    error_log_path var/"log/jackett.log"
  end

  test do
    assert_match(/^Jackett v#{Regexp.escape(version)}$/, shell_output("#{bin}/jackett --version 2>&1; true"))

    port = free_port

    pid = fork do
      exec "#{bin}/jackett", "-d", testpath, "-p", port.to_s
    end

    begin
      sleep 10
      assert_match "<title>Jackett</title>", shell_output("curl -b cookiefile -c cookiefile -L --silent http://localhost:#{port}")
    ensure
      Process.kill "TERM", pid
      Process.wait pid
    end
  end
end
