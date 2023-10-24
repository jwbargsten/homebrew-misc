class Defbro < Formula
  desc "Set the default browser from command-line"
  homepage "https://github.com/jwbargsten/defbro"
  url "https://github.com/jwbargsten/defbro/archive/refs/tags/v0.0.1.tar.gz"
  sha256 "90c5bfa02037cdcdb5356b935298d52d854f3ab1368bc4663b77e99e3287f8a6"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/jwbargsten/misc"
    rebuild 1
    sha256 cellar: :any_skip_relocation, big_sur: "d61c7ccbf2d3989d4be4102db16c3d6b244ef67f0973df82a250331d62c8c11c"
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
    # because we do bug-free development
    system "true"
  end
end
