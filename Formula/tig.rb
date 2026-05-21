class Tig < Formula
  desc "Text interface for Git repositories"
  homepage "https://jonas.github.io/tig/"
  url "https://github.com/jonas/tig/releases/download/tig-2.6.0/tig-2.6.0.tar.gz"
  sha256 "99d4a0fdd3d93547ebacfe511195cb92e4f75b91644c06293c067f401addeb3e"
  license "GPL-2.0-or-later"

  head do
    url "https://github.com/jonas/tig.git", branch: "master"

    depends_on "asciidoc" => :build
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "xmlto" => :build
  end

  depends_on "pkgconf" => :build
  # https://github.com/jonas/tig/issues/1210
  depends_on "ncurses"
  depends_on "pcre2"
  depends_on "readline"

  # See notes/tig-skip-entries.md
  patch do
    url "https://raw.githubusercontent.com/jwbargsten/homebrew-misc/a5b42c7a18e276295fb376cc47f855e002b6d226/patches/tig-skip-entries.patch"
    sha256 "8e67c980416a2fe9975facff3cc5e9174a3eb43068ef7d985e0befe43bafda40"
  end

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--prefix=#{prefix}", "--sysconfdir=#{etc}"
    system "make"
    # Ensure the configured `sysconfdir` is used during runtime by
    # installing in a separate step.
    system "make", "install", "sysconfdir=#{pkgshare}/examples"
    system "make", "install-doc-man"
    bash_completion.install "contrib/tig-completion.bash"
    zsh_completion.install "contrib/tig-completion.zsh" => "_tig"
    cp "#{bash_completion}/tig-completion.bash", zsh_completion
  end

  def caveats
    <<~EOS
      A sample of the default configuration has been installed to:
        #{opt_pkgshare}/examples/tigrc
      to override the system-wide default configuration, copy the sample to:
        #{etc}/tigrc
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tig -v")
  end
end
