#!/usr/bin/env bash
set -Ceu

### Constants
# SFMONO_GLYPH_WIDTH=$((1150)) # Condensed Width. (Opt. 1)
# SFMONO_GLYPH_WIDTH=$((1155)) # Condensed Width. (Opt. 2)
# SFMONO_GLYPH_WIDTH=$((1160)) # Condensed Width. (Opt. 3)
readonly SFMONO_GLYPH_WIDTH=$((1165))      # Condensed Width. (Opt. 4) So far the most natural
readonly SFMONO_GLYPH_SCALE=$((95))        # Condensed Scale.
readonly SFMONO_ITALIC_GLYPH_SCALE=$((90)) # Condensed Scale.
readonly VERSION="Version 2020-08-13"

### Trap
cleanup() { [[ -d "${TEMP_DIR:-}" ]] && rm -rf "$TEMP_DIR" > /dev/null 2>&1; }
trap 'cleanup' EXIT ERR HUP

### Early Exit
if ! command -v fontforge > /dev/null 2>&1; then
    echo "fontforge is not installed." >&2 && exit 1

elif ! command -v osascript > /dev/null 2>&1; then
    echo "This script supports macOS only." >&2 && exit 1
fi

# Option Parsing
if [[ $# -gt 0 ]]; then
    for option in "$@"; do
        case "$option" in
            -brew) HOMEBREW=true && shift ;;
            *) echo "Illegal option." >&2 && exit 1 ;;
        esac
    done
fi

### Variables
TEMP_DIR="./tmp"
USER_LIBRARY_FONT_DIR=~/Library/Fonts/Japantown
FONTFORGE_CMD='fontforge -lang=ff -script'

if ${HOMEBREW:-false}; then
    USER_LIBRARY_FONT_DIR=./build
fi

