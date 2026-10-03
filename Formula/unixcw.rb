class Unixcw < Formula
  desc "Morse code tutor - command-line user interface"
  homepage "https://unixcw.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/unixcw/unixcw-3.6.1.tar.gz"
  sha256 "0af83855214bf90b4c0d149221884ab4458f3857c38972d428daebf3badd6e32"
  license "GPL-2.0-or-later"

  depends_on "pkgconf" => :build
  depends_on "gettext"
  depends_on "pulseaudio"

  patch :p0 do
    url "https://raw.githubusercontent.com/macports/macports-ports/ecf1303c55243b6b887bce8c67f9cdca4786436d/audio/unixcw/files/patch-src-libcw-libcw-pa.diff"
    sha256 "e24f8b51a952fcd8faa5b58b8c0ec6d265db2e824c861d9b88e1e6519b0750ab"
  end

  patch :p0 do
    url "https://raw.githubusercontent.com/macports/macports-ports/ecf1303c55243b6b887bce8c67f9cdca4786436d/audio/unixcw/files/patch-src-cwutils-lib-random.diff"
    sha256 "797e7d7da4cc9777bb35c56db0aa573d092b2125df392f3c1569cdb4200a2416"
  end

  deny_network_access!

  def install
    inreplace "src/libcw/libcw_pa.c",
              "LIBDIR \"", "\"#{formula_opt_lib("pulseaudio")}"
    system "./configure", *std_configure_args,
           "--disable-console", "--disable-oss", "--disable-alsa",
           "--disable-cwgen", "--disable-cwcp", "--disable-xcwcp",
           "--disable-static"
    system "make", "install"
  end

  def caveats
    <<~EOS
      Start the sound server with: brew services start pulseaudio
      For clean audio, use: PULSE_LATENCY_MSEC=500 cw
    EOS
  end

  test do
    assert_match "cw version #{version}", shell_output("#{bin}/cw --version 2>&1")
  end
end
