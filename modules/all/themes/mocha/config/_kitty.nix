{colors, fonts, ...}: ''
#: Fonts {{{

#: kitty has very powerful font management. You can configure
#: individual font faces and even specify special fonts for particular
#: characters.

font_family      ${fonts.highres.name}
bold_font        auto
italic_font      auto
bold_italic_font auto

#: You can specify different fonts for the bold/italic/bold-italic
#: variants. To get a full list of supported fonts use the `kitty
#: +list-fonts` command. By default they are derived automatically, by
#: the OSes font system. When bold_font or bold_italic_font is set to
#: auto on macOS, the priority of bold fonts is semi-bold, bold,
#: heavy. Setting them manually is useful for font families that have
#: many weight variants like Book, Medium, Thick, etc. For example::

#:     font_family      Operator Mono Book
#:     bold_font        Operator Mono Medium
#:     italic_font      Operator Mono Book Italic
#:     bold_italic_font Operator Mono Medium Italic

#: Font size (in pts)
#: TODO: maybe add specific font size for terminal
font_size 10


# force_ltr no

#: kitty does not support BIDI (bidirectional text), however, for RTL
#: scripts, words are automatically displayed in RTL. That is to say,
#: in an RTL script, the words "HELLO WORLD" display in kitty as
#: "WORLD HELLO", and if you try to select a substring of an RTL-
#: shaped string, you will get the character that would be there had
#: the string been LTR. For example, assuming the Hebrew word ירושלים,
#: selecting the character that on the screen appears to be ם actually
#: writes into the selection buffer the character י. kitty's default
#: behavior is useful in conjunction with a filter to reverse the word
#: order, however, if you wish to manipulate RTL glyphs, it can be
#: very challenging to work with, so this option is provided to turn
#: it off. Furthermore, this option can be used with the command line
#: program GNU FriBidi <https://github.com/fribidi/fribidi#executable>
#: to get BIDI support, because it will force kitty to always treat
#: the text as LTR, which FriBidi expects for terminals.

# symbol_map

# symbol_map U+E0A0-U+E0A3,U+E0C0-U+E0C7 MaterialIcons-Regular

#: Map the specified Unicode codepoints to a particular font. Useful
#: if you need special rendering for some symbols, such as for
#: Powerline. Avoids the need for patched fonts. Each Unicode code
#: point is specified in the form `U+<code point in hexadecimal>`. You
#: can specify multiple code points, separated by commas and ranges
#: separated by hyphens. This option can be specified multiple times.
#: The syntax is::

#:     symbol_map codepoints Font Family Name

# narrow_symbols

#: E.g. narrow_symbols U+E0A0-U+E0A3,U+E0C0-U+E0C7 1

#: Usually, for Private Use Unicode characters and some symbol/dingbat
#: characters, if the character is followed by one or more spaces,
#: kitty will use those extra cells to render the character larger, if
#: the character in the font has a wide aspect ratio. Using this
#: option you can force kitty to restrict the specified code points to
#: render in the specified number of cells (defaulting to one cell).
#: This option can be specified multiple times. The syntax is::

#:     narrow_symbols codepoints [optionally the number of cells]

# disable_ligatures never

#: Choose how you want to handle multi-character ligatures. The
#: default is to always render them. You can tell kitty to not render
#: them when the cursor is over them by using cursor to make editing
#: easier, or have kitty never render them at all by using always, if
#: you don't like them. The ligature strategy can be set per-window
#: either using the kitty remote control facility or by defining
#: shortcuts for it in kitty.conf, for example::

#:     map alt+1 disable_ligatures_in active always
#:     map alt+2 disable_ligatures_in all never
#:     map alt+3 disable_ligatures_in tab cursor

#: Note that this refers to programming ligatures, typically
#: implemented using the calt OpenType feature. For disabling general
#: ligatures, use the font_features option.

# font_features

font_features none
#: E.g. font_features none

#: Choose exactly which OpenType features to enable or disable. This
#: is useful as some fonts might have features worthwhile in a
#: terminal. For example, Fira Code includes a discretionary feature,
#: zero, which in that font changes the appearance of the zero (0), to
#: make it more easily distinguishable from Ø. Fira Code also includes
#: other discretionary features known as Stylistic Sets which have the
#: tags ss01 through ss20.