### Remove target dir
rm $USER_LIBRARY_FONT_DIR/* 2> /dev/null || :

SFMONO_FONTS=(
    "SF-Mono-Light.otf"
    "SF-Mono-LightItalic.otf"
    "SF-Mono-Regular.otf"
    "SF-Mono-RegularItalic.otf"
    "SF-Mono-Medium.otf"
    "SF-Mono-MediumItalic.otf"
    "SF-Mono-Semibold.otf"
    "SF-Mono-SemiboldItalic.otf"

    ### Not in use.
    # "SF-Mono-Bold.otf"
    # "SF-Mono-BoldItalic.otf"
    # "SF-Mono-Heavy.otf"
    # "SF-Mono-HeavyItalic.otf"
)
OTHER_FONTS=(
    "mplus-1m-light.otf"
    "mplus-1m-regular.otf"
    "mplus-1m-medium.otf"
    "mplus-1m-bold.otf"

    ### Alternative Japanese Font.
    # "rounded-mplus-1m-light.otf"
    # "rounded-mplus-1m-regular.otf"
    # "rounded-mplus-1m-medium.otf"
    # "rounded-mplus-1m-bold.otf"
)

### Prepare Environment
# Cd to this script's directory
cd "${0%/*}"

# Mkdir destination directory if needed
for dir in $TEMP_DIR $USER_LIBRARY_FONT_DIR; do
    [[ ! -d $dir ]] && mkdir -pv "$dir"
done

#################
### Functions ###
#################

# Modify SF Mono. $1 = SF Mono Font Path
saveCondensedSFMonoFont() {
    # EM (Original values)
    local SFMONO_ASCENT=$((1638))
    local SFMONO_DESCENT=$((410))

    # For 'SetOS2Value' (Original values)
    local OS2_ASCENT=$((1950))
    local OS2_DESCENT=$((494))
    local LINE_SPACING=$((0))

    local POST_SCRIPT_NAME
    local FAMILY_NAME
    local FULL_NAME
    local WEIGHT=$((0))
    local OS2_WEIGHT=$((300))
    local LETTERFORM=$((2))
    local EXPORT_NAME
    local DESTINATION

    : "${1%.*}" && : "${_/SF-Mono/Japantown}" && : "${_/Semibold/Bold}"
    POST_SCRIPT_NAME="$_"
    FAMILY_NAME="Japantown"
    : "${1%.*}" && : "${_//-/ }" && : "${_/SF Mono/Japantown}" && : "${_/Semibold/Bold}"
    FULL_NAME="$_"
    : "${1/Semibold/Bold}" && : "${_//SF-Mono/Japantown}"
    EXPORT_NAME="$_"

    # https://docs.microsoft.com/en-us/typography/opentype/spec/os2#wtc
    [[ $1 == *Light* ]] && WEIGHT=$((3)) && OS2_WEIGHT=$((300))
    [[ $1 == *Regular* ]] && WEIGHT=$((5)) && OS2_WEIGHT=$((400))
    [[ $1 == *Medium* ]] && WEIGHT=$((6)) && OS2_WEIGHT=$((500))
    [[ $1 == *Semibold* ]] && WEIGHT=$((8)) && OS2_WEIGHT=$((700))
    [[ $1 == *Italic* ]] && LETTERFORM=9

    DESTINATION="${TEMP_DIR}/${EXPORT_NAME/.otf/.sfd}"

    setTTFName() {
        # https://docs.microsoft.com/en-us/typography/opentype/spec/name
        # English  United States 0409
        # Japanese Japan         0411
        for langID in 0x409 0x411; do
            cat << EOL
SetTTFName($langID, 0, COPYRIGHT)        # Family Name
SetTTFName($langID, 1, "$FAMILY_NAME")   # Family Name
SetTTFName($langID, 3, FULLNAME_VERSION) # Fullname with Version / Build Number
SetTTFName($langID, 4, "$FULL_NAME")     # Fullname
SetTTFName($langID, 5, "$VERSION")       # Version / Build Number
SetTTFName($langID, 7, VENDOR_NAME)      # Vendor Name
SetTTFName($langID, 8, VENDOR_NAME)      # Vendor Name
SetTTFName($langID, 9, VENDOR_NAME)      # Vendor Name
SetTTFName($langID, 10, VENDOR_NAME)     # Vendor Name
SetTTFName($langID, 11, VENDOR_URL)      # Vendor URL
SetTTFName($langID, 12, VENDOR_URL)      # Vendor URL
SetTTFName($langID, 13, LISENCE)         # Lisence Agreement
SetTTFName($langID, 14, VENDOR_URL)      # Vendor URL'
EOL
        done
    }

    zenkakunize() {
        cat << EOL
SelectNone()
Select($1); Copy()
Select($2); Paste()
Scale(120, 105)
SetWidth($((SFMONO_GLYPH_WIDTH * 2)))
CenterInWidth()
SelectNone()
EOL
    }

    zenkakunize2() {
        cat << EOL
SelectNone()
Select($1)
Move(500, 0)
SetWidth($((SFMONO_GLYPH_WIDTH * 2)))
SelectNone()
EOL
    }

    zenkakunize3() {
        cat << EOL
SelectNone()
Select($1)
Scale(130)
Move(500, 0)
SetWidth($((SFMONO_GLYPH_WIDTH * 2)))
SelectNone()
EOL
    }

    $FONTFORGE_CMD 2> /dev/null << EOL
Open("$1")
Print("==> Processing: ${EXPORT_NAME}")

## Variables
## Those should be declared inside FontForge script due to escaping issues.
COPYRIGHT = "Copyright (c) 2019 aerobounce.github.io\n" \\
          + "Copyright (c) 2016-2019 Apple Inc. All rights reserved.\n" \\
          + "Copyright (c) 2019 M+ FONTS PROJECT" \\

LISENCE = "# ${FAMILY_NAME}\n" \\
        + "Made by github.com/aerobounce.\n" \\
        + "The same license of 'SF Mono' is applied to this font family, " \\
        + "as it is based on the Apple font family.\n\n" \\
        + "# SF Mono\n" \\
        + "Made and Licensed by Apple Inc.\n" \\
        + "It is not allowed to redistribute font binary files.\n" \\
        + "For more information, visit: https://developer.apple.com/fonts/\n\n" \\
        + "# M+ 1m\n" \\
        + "Made by M+ FONTS.\n" \\
        + "M+ FONTS License."
FULLNAME_VERSION = "${FULL_NAME}; Based on: " + GetTTFName(0x409, 3) \\
                 + " & M+ 1m 1.063a"
VENDOR_URL = "https://github.com/aerobounce"
VENDOR_NAME = "aerobounce"

#! Set Names / Metadata
SetFontNames("$POST_SCRIPT_NAME", \\
             "$FAMILY_NAME", \\
             "$FULL_NAME", \\
             GetTTFName(0x409, 17), \\
             COPYRIGHT, \\
             "$VERSION")

#! Set TTF Names
$(setTTFName)

#! Set OS2 Values
#! https://docs.microsoft.com/en-us/typography/opentype/spec/os2#wtc
SetOS2Value("VendorID"             , "ARBC")
SetOS2Value("IBMFamily"            , 2057)
SetOS2Value("Weight"               , $OS2_WEIGHT)

SetOS2Value("WinAscent"            , $OS2_ASCENT)
SetOS2Value("WinDescent"           , $OS2_DESCENT)

SetOS2Value("TypoAscent"           , $OS2_ASCENT)
SetOS2Value("TypoDescent"          , $((-OS2_DESCENT)))

SetOS2Value("HHeadAscent"          , $OS2_ASCENT)
SetOS2Value("HHeadDescent"         , $((-OS2_DESCENT)))

SetOS2Value("TypoLineGap"          , $LINE_SPACING)
SetOS2Value("HHeadLineGap"         , $LINE_SPACING)
SetOS2Value("VHeadLineGap"         , $LINE_SPACING)

SetOS2Value("WinAscentIsOffset"    , 0)
SetOS2Value("WinDescentIsOffset"   , 0)
SetOS2Value("TypoAscentIsOffset"   , 0)
SetOS2Value("TypoDescentIsOffset"  , 0)
SetOS2Value("HHeadAscentIsOffset"  , 0)
SetOS2Value("HHeadDescentIsOffset" , 0)

#! Set Panose
#! https://docs.microsoft.com/en-us/typography/opentype/spec/os2#wtc
SetPanose([2, 11, $WEIGHT, 9, 2, 2, 3, $LETTERFORM, 2, 7])


#! Tighten Letter Spacing
SelectWorthOutputting()
UnlinkReference()
$(
        if [[ $1 == *Italic* ]]; then
            cat <<< "Scale($SFMONO_ITALIC_GLYPH_SCALE, 100)"
        else
            cat <<< "Scale($SFMONO_GLYPH_SCALE, 100)"
        fi
    )
SetWidth($SFMONO_GLYPH_WIDTH)
ScaleToEm($SFMONO_ASCENT, $SFMONO_DESCENT)
SelectNone()

#! Center in Width All Glyphs
# SelectWorthOutputting(); CenterInWidth();

#! Create Zenkaku Glyphs
$(zenkakunize "0u0021" "0uff01") # ! ！
$(zenkakunize "0u0022" "0uff02") # " ＂
$(zenkakunize "0u0023" "0uff03") # # ＃
$(zenkakunize "0u0024" "0uff04") # $ ＄
$(zenkakunize "0u0025" "0uff05") # % ％
$(zenkakunize "0u0026" "0uff06") # & ＆
$(zenkakunize "0u0027" "0uff07") # ' ＇
$(zenkakunize "0u0028" "0uff08") # ( （
$(zenkakunize "0u0029" "0uff09") # ) ）
$(zenkakunize "0u002a" "0uff0a") # * ＊
$(zenkakunize "0u002b" "0uff0b") # + ＋
$(zenkakunize "0u002c" "0uff0c") # , ，
$(zenkakunize "0u002d" "0uff0d") # - －
$(zenkakunize "0u002e" "0uff0e") # . ．
$(zenkakunize "0u002f" "0uff0f") # / ／
$(zenkakunize "0u0030" "0uff10") # 0 ０
$(zenkakunize "0u0031" "0uff11") # 1 １
$(zenkakunize "0u0032" "0uff12") # 2 ２
$(zenkakunize "0u0033" "0uff13") # 3 ３
$(zenkakunize "0u0034" "0uff14") # 4 ４
$(zenkakunize "0u0035" "0uff15") # 5 ５
$(zenkakunize "0u0036" "0uff16") # 6 ６
$(zenkakunize "0u0037" "0uff17") # 7 ７
$(zenkakunize "0u0038" "0uff18") # 8 ８
$(zenkakunize "0u0039" "0uff19") # 9 ９
$(zenkakunize "0u003a" "0uff1a") # : ：
$(zenkakunize "0u003b" "0uff1b") # ; ；
$(zenkakunize "0u003c" "0uff1c") # < ＜
$(zenkakunize "0u003d" "0uff1d") # = ＝
$(zenkakunize "0u003e" "0uff1e") # > ＞
$(zenkakunize "0u003f" "0uff1f") # ? ？
$(zenkakunize "0u0040" "0uff20") # @ ＠
$(zenkakunize "0u0041" "0uff21") # A Ａ
$(zenkakunize "0u0042" "0uff22") # B Ｂ
$(zenkakunize "0u0043" "0uff23") # C Ｃ
$(zenkakunize "0u0044" "0uff24") # D Ｄ
$(zenkakunize "0u0045" "0uff25") # E Ｅ
$(zenkakunize "0u0046" "0uff26") # F Ｆ
$(zenkakunize "0u0047" "0uff27") # G Ｇ
$(zenkakunize "0u0048" "0uff28") # H Ｈ
$(zenkakunize "0u0049" "0uff29") # I Ｉ
$(zenkakunize "0u004a" "0uff2a") # J Ｊ
$(zenkakunize "0u004b" "0uff2b") # K Ｋ
$(zenkakunize "0u004c" "0uff2c") # L Ｌ
$(zenkakunize "0u004d" "0uff2d") # M Ｍ
$(zenkakunize "0u004e" "0uff2e") # N Ｎ
$(zenkakunize "0u004f" "0uff2f") # O Ｏ
$(zenkakunize "0u0050" "0uff30") # P Ｐ
$(zenkakunize "0u0051" "0uff31") # Q Ｑ
$(zenkakunize "0u0052" "0uff32") # R Ｒ
$(zenkakunize "0u0053" "0uff33") # S Ｓ
$(zenkakunize "0u0054" "0uff34") # T Ｔ
$(zenkakunize "0u0055" "0uff35") # U Ｕ
$(zenkakunize "0u0056" "0uff36") # V Ｖ
$(zenkakunize "0u0057" "0uff37") # W Ｗ
$(zenkakunize "0u0058" "0uff38") # X Ｘ
$(zenkakunize "0u0059" "0uff39") # Y Ｙ
$(zenkakunize "0u005a" "0uff3a") # Z Ｚ
$(zenkakunize "0u005b" "0uff3b") # [ ［
$(zenkakunize "0u005c" "0uff3c") # \ ＼
$(zenkakunize "0u005d" "0uff3d") # ] ］
$(zenkakunize "0u005e" "0uff3e") # ^ ＾
$(zenkakunize "0u005f" "0uff3f") # _ ＿
$(zenkakunize "0u0060" "0uff40") # \` ｀
$(zenkakunize "0u0061" "0uff41") # a ａ
$(zenkakunize "0u0062" "0uff42") # b ｂ
$(zenkakunize "0u0063" "0uff43") # c ｃ
$(zenkakunize "0u0064" "0uff44") # d ｄ
$(zenkakunize "0u0065" "0uff45") # e ｅ
$(zenkakunize "0u0066" "0uff46") # f ｆ
$(zenkakunize "0u0067" "0uff47") # g ｇ
$(zenkakunize "0u0068" "0uff48") # h ｈ
$(zenkakunize "0u0069" "0uff49") # i ｉ
$(zenkakunize "0u006a" "0uff4a") # j ｊ
$(zenkakunize "0u006b" "0uff4b") # k ｋ
$(zenkakunize "0u006c" "0uff4c") # l ｌ
$(zenkakunize "0u006d" "0uff4d") # m ｍ
$(zenkakunize "0u006e" "0uff4e") # n ｎ
$(zenkakunize "0u006f" "0uff4f") # o ｏ
$(zenkakunize "0u0070" "0uff50") # p ｐ
$(zenkakunize "0u0071" "0uff51") # q ｑ
$(zenkakunize "0u0072" "0uff52") # r ｒ
$(zenkakunize "0u0073" "0uff53") # s ｓ
$(zenkakunize "0u0074" "0uff54") # t ｔ
$(zenkakunize "0u0075" "0uff55") # u ｕ
$(zenkakunize "0u0076" "0uff56") # v ｖ
$(zenkakunize "0u0077" "0uff57") # w ｗ
$(zenkakunize "0u0078" "0uff58") # x ｘ
$(zenkakunize "0u0079" "0uff59") # y ｙ
$(zenkakunize "0u007a" "0uff5a") # z ｚ
$(zenkakunize "0u007b" "0uff5b") # { ｛
$(zenkakunize "0u007c" "0uff5c") # | ｜
$(zenkakunize "0u007d" "0uff5d") # } ｝
$(zenkakunize "0u007e" "0uff5e") # ~ ～

#! Convert to Zenkaku width
# \$(zenkakunize2 "0u2011") # ‑
$(zenkakunize3 "0u2026") # …
$(zenkakunize3 "0u2034") # ‴
$(zenkakunize3 "0u20dd") # "⃝
$(zenkakunize3 "0u20de") # "⃞
$(zenkakunize3 "0u2190") # ←
$(zenkakunize3 "0u2191") # ↑
$(zenkakunize3 "0u2192") # →
$(zenkakunize3 "0u2193") # ↓
$(zenkakunize3 "0u2194") # ↔
$(zenkakunize3 "0u2195") # ↕
$(zenkakunize3 "0u2196") # ↖
$(zenkakunize3 "0u2197") # ↗
$(zenkakunize3 "0u2198") # ↘
$(zenkakunize3 "0u2199") # ↙
$(zenkakunize3 "0u21e7") # ⇧
$(zenkakunize3 "0u2303") # ⌃
$(zenkakunize3 "0u2318") # ⌘
$(zenkakunize3 "0u2325") # ⌥
$(zenkakunize3 "0u2326") # ⌦
$(zenkakunize3 "0u2327") # ⌧
$(zenkakunize3 "0u232b") # ⌫
$(zenkakunize3 "0u2460") # ①
$(zenkakunize3 "0u2461") # ②
$(zenkakunize3 "0u2462") # ③
$(zenkakunize3 "0u2463") # ④
$(zenkakunize3 "0u2464") # ⑤
$(zenkakunize3 "0u2465") # ⑥
$(zenkakunize3 "0u2466") # ⑦
$(zenkakunize3 "0u2467") # ⑧
$(zenkakunize3 "0u2468") # ⑨
$(zenkakunize3 "0u24ea") # ⓪
$(zenkakunize3 "0u24ff") # ⓿
$(zenkakunize3 "0u2500") # ─
$(zenkakunize3 "0u2501") # ━
$(zenkakunize2 "0u2502") # │
$(zenkakunize2 "0u2503") # ┃
$(zenkakunize3 "0u2504") # ┄
$(zenkakunize3 "0u2505") # ┅
$(zenkakunize2 "0u2506") # ┆
$(zenkakunize2 "0u2507") # ┇
$(zenkakunize3 "0u2508") # ┈
$(zenkakunize3 "0u2509") # ┉
$(zenkakunize3 "0u250a") # ┊
$(zenkakunize3 "0u250b") # ┋
$(zenkakunize2 "0u250c") # ┌
$(zenkakunize2 "0u250d") # ┍
$(zenkakunize2 "0u250e") # ┎
$(zenkakunize2 "0u250f") # ┏
$(zenkakunize2 "0u2510") # ┐
$(zenkakunize2 "0u2511") # ┑
$(zenkakunize2 "0u2512") # ┒
$(zenkakunize2 "0u2513") # ┓
$(zenkakunize2 "0u2514") # └
$(zenkakunize2 "0u2515") # ┕
$(zenkakunize2 "0u2516") # ┖
$(zenkakunize2 "0u2517") # ┗
$(zenkakunize2 "0u2518") # ┘
$(zenkakunize2 "0u2519") # ┙
$(zenkakunize2 "0u251a") # ┚
$(zenkakunize2 "0u251b") # ┛
$(zenkakunize2 "0u251c") # ├
$(zenkakunize2 "0u251d") # ┝
$(zenkakunize2 "0u251e") # ┞
$(zenkakunize2 "0u251f") # ┟
$(zenkakunize2 "0u2520") # ┠
$(zenkakunize2 "0u2521") # ┡
$(zenkakunize2 "0u2522") # ┢
$(zenkakunize2 "0u2523") # ┣
$(zenkakunize2 "0u2524") # ┤
$(zenkakunize2 "0u2525") # ┥
$(zenkakunize2 "0u2526") # ┦
$(zenkakunize2 "0u2527") # ┧
$(zenkakunize2 "0u2528") # ┨
$(zenkakunize2 "0u2529") # ┩
$(zenkakunize2 "0u252a") # ┪
$(zenkakunize2 "0u252b") # ┫
$(zenkakunize2 "0u252c") # ┬
$(zenkakunize2 "0u252d") # ┭
$(zenkakunize2 "0u252e") # ┮
$(zenkakunize2 "0u252f") # ┯
$(zenkakunize2 "0u2530") # ┰
$(zenkakunize2 "0u2531") # ┱
$(zenkakunize2 "0u2532") # ┲
$(zenkakunize2 "0u2533") # ┳
$(zenkakunize2 "0u2534") # ┴
$(zenkakunize2 "0u2535") # ┵
$(zenkakunize2 "0u2536") # ┶
$(zenkakunize2 "0u2537") # ┷
$(zenkakunize2 "0u2538") # ┸
$(zenkakunize2 "0u2539") # ┹
$(zenkakunize2 "0u253a") # ┺
$(zenkakunize2 "0u253b") # ┻
$(zenkakunize2 "0u253c") # ┼
$(zenkakunize2 "0u253d") # ┽
$(zenkakunize2 "0u253e") # ┾
$(zenkakunize2 "0u253f") # ┿
$(zenkakunize2 "0u2540") # ╀
$(zenkakunize2 "0u2541") # ╁
$(zenkakunize2 "0u2542") # ╂
$(zenkakunize2 "0u2543") # ╃
$(zenkakunize2 "0u2544") # ╄
$(zenkakunize2 "0u2545") # ╅
$(zenkakunize2 "0u2546") # ╆
$(zenkakunize2 "0u2547") # ╇
$(zenkakunize2 "0u2548") # ╈
$(zenkakunize2 "0u2549") # ╉
$(zenkakunize2 "0u254a") # ╊
$(zenkakunize2 "0u254b") # ╋
$(zenkakunize2 "0u2550") # ═
$(zenkakunize2 "0u2551") # ║
$(zenkakunize2 "0u2552") # ╒
$(zenkakunize2 "0u2553") # ╓
$(zenkakunize2 "0u2554") # ╔
$(zenkakunize2 "0u2555") # ╕
$(zenkakunize2 "0u2556") # ╖
$(zenkakunize2 "0u2557") # ╗
$(zenkakunize2 "0u2558") # ╘
$(zenkakunize2 "0u2559") # ╙
$(zenkakunize2 "0u255a") # ╚
$(zenkakunize2 "0u255b") # ╛
$(zenkakunize2 "0u255c") # ╜
$(zenkakunize2 "0u255d") # ╝
$(zenkakunize2 "0u255e") # ╞
$(zenkakunize2 "0u255f") # ╟
$(zenkakunize2 "0u2560") # ╠
$(zenkakunize2 "0u2561") # ╡
$(zenkakunize2 "0u2562") # ╢
$(zenkakunize2 "0u2563") # ╣
$(zenkakunize2 "0u2564") # ╤
$(zenkakunize2 "0u2565") # ╥
$(zenkakunize2 "0u2566") # ╦
$(zenkakunize2 "0u2567") # ╧
$(zenkakunize2 "0u2568") # ╨
$(zenkakunize2 "0u2569") # ╩
$(zenkakunize2 "0u256a") # ╪
$(zenkakunize2 "0u256b") # ╫
$(zenkakunize2 "0u256c") # ╬
$(zenkakunize2 "0u256d") # ╭
$(zenkakunize2 "0u256e") # ╮
$(zenkakunize2 "0u256f") # ╯
$(zenkakunize2 "0u2570") # ╰
$(zenkakunize2 "0u2571") # ╱
$(zenkakunize2 "0u2572") # ╲
$(zenkakunize2 "0u2573") # ╳
$(zenkakunize2 "0u2574") # ╴
$(zenkakunize3 "0u2591") # ░
$(zenkakunize3 "0u2592") # ▒
$(zenkakunize3 "0u2593") # ▓
$(zenkakunize3 "0u25a0") # ■
$(zenkakunize3 "0u25a1") # □
$(zenkakunize3 "0u25b2") # ▲
$(zenkakunize3 "0u25b6") # ▶
$(zenkakunize3 "0u25bc") # ▼
$(zenkakunize3 "0u25c0") # ◀
$(zenkakunize3 "0u25cb") # ○
$(zenkakunize3 "0u25cf") # ●
$(zenkakunize3 "0u2713") # ✓
$(zenkakunize3 "0u2717") # ✗
$(zenkakunize3 "0u278a") # ➊
$(zenkakunize3 "0u278b") # ➋
$(zenkakunize3 "0u278c") # ➌
$(zenkakunize3 "0u278d") # ➍
$(zenkakunize3 "0u278e") # ➎
$(zenkakunize3 "0u278f") # ➏
$(zenkakunize3 "0u2790") # ➐
$(zenkakunize3 "0u2791") # ➑
$(zenkakunize3 "0u2792") # ➒
$(zenkakunize3 "0u2934") # ⤴
$(zenkakunize3 "0u2935") # ⤵
$(zenkakunize3 "0u2936") # ⤶
$(zenkakunize3 "0u2937") # ⤷
$(zenkakunize3 "0uf6d5") # 
$(zenkakunize3 "0uf6d6") # 
$(zenkakunize3 "0uf6d7") # 
$(zenkakunize3 "0uf6d8") # 

#! Align Characters
SelectNone()
Select("("); Move(0, -40)
Select(")"); Move(0, -40)
Select("{"); Move(0, -40)
Select("}"); Move(0, -40)
Select("["); Move(0, -40)
Select("]"); Move(0, -40)
Select("|"); Move(0, 90)
Select("_"); Move(0, 130)
SelectNone()

#! Adjust Characters' Scaling / Visual
SelectNone()
Select("@") ; Scale(95, 80)   ; CenterInWidth() ; SetWidth($SFMONO_GLYPH_WIDTH)
Select("#") ; Skew(-100, 100) ; CenterInWidth() ; SetWidth($SFMONO_GLYPH_WIDTH)
Select("#") ; Scale(90, 100)  ; CenterInWidth() ; SetWidth($SFMONO_GLYPH_WIDTH)
Select("$") ; Scale(95, 100)  ; CenterInWidth() ; SetWidth($SFMONO_GLYPH_WIDTH)
Select("%") ; Scale(85, 98)   ; CenterInWidth() ; SetWidth($SFMONO_GLYPH_WIDTH)
Select("&") ; Scale(95, 98)   ; CenterInWidth() ; SetWidth($SFMONO_GLYPH_WIDTH)
SelectNone()

#! Save Font
Print("==> Saving: ${DESTINATION}...")
Save("$DESTINATION")
Print("==> Saved: ${DESTINATION}")
EOL
}

# Adjust Other Font. $1 = Other Font Path
saveCondensedOtherFont() {
    local SFMONO_EM=$((2048)) # SF Mono's original Value.
    local DESTINATION="${TEMP_DIR}/${1/.otf/.sfd}"
    local DESTINATION_ITALIC="${DESTINATION/.sfd/Italic.sfd}"
    local ITALIC_FRACTION=$((10))

    $FONTFORGE_CMD 2> /dev/null << EOL
Open("$1")
Print("==> Processing: ${TEMP_DIR}/${1}")

#! Remove Glyphys Unneeded
# Print("==> Remove Glyphys Unneeded")
SelectWorthOutputting()
SelectInvert()
Clear()
SelectNone()

#! Visualize Full-Width Space; *Thanks Ricty
# Print("==> Visualize Full-Width Space")
SelectNone()
Select(0u2610); Copy(); Select(0u3000); Paste()
Select(0u271a); Copy(); Select(0u3000); PasteInto()
OverlapIntersect()
SelectNone()

#! Align Characters (The other font will get mis-aligned as a consequence of scaling.)
SelectNone()
Select(0uFF61, 0uFF9F) # Hankaku
Move(350, 350)
SelectWorthOutputting()
SelectFewer(0uFF61, 0uFF9F) # Zenkaku
Move(650, 350)
Select(0u3001, 0u3002) # 、。
Move(-350, -350)
SelectNone()

#! Adjust Characters' Scaling / Visual
SelectNone()
# Select(0u3000); Move(650, 350)
# Select(""); Scale(90, 100); CenterInWidth(); SetWidth($SFMONO_GLYPH_WIDTH);
SelectNone()

#! Scale
# Print("==> Scaling")
SelectWorthOutputting()
UnlinkReference()
ScaleToEm($((SFMONO_EM / 2)))
Scale(200)
SelectNone()

#! Adjust Zenkaku / Hankaku Letter Widths
# Print("==> Adjusting Zenkaku / Hankaku Letter Widths")
SelectNone()
Select(0uFF61, 0uFF9F) # Hankaku
SetWidth($((SFMONO_GLYPH_WIDTH)))
SelectWorthOutputting()
SelectFewer(0uFF61, 0uFF9F) # Zenkaku
SetWidth($((SFMONO_GLYPH_WIDTH * 2)))
SelectNone()

#! Clean-up
# Print("==> Clean-up")
Select(".notdef")
DetachAndRemoveGlyphs()
SelectWorthOutputting()
RoundToInt()
ClearInstrs()

#! Save Font
Print("==> Saving: ${DESTINATION}...")
Save("$DESTINATION")
Print("==> Saved: ${DESTINATION}")

#! Skew
# Print("==> Apply Skew")
SelectWorthOutputting()
Skew($ITALIC_FRACTION)
RoundToInt()

#! Save Skewed Font
Print("==> Saving: ${DESTINATION_ITALIC}...")
Save("$DESTINATION_ITALIC")
Print("==> Saved: ${DESTINATION_ITALIC}")
EOL
}

# Merge, generate and export fonts. $1 = SF Mono Path, $2 = Other Font Path
mergeAndExportFonts() {
    local EXPORT_NAME
    : "${1##*/}" && : "${_/SF-Mono/Japantown}" && : "${_/.sfd/.otf}"
    EXPORT_NAME="$_"

    $FONTFORGE_CMD 2> /dev/null << EOL
