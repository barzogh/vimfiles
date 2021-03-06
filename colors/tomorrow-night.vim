" Tomorrow Night - Full Colour and 256 Colour
" http://chriskempson.com
"
" Hex colour conversion functions borrowed from the theme "Desert256""

let g:colors_name = "Tomorrow-Night"

" Default GUI Colours
let s:foreground = "c5c8c6"
let s:background = "151617"
let s:selection = "373b41"
let s:line = "282a2e"
let s:comment = "6A6C6B"
let s:red = "cc6666"
let s:orange = "de935f"
let s:yellow = "f0c674"
let s:green = "b5bd68"
let s:blue = "81a2be"
let s:purple = "b294bb"

" Console 256 Colours
if !has("gui_running")
	let s:background = "303030"
	let s:line = "3a3a3a"
	let s:selection = "585858"
end

set background=dark
hi clear
syntax reset

if has("gui_running") || &t_Co == 88 || &t_Co == 256
	" Returns an approximate grey index for the given grey level
	fun! <SID>grey_number(x)
		if &t_Co == 88
			if a:x < 23
				return 0
			elseif a:x < 69
				return 1
			elseif a:x < 103
				return 2
			elseif a:x < 127
				return 3
			elseif a:x < 150
				return 4
			elseif a:x < 173
				return 5
			elseif a:x < 196
				return 6
			elseif a:x < 219
				return 7
			elseif a:x < 243
				return 8
			else
				return 9
			endif
		else
			if a:x < 14
				return 0
			else
				let l:n = (a:x - 8) / 10
				let l:m = (a:x - 8) % 10
				if l:m < 5
					return l:n
				else
					return l:n + 1
				endif
			endif
		endif
	endfun

	" Returns the actual grey level represented by the grey index
	fun! <SID>grey_level(n)
		if &t_Co == 88
			if a:n == 0
				return 0
			elseif a:n == 1
				return 46
			elseif a:n == 2
				return 92
			elseif a:n == 3
				return 115
			elseif a:n == 4
				return 139
			elseif a:n == 5
				return 162
			elseif a:n == 6
				return 185
			elseif a:n == 7
				return 208
			elseif a:n == 8
				return 231
			else
				return 255
			endif
		else
			if a:n == 0
				return 0
			else
				return 8 + (a:n * 10)
			endif
		endif
	endfun

	" Returns the palette index for the given grey index
	fun! <SID>grey_colour(n)
		if &t_Co == 88
			if a:n == 0
				return 16
			elseif a:n == 9
				return 79
			else
				return 79 + a:n
			endif
		else
			if a:n == 0
				return 16
			elseif a:n == 25
				return 231
			else
				return 231 + a:n
			endif
		endif
	endfun

	" Returns an approximate colour index for the given colour level
	fun! <SID>rgb_number(x)
		if &t_Co == 88
			if a:x < 69
				return 0
			elseif a:x < 172
				return 1
			elseif a:x < 230
				return 2
			else
				return 3
			endif
		else
			if a:x < 75
				return 0
			else
				let l:n = (a:x - 55) / 40
				let l:m = (a:x - 55) % 40
				if l:m < 20
					return l:n
				else
					return l:n + 1
				endif
			endif
		endif
	endfun

	" Returns the actual colour level for the given colour index
	fun! <SID>rgb_level(n)
		if &t_Co == 88
			if a:n == 0
				return 0
			elseif a:n == 1
				return 139
			elseif a:n == 2
				return 205
			else
				return 255
			endif
		else
			if a:n == 0
				return 0
			else
				return 55 + (a:n * 40)
			endif
		endif
	endfun

	" Returns the palette index for the given R/G/B colour indices
	fun! <SID>rgb_colour(x, y, z)
		if &t_Co == 88
			return 16 + (a:x * 16) + (a:y * 4) + a:z
		else
			return 16 + (a:x * 36) + (a:y * 6) + a:z
		endif
	endfun

	" Returns the palette index to approximate the given R/G/B colour levels
	fun! <SID>colour(r, g, b)
		" Get the closest grey
		let l:gx = <SID>grey_number(a:r)
		let l:gy = <SID>grey_number(a:g)
		let l:gz = <SID>grey_number(a:b)

		" Get the closest colour
		let l:x = <SID>rgb_number(a:r)
		let l:y = <SID>rgb_number(a:g)
		let l:z = <SID>rgb_number(a:b)

		if l:gx == l:gy && l:gy == l:gz
			" There are two possibilities
			let l:dgr = <SID>grey_level(l:gx) - a:r
			let l:dgg = <SID>grey_level(l:gy) - a:g
			let l:dgb = <SID>grey_level(l:gz) - a:b
			let l:dgrey = (l:dgr * l:dgr) + (l:dgg * l:dgg) + (l:dgb * l:dgb)
			let l:dr = <SID>rgb_level(l:gx) - a:r
			let l:dg = <SID>rgb_level(l:gy) - a:g
			let l:db = <SID>rgb_level(l:gz) - a:b
			let l:drgb = (l:dr * l:dr) + (l:dg * l:dg) + (l:db * l:db)
			if l:dgrey < l:drgb
				" Use the grey
				return <SID>grey_colour(l:gx)
			else
				" Use the colour
				return <SID>rgb_colour(l:x, l:y, l:z)
			endif
		else
			" Only one possibility
			return <SID>rgb_colour(l:x, l:y, l:z)
		endif
	endfun

	" Returns the palette index to approximate the 'rrggbb' hex string
	fun! <SID>rgb(rgb)
		let l:r = ("0x" . strpart(a:rgb, 0, 2)) + 0
		let l:g = ("0x" . strpart(a:rgb, 2, 2)) + 0
		let l:b = ("0x" . strpart(a:rgb, 4, 2)) + 0

		return <SID>colour(l:r, l:g, l:b)
	endfun

	" Sets the highlighting for the given group
	fun! <SID>X(group, fg, bg, attr)
		if a:fg != ""
			exec "hi " . a:group . " guifg=#" . a:fg . " ctermfg=" . <SID>rgb(a:fg)
		endif
		if a:bg != ""
			exec "hi " . a:group . " guibg=#" . a:bg . " ctermbg=" . <SID>rgb(a:bg)
		endif
		if a:attr != ""
			exec "hi " . a:group . " gui=" . a:attr . " cterm=" . a:attr
		endif
	endfun

	" Vim Highlighting
	call <SID>X("Normal", s:foreground, s:background, "")
	call <SID>X("LineNr", s:comment, "", "")
	call <SID>X("NonText", s:selection, "", "")
	call <SID>X("SpecialKey", s:selection, "", "")
	call <SID>X("Search", s:background, s:yellow, "")
	call <SID>X("StatusLine", s:foreground, s:background, "reverse")
	call <SID>X("StatusLineNC", s:foreground, s:background, "reverse")
	call <SID>X("Visual", "", s:selection, "")
	call <SID>X("Directory", s:blue, "", "")
	call <SID>X("ModeMsg", s:green, "", "")
    call <SID>X("MoreMsg", s:green, "", "")
	call <SID>X("Question", s:green, "", "")
	call <SID>X("WarningMsg", s:red, "", "")
	if version >= 700
		call <SID>X("CursorLine", "", s:line, "none")
		call <SID>X("CursorColumn", "", s:line, "none")
		call <SID>X("PMenu", s:background, 'd3d3d3', "none")
		call <SID>X("PMenuSel", 'ffffff', s:blue, "none")
	end

	" Standard Highlighting
	call <SID>X("Comment", s:comment, "", "")
	call <SID>X("Todo", s:comment, "", "")
	call <SID>X("Title", s:comment, "", "")
	call <SID>X("Identifier", s:red, "", "none")
	call <SID>X("Statement", s:purple, "", "")
	call <SID>X("Conditional", s:purple, "", "")
	call <SID>X("Repeat", s:purple, "", "")
	call <SID>X("Structure", s:purple, "", "")
	call <SID>X("Function", s:blue, "", "")
	call <SID>X("Constant", s:orange, "", "")
	call <SID>X("String", s:green, "", "")
	call <SID>X("Special", s:blue, "", "")
	call <SID>X("PreProc", s:purple, "", "")
	call <SID>X("Operator", s:foreground, "", "none")
	call <SID>X("Type", s:blue, "", "none")
	call <SID>X("Define", s:purple, "", "none")
	call <SID>X("Include", s:blue, "", "") 
	"call <SID>X("Ignore", "666666", "", "")
	
	" Vim Highlighting
	call <SID>X("vimCommand", s:red, "", "none")

	" C Highlighting
	call <SID>X("cType", s:yellow, "", "")
	call <SID>X("cStorageClass", s:purple, "", "")

	" PHP Highlighting
	call <SID>X("phpVarSelector", s:red, "", "")
	call <SID>X("phpKeyword", s:purple, "", "")
	call <SID>X("phpRepeat", s:purple, "", "")
	call <SID>X("phpConditional", s:purple, "", "")
	call <SID>X("phpStatement", s:purple, "", "")
	call <SID>X("phpMemberSelector", s:foreground, "", "")
	
	" Ruby Highlighting
	call <SID>X("rubySymbol", s:orange, "", "")
	call <SID>X("rubyConstant", s:yellow, "", "")
	call <SID>X("rubyAttribute", s:blue, "", "")
	call <SID>X("rubyInclude", s:blue, "", "")
	call <SID>X("rubyLocalVariableOrMethod", s:orange, "", "")
	call <SID>X("rubyBlock", s:blue, "", "")
	call <SID>X("rubyCurlyBlock", s:orange, "", "")
	call <SID>X("rubyRegexp", s:orange, "", "")
	call <SID>X("rubyRegexpDelimiter", s:orange, "", "")
	call <SID>X("rubyEscape", s:orange, "", "")
	call <SID>X("rubyInterpolationDelimiter", s:orange, "", "")
	call <SID>X("rubyControl", s:purple, "", "")
	call <SID>X("rubyStringDelimiter", s:green, "", "")
	call <SID>X("rubyConditional", s:purple, "", "")

	call <SID>X("Conditional", s:purple, "", "")
	call <SID>X("Repeat", s:purple, "", "")

	" Delete Functions
	delf <SID>X
	delf <SID>rgb
	delf <SID>colour
	delf <SID>rgb_colour
	delf <SID>rgb_level
	delf <SID>rgb_number
	delf <SID>grey_colour
	delf <SID>grey_level
	delf <SID>grey_number