#: For the exact syntax to use for individual features, see the
#: HarfBuzz documentation <https://harfbuzz.github.io/harfbuzz-hb-
#: common.html#hb-feature-from-string>.

#: Note that this code is indexed by PostScript name, and not the font
#: family. This allows you to define very precise feature settings;
#: e.g. you can disable a feature in the italic font but not in the
#: regular font.

#: On Linux, font features are first read from the FontConfig database
#: and then this option is applied, so they can be configured in a
#: single, central place.

#: To get the PostScript name for a font, use `kitty +list-fonts
#: --psnames`:

#: .. code-block:: sh

#:     $ kitty +list-fonts --psnames | grep Fira
#:     Fira Code
#:     Fira Code Bold (FiraCode-Bold)
#:     Fira Code Light (FiraCode-Light)
#:     Fira Code Medium (FiraCode-Medium)
#:     Fira Code Regular (FiraCode-Regular)
#:     Fira Code Retina (FiraCode-Retina)

#: The part in brackets is the PostScript name.

#: Enable alternate zero and oldstyle numerals::

#:     font_features FiraCode-Retina +zero +onum

#: Enable only alternate zero in the bold font::

#:     font_features FiraCode-Bold +zero

#: Disable the normal ligatures, but keep the calt feature which (in
#: this font) breaks up monotony::

#:     font_features TT2020StyleB-Regular -liga +calt

#: In conjunction with force_ltr, you may want to disable Arabic
#: shaping entirely, and only look at their isolated forms if they
#: show up in a document. You can do this with e.g.::

#:     font_features UnifontMedium +isol -medi -fina -init

# modify_font

#: Modify font characteristics such as the position or thickness of
#: the underline and strikethrough. The modifications can have the
#: suffix px for pixels or % for percentage of original value. No
#: suffix means use pts. For example::

#:     modify_font underline_position -2
#:     modify_font underline_thickness 150%
#:     modify_font strikethrough_position 2px

#: Additionally, you can modify the size of the cell in which each
#: font glyph is rendered and the baseline at which the glyph is
#: placed in the cell. For example::

#:     modify_font cell_width 80%
#:     modify_font cell_height -2px
#:     modify_font baseline 3

#: Note that modifying the baseline will automatically adjust the
#: underline and strikethrough positions by the same amount.
#: Increasing the baseline raises glyphs inside the cell and
#: decreasing it lowers them. Decreasing the cell size might cause
#: rendering artifacts, so use with care.

# box_drawing_scale 0.001, 1, 1.5, 2

#: The sizes of the lines used for the box drawing Unicode characters.
#: These values are in pts. They will be scaled by the monitor DPI to
#: arrive at a pixel value. There must be four values corresponding to
#: thin, normal, thick, and very thick lines.

# undercurl_style thin-sparse

#: The style with which undercurls are rendered. This option takes the
#: form (thin|thick)-(sparse|dense). Thin and thick control the
#: thickness of the undercurl. Sparse and dense control how often the
#: curl oscillates. With sparse the curl will peak once per character,
#: with dense twice.

text_composition_strategy platform

#: Control how kitty composites text glyphs onto the background color.
#: The default value of platform tries for text rendering as close to
#: "native" for the platform kitty is running on as possible.

#: A value of legacy uses the old (pre kitty 0.28) strategy for how
#: glyphs are composited. This will make dark text on light
#: backgrounds look thicker and light text on dark backgrounds
#: thinner. It might also make some text appear like the strokes are
#: uneven.

#: You can fine tune the actual contrast curve used for glyph
#: composition by specifying up to two space-separated numbers for
#: this setting.

#: The first number is the gamma adjustment, which controls the
#: thickness of dark text on light backgrounds. Increasing the value
#: will make text appear thicker. The default value for this is 1.0 on
#: Linux and 1.7 on macOS. Valid values are 0.01 and above. The result
#: is scaled based on the luminance difference between the background
#: and the foreground. Dark text on light backgrounds receives the
#: full impact of the curve while light text on dark backgrounds is
#: affected very little.

#: The second number is an additional multiplicative contrast. It is
#: percentage ranging from 0 to 100. The default value is 0 on Linux
#: and 30 on macOS.

#: If you wish to achieve similar looking thickness in light and dark
#: themes, a good way to experiment is start by setting the value to
#: 1.0 0 and use a dark theme. Then adjust the second parameter until
#: it looks good. Then switch to a light theme and adjust the first
#: parameter until the perceived thickness matches the dark theme.

