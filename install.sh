#!/usr/bin/env bash
set -Ceu

### Constants
# SFMONO_GLYPH_WIDTH=$((1150)) # Condensed Width. (Opt. 1)
# SFMONO_GLYPH_WIDTH=$((1155)) # Condensed Width. (Opt. 2)
# SFMONO_GLYPH_WIDTH=$((1160)) # Condensed Width. (Opt. 3)
readonly SFMONO_GLYPH_WIDTH=$((1165)) # Condensed Width. (Opt. 4) So far the most natural
readonly SFMONO_GLYPH_SCALE=$((97))   # Condensed Scale.
readonly VERSION="Version 2019-12-27"

### Trap
cleanup() { rm -rf "$TEMP_DIR" > /dev/null 2>&1; }
trap 'cleanup' EXIT ERR HUP

### Early Exit
if ! command -v fontforge > /dev/null 2>&1; then
    echo "fontforge is not installed." >&2 && exit 1

elif ! command -v osascript > /dev/null 2>&1; then
    echo "Currently this script supports macOS only." >&2 && exit 1
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
Scale($SFMONO_GLYPH_SCALE, 100)
SetWidth($SFMONO_GLYPH_WIDTH)
ScaleToEm($SFMONO_ASCENT, $SFMONO_DESCENT)
SelectNone()

#! Center in Width All Glyphs
SelectWorthOutputting(); CenterInWidth();

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
