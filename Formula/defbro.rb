# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Defbro < Formula
  desc "set the default browser from commandline"
  homepage "https://github.com/jwbargsten/defbro"
  url "https://github.com/jwbargsten/defbro/archive/refs/tags/v0.0.1.tar.gz"
  sha256 "90c5bfa02037cdcdb5356b935298d52d854f3ab1368bc4663b77e99e3287f8a6"
  license "MIT"

  depends_on xcode: [">= 11.2", :build ]
  depends_on macos: [
    :catalina,
    :big_sur,
  ]

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel
    # Remove unrecognized options if warned by configure
    # https://rubydoc.brew.sh/Formula.html#std_configure_args-instance_method
    system "swift", "build", "--disable-sandbox", "--configuration", "release"
    bin.install ".build/release/defbro"
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test defbro`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "true"
  end
end