endif

let s:remi_grey_blue = '#8a9597'
let s:remi_light_grey_blue = '#a0a8b0'
let s:remi_dark_grey_blue = '#34383c'
let s:remi_mid_grey_blue = '#64686c'
let s:remi_beige = '#ceb67f'
let s:remi_light_orange = '#ebc471'
let s:remi_violet = '#a999ac'
let s:remi_lightgreen = '#c2c98f'
let s:remi_twilight_red = '#d08356'
let s:remi_cyan = '#74dad9'
let s:remi_darkgrey = '#202020'
let s:remi_grey = '#303030'
let s:remi_lightgrey = '#605958'
let s:remi_midgrey = '#888888'
let s:remi_white = '#fffedc'

exe 'hi User1          guibg='.s:remi_grey.'               guifg='.s:remi_white
exe 'hi User3          guibg='.s:remi_grey.'               guifg='.s:remi_midgrey
exe 'hi User4          guibg='.s:remi_grey.'               guifg='.s:remi_white
exe 'hi User5          guibg='.s:remi_grey.'               guifg='.s:remi_violet
exe 'hi User6          guibg='.s:remi_grey.'               guifg='.s:remi_twilight_red
exe 'hi User7          guibg='.s:remi_grey.'               guifg='.s:remi_light_orange
exe 'hi User8          guibg='.s:remi_violet.'             guifg='.s:remi_white
exe 'hi User9          guibg='.s:remi_grey.'               guifg='.s:remi_grey

exe 'hi Error          guifg='.s:remi_white             .' guibg='.s:remi_twilight_red

exe 'hi Folded         guifg='.s:remi_grey_blue         .' guibg='.s:remi_dark_grey_blue  .' gui=none'
exe 'hi FoldColumn     guifg='.s:remi_grey_blue         .' guibg='.s:remi_dark_grey_blue  .' gui=none'
exe 'hi SignColumn     guifg='.s:remi_grey_blue         .' guibg='.s:remi_dark_grey_blue  .' gui=none'

exe 'hi TODO           guifg='.s:remi_white         .' guibg=#cc6666    gui=italic,bold'
