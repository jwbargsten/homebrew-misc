class Defbro < Formula
  desc "Set the default browser from command-line"
  homepage "https://github.com/jwbargsten/defbro"
  url "https://github.com/jwbargsten/defbro/archive/refs/tags/v0.0.1.tar.gz"
  sha256 "90c5bfa02037cdcdb5356b935298d52d854f3ab1368bc4663b77e99e3287f8a6"
  license "MIT"

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
    system "true"
  end
end