# text_fg_override_threshold 0

#: The minimum accepted difference in luminance between the foreground
#: and background color, below which kitty will override the
#: foreground color. It is percentage ranging from 0 to 100. If the
#: difference in luminance of the foreground and background is below
#: this threshold, the foreground color will be set to white if the
#: background is dark or black if the background is light. The default
#: value is 0, which means no overriding is performed. Useful when
#: working with applications that use colors that do not contrast well
#: with your preferred color scheme.

#: WARNING: Some programs use characters (such as block characters)
#: for graphics display and may expect to be able to set the
#: foreground and background to the same color (or similar colors).
#: If you see unexpected stripes, dots, lines, incorrect color, no
#: color where you expect color, or any kind of graphic display
#: problem try setting text_fg_override_threshold to 0 to see if this
#: is the cause of the problem.

#: }}}

#: Cursor customization {{{

cursor none

#: Default cursor color. If set to the special value none the cursor
#: will be rendered with a "reverse video" effect. It's color will be
#: the color of the text in the cell it is over and the text will be
#: rendered with the background color of the cell. Note that if the
#: program running in the terminal sets a cursor color, this takes
#: precedence. Also, the cursor colors are modified if the cell
#: background and foreground colors have very low contrast.

# cursor_text_color #111111

#: The color of text under the cursor. If you want it rendered with
#: the background color of the cell underneath instead, use the
#: special keyword: background. Note that if cursor is set to none
#: then this option is ignored.

cursor_shape beam

#: The cursor shape can be one of block, beam, underline. Note that
#: when reloading the config this will be changed only if the cursor
#: shape has not been set by the program running in the terminal. This
#: sets the default cursor shape, applications running in the terminal
#: can override it. In particular, shell integration
#: <https://sw.kovidgoyal.net/kitty/shell-integration/> in kitty sets
#: the cursor shape to beam at shell prompts. You can avoid this by
#: setting shell_integration to no-cursor.

cursor_beam_thickness 1.5

#: The thickness of the beam cursor (in pts).

# cursor_underline_thickness 2.0

#: The thickness of the underline cursor (in pts).

cursor_blink_interval 2

#: The interval to blink the cursor (in seconds). Set to zero to
#: disable blinking. Negative values mean use system default. Note
#: that the minimum interval will be limited to repaint_delay.

cursor_stop_blinking_after 7

#: Stop blinking cursor after the specified number of seconds of
#: keyboard inactivity. Set to zero to never stop blinking.

#: }}}


#: {{{ Theme Colors
## name: Nord
## author: Connor Holyday
## license: MIT
## upstream: https://raw.githubusercontent.com/connorholyday/nord-kitty/master/nord.conf
## blurb: An arctic, north-bluish clean and elegant Kitty theme.

# Nord Colorscheme for Kitty
# Based on:
# - https://gist.github.com/marcusramberg/64010234c95a93d953e8c79fdaf94192
# - https://github.com/arcticicestudio/nord-hyper

foreground            ${colors.types.fg}
background            ${colors.types.bg}

selection_foreground  #000000
selection_background  #FFFACD

active_border_color ${colors.blue}

#: The color for the border of the active window. Set this to none to
#: not draw borders around the active window.

inactive_border_color ${colors.types.bg}

#: The color for the border of inactive windows.

bell_border_color ${colors.red}

#: The color for the border of inactive windows in which a bell has
#: occurred.

url_color             ${colors.dimblue}
cursor                ${colors.brightblue}

# black
color0   ${colors.black}
color8   ${colors.brightblack}

# red
color1   ${colors.red}
color9   ${colors.brightred}

# green
color2   ${colors.green}
color10  ${colors.brightgreen}

# yellow
color3   ${colors.yellow}
color11  ${colors.brightyellow}

# blue
color4  ${colors.blue}
color12 ${colors.brightblue}

# magenta
color5   ${colors.magenta}
color13  ${colors.brightmagenta}

# cyan
color6   ${colors.cyan}
color14  ${colors.brightcyan}

# white
color7   ${colors.white}
color15  ${colors.brightwhite}

mark1_foreground black
mark1_background ${colors.dimblue}

mark2_foreground black
mark2_background ${colors.green}

mark3_foreground black
mark3_background ${colors.yellow}

# }}}

''
