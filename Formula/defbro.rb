class Defbro < Formula
  desc "Set the default browser from command-line"
  homepage "https://github.com/jwbargsten/defbro"
  url "https://github.com/jwbargsten/defbro/archive/refs/tags/v0.0.1.tar.gz"
  sha256 "90c5bfa02037cdcdb5356b935298d52d854f3ab1368bc4663b77e99e3287f8a6"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/jwbargsten/misc"
    rebuild 2
    sha256 cellar: :any_skip_relocation, arm64_ventura: "85661041ed653a8d6e09a898e8e175166eb9bf63b7e93930f321e8e9c3ae922a"
    sha256 cellar: :any_skip_relocation, ventura:       "17ce293c7a6809a3efef2ff2837bf482aabae2d98d1dd2b4ea422feec2bec0da"
  end

  depends_on xcode: [">= 11.2", :build]
  depends_on macos: [
    :catalina,
    :big_sur,
    :ventura,
  ]

  uses_from_macos "swift"

  def install
    system "swift", "build", "--disable-sandbox", "-c", "release"
    bin.install ".build/release/defbro"
  end

  test do
    # no tests, yay!
    system "true"
  end
end
