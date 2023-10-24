class GoMssqlLoad < Formula
  desc "Simple alternative to the sqlcmd utility of Microsoft"
  homepage "https://github.com/jwbargsten/go-mssql-load"
  url "https://github.com/jwbargsten/go-mssql-load.git",
      tag:      "v0.0.1",
      revision: "9ea52c6bf3e749b9a280ef2c3698785acd4cd3d5"
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    run_output = shell_output("#{bin}/go-mssql-load 2>&1")
    assert_match "Utility functions for loading data into mssql server", run_output
  end
end