Open("$1")
Print("==> Merging: ${1##*/} & ${2##*/}...")

#! Merge Fonts
MergeFonts("$2")

#! Clean-up
# SelectWorthOutputting()
# RoundToInt()
# RemoveOverlap() # Emits overlapping warning log.
# RoundToInt()
AutoHint()
AutoInstr()

#! Generate Font
## 0x04 => Generate a short 'post' table with no glyph name info in it.
## 0x80 => Generate tables so the font will work on both Apple and MS platforms.
Print("==> Generating: ${USER_LIBRARY_FONT_DIR}/${EXPORT_NAME}...")
Generate("${USER_LIBRARY_FONT_DIR}/${EXPORT_NAME}", "", 0x84)
Print("==> Generated: ${USER_LIBRARY_FONT_DIR}/${EXPORT_NAME}")
EOL
}

# Modify Other Fonts
modifyOtherFonts() {
    for OTHER_FONT in "${OTHER_FONTS[@]}"; do
        # Exit if a file doesn't exist.
        [[ ! -e $OTHER_FONT ]] &&
            echo "$OTHER_FONT doesn't exist." >&2 &&
            break &&
            exit 1
        saveCondensedOtherFont "$OTHER_FONT" &
    done
    wait
}

# Modify SF Mono Fonts
modifySFFonts() {
    for SFMONO_FONT in "${SFMONO_FONTS[@]}"; do
        # Exit if a file doesn't exist.
        [[ ! -e $SFMONO_FONT ]] &&
            echo "$SFMONO_FONT doesn't exist." >&2 &&
            break &&
            exit 1
        saveCondensedSFMonoFont "$SFMONO_FONT" &
    done
    wait
}

