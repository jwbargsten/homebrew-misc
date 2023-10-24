class GoMssqlLoad < Formula
  desc "Simple alternative to the sqlcmd utility of Microsoft"
  homepage "https://github.com/jwbargsten/go-mssql-load"
  url "https://github.com/jwbargsten/go-mssql-load.git",
      tag:      "v0.0.1",
      revision: "9ea52c6bf3e749b9a280ef2c3698785acd4cd3d5"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/jwbargsten/misc"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "a6de13b2c5727643410c7c7d89f0a9c5b07c04cd5f8f45295c73e7b0ac38bba8"
    sha256 cellar: :any_skip_relocation, ventura:       "0f6b1582e376479e92b37c4ce2c5540ea3097c6a311862980d9ea37a0797b1cf"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "a9e3ec736f2f30527d21925ab4fce4a325cc83f6afd25bb80f20650e378fbf61"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    run_output = shell_output("#{bin}/go-mssql-load 2>&1")
    assert_match "Utility functions for loading data into mssql server", run_output
  end
end
