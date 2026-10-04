class Unixcw < Formula
  desc "Morse code tutor and command-line tools"
  homepage "https://unixcw.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/unixcw/unixcw-3.6.1.tar.gz"
  sha256 "0af83855214bf90b4c0d149221884ab4458f3857c38972d428daebf3badd6e32"
  license "GPL-2.0-or-later"

  bottle do
    rebuild 1
    sha256 arm64_golden_gate: "dc7988fd7a9af8c45404b29aebaa33506db51d68f7979bbe7e6a11165d86f727"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build
  depends_on "pkgconf" => :build

  depends_on "gettext"
  depends_on "pulseaudio"
  uses_from_macos "ncurses"

  on_linux do
    depends_on "alsa-lib"
  end

  # macOS patches from MacPorts
  # submitted to upstream https://sourceforge.net/p/unixcw/tickets/3/
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
    if OS.mac?
      # Patch above expects LIBDIR to point at the PulseAudio libraries
      inreplace "src/libcw/libcw_pa.c",
                "LIBDIR \"", "\"#{formula_opt_lib("pulseaudio")}"
    end

    # prevent linking with flat namespace
    system "autoreconf", "--force", "--install", "--verbose"

    args = %w[
      --disable-xcwcp
      --disable-static
    ]
    args += %w[--disable-console --disable-oss --disable-alsa] if OS.mac?

    system "./configure", *args, *std_configure_args
    system "make", "install"
  end

  test do
    assert_match "cw version #{version}", shell_output("#{bin}/cw --version 2>&1")
  end
end