# Merge Fonts
mergeFonts() {
    local index=$((0))
    local isItalic=false

    for SFMONO_FONT in "${SFMONO_FONTS[@]}"; do
        : "$SFMONO_FONT"
        : "${_/Semibold/Bold}"
        SFMONO_FONT="${_/SF-Mono/Japantown}"

        if $isItalic; then
            OTHER_FONT_PATH="${TEMP_DIR}/${OTHER_FONTS[$((index - 1))]/.otf/Italic.sfd}"
            isItalic=false
        else
            OTHER_FONT_PATH="${TEMP_DIR}/${OTHER_FONTS[$index]/.otf/.sfd}"
            isItalic=true
            index=$((index + 1))
        fi

        mergeAndExportFonts \
            "${TEMP_DIR}/${SFMONO_FONT/.otf/.sfd}" \
            "$OTHER_FONT_PATH" &
    done
    wait
}

############
### Main ###
############

modifyOtherFonts # multiprocess
modifySFFonts    # multiprocess
mergeFonts       # multiprocess

echo "${0##*/}: Succeess!"

# Post notification
if ! ${HOMEBREW:-false}; then
    : "display notification"
    : "$_ \"Successful\" with title \"${0##*/}\""
    : "$_ sound name \"Tink\""
    osascript -e "$_" &
fi
