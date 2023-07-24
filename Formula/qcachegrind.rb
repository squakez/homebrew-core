class Qcachegrind < Formula
  desc "Visualize data generated by Cachegrind and Calltree"
  homepage "https://kcachegrind.github.io/"
  url "https://download.kde.org/stable/release-service/23.04.3/src/kcachegrind-23.04.3.tar.xz"
  sha256 "4b188f1dd9f58164677d1de78010445e9ab3a28d7f2ca9db3ab74557c353ab9c"
  license "GPL-2.0-or-later"

  # We don't match versions like 19.07.80 or 19.07.90 where the patch number
  # is 80+ (beta) or 90+ (RC), as these aren't stable releases.
  livecheck do
    url "https://download.kde.org/stable/release-service/"
    regex(%r{href=.*?v?(\d+\.\d+\.(?:(?![89]\d)\d+)(?:\.\d+)*)/?["' >]}i)
  end

  bottle do
    sha256 cellar: :any,                 arm64_ventura:  "3198fb8dff0cb4f06173eb70559dcbcb51a302945c9ac14b12e339470f91cbbe"
    sha256 cellar: :any,                 arm64_monterey: "73860bf7130231d11a6e8408f8f5e5c7fa76aa6692799bba76f3cd90e3123956"
    sha256 cellar: :any,                 arm64_big_sur:  "85c08037fc8fcc43880ce0f38ed1eb3184f8f643511e178a5cf65785470b50d4"
    sha256 cellar: :any,                 ventura:        "08ab2a37f6684f8f87b27d214a4c3c6e1b6dbb3b1b88fc16c1e285b7e7ee1763"
    sha256 cellar: :any,                 monterey:       "e9d70f4519ad0170ad4c308b601c7e17152f8d7cb43e2eaf0c91bd8f303a27eb"
    sha256 cellar: :any,                 big_sur:        "f1182d2c6c73b3e28543b7762fab5d61092eb4b06c765a116b7a11b61d8b3457"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "d1145e1991930542c7dbf914dc455d1fa6cd195fdd7b06dc5556a3f44d446f66"
  end

  depends_on "graphviz"
  depends_on "qt@5"

  fails_with gcc: "5"

  def install
    args = []
    if OS.mac?
      # TODO: when using qt 6, modify the spec
      spec = (ENV.compiler == :clang) ? "macx-clang" : "macx-g++"
      args = %W[-config release -spec #{spec}]
    end

    system Formula["qt@5"].opt_bin/"qmake", *args
    system "make"

    if OS.mac?
      prefix.install "qcachegrind/qcachegrind.app"
      bin.install_symlink prefix/"qcachegrind.app/Contents/MacOS/qcachegrind"
    else
      bin.install "qcachegrind/qcachegrind"
    end
  end
end
