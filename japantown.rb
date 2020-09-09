class Japantown < Formula
  desc "Tighten SF Mono + Japanese Font"
  homepage "https://github.com/aerobounce/Japantown"
  url "https://github.com/aerobounce/Homebrew-Japantown/archive/2020-08-13.zip"
  sha256 "72bd4e4b58fa259b5f1c6eda8faf7b376dd66d23388d16931e81f858ed6ae8dc"
  version "2020-08-13"
  head "https://github.com/aerobounce/Japantown.git"

  depends_on "fontforge"

  resource "mplus-fonts" do
    url "https://osdn.net/frs/redir.php?m=iij&f=mplus-fonts%2F62344%2F063-OTF.tar.xz"
    sha256 "b1a98b24e034ff26d7cb957d904f1d49bbffc004c732eadc822e140b99f98ce1"
  end

  resource "sfmono" do
    url "https://developer.apple.com/design/downloads/SF-Mono.dmg"
    sha256 "e44347f272290875f2ae03866799d3d0958b4e26bc871cb6f4d1c241d5ba507d"
  end

  def install
    resource("mplus-fonts").stage {
      [
        "mplus-1m-light.otf",
        "mplus-1m-regular.otf",
        "mplus-1m-medium.otf",
        "mplus-1m-bold.otf",
      ]
        .each do |mplus|
        buildpath.install mplus
      end
    }

    resource("sfmono").stage do
      system "/usr/bin/xar", "-xf", "SF Mono Fonts.pkg"
      system "/bin/bash", "-c", "cat SFMonoFonts.pkg/Payload | gunzip -dc | cpio -i"
      [
        "SF-Mono-Light.otf",
        "SF-Mono-LightItalic.otf",
        "SF-Mono-Regular.otf",
        "SF-Mono-RegularItalic.otf",
        "SF-Mono-Medium.otf",
        "SF-Mono-MediumItalic.otf",
        "SF-Mono-Semibold.otf",
        "SF-Mono-SemiboldItalic.otf",
      ]
        .each do |sfmono|
        buildpath.install "Library/Fonts/#{sfmono}"
      end
    end

    system (buildpath / "install.sh"), "-brew"
    prefix.install Dir["build/*.otf"]
    system "open", prefix
  end
end
