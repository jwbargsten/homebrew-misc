class Defbro < Formula
  desc "Set the default browser from command-line"
  homepage "https://github.com/jwbargsten/defbro"
  url "https://github.com/jwbargsten/defbro/archive/refs/tags/v0.0.1.tar.gz"
  sha256 "90c5bfa02037cdcdb5356b935298d52d854f3ab1368bc4663b77e99e3287f8a6"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/jwbargsten/misc"
    rebuild 3
    sha256 cellar: :any_skip_relocation, arm64_ventura: "7424921aa23cbc9d564f9e053d5beb932c007741cb27f2c76918b2de39c60268"
    sha256 cellar: :any_skip_relocation, ventura:       "31cd64f0a94024bf7594e9a0aa555b69f42016ab70e7f6e7a7ae2ec20f414f67"
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
