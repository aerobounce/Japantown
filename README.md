# <p align="center">Japantown</p>
### <p align="center">Condensed Spacing SF Mono + Japanese Glyphs</p>

<p align="center"><img src="./assets/logo.png" width="400"/></p>
<p align="center"><img src="./assets/lorem.png"/></p>

## 4 Weights, supports italic

- Japantown-Light.otf
- Japantown-LightItalic.otf
- Japantown-Regular.otf
- Japantown-RegularItalic.otf
- Japantown-Medium.otf
- Japantown-MediumItalic.otf
- Japantown-Bold.otf
- Japantown-BoldItalic.otf

## For developers like me

I always loved SFMono's look and feel except its too wide letter spacing and lack of Japanese glyphs.\
**Japantown** complements those points.\
It's like a modernized brother of `Osaka`.

- Supports Japanese glyphs (by merging: [mplus-1m](https://mplus-fonts.osdn.jp/about.html))
- Condensed letter spacing
- Some glyphs are customized for readability

## For people who want to create a font with FontForge

In build script `install.sh`, I've left comments as much as I can. It's a good start to learn how it works.\
Check out **References** too, they're quite informative.

## License

This font inherits `SFMono Font License` as based on the font.\
In other words, binary form of this font cannot be shared.


# Install

```
brew tap aerobounce/Japantown && brew install japantown
```

Or, clone this repository, put all the fonts below and execute `install.sh`.

```
mplus-1m-light.otf
mplus-1m-regular.otf
mplus-1m-medium.otf
mplus-1m-bold.otf

SF-Mono-Light.otf
SF-Mono-LightItalic.otf
SF-Mono-Regular.otf
SF-Mono-RegularItalic.otf
SF-Mono-Medium.otf
SF-Mono-MediumItalic.otf
SF-Mono-Semibold.otf
SF-Mono-SemiboldItalic.otf
```


# Todo

- [ ] Better way to install
- [ ] Check all the glyphs


# Tips

- `CoreText` based rendering rounds glyph's width.
    - `TextEdit.app`, `Terminal.app` ... etc
    - Be warned that those applications are not suitable to check how a font is rendered.
- `Xcode.app` renders fonts accurately.
- `Sublime Text 3` with `"font_options": ["no_round"]` pref renders fonts accurately.


# References

### Fonts
- [M+ FONTS PROJECT](https://mplus-fonts.osdn.jp/about.html)
- [Japanese Monospaced Fonts](https://neos21.github.io/japanese-monospaced-fonts/index.html)
- [yuru7/HackGen](https://github.com/yuru7/HackGen)
- [delphinus/homebrew-sfmono-square](https://github.com/delphinus/homebrew-sfmono-square)

### Unicode
- [Unicode Characters in the 'Symbol, Other' Category](https://www.fileformat.info/info/unicode/category/So/list.htm)
- [List of Unicode characters](https://en.wikipedia.org/wiki/List_of_Unicode_characters)

### Font Structure
- [OS/2 Compatibility Table - TrueType Reference Manual - Apple Developer](https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6OS2.html)
- [OS/2 and Windows Metrics Table](https://docs.microsoft.com/en-us/typography/opentype/spec/os2)

### FontForge
- [Scripting functions](https://fontforge.org/scripting-alpha.html)
- [Writing python scripts to change fonts in FontForge](https://fontforge.org/en-US/documentation/scripting/python/)
- [Writing python scripts to change fonts in FontForge](http://dmtr.org/ff.php)

### Tools
- [webfont | test](http://webfont-test.com/)

### Others
- [Sublime Text Dev Build 2169](https://forum.sublimetext.com/t/dev-build-2169/4026)


# Special Thanks

FontForge contributor: skef.
