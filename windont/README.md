# Windon't

### A replacement for the Window API, created by someone who can't think of better names

To load Windon't, simply use `require` or `dofile`.

```lua
local windont = dofile("path/to/windont.lua")
```

Windon't contains two functions: one to make a new window object, and another to render them.
Beyond that, Windon't stores various default values that are used when creating new windows.

```lson
windont.default = {
	baseTerm = term.current(),	-- default base terminal for all windows
	textColor = "0",		-- default text color (what " " corresponds to in term.blit's second argument)
	backColor = "f",		-- default background color (what " " corresponds to in term.blit's third argument)
	blink = true,			-- default getCursorBlink
	visible = true,			-- default whether or not new windows are visible
	alwaysRender = true,		-- if true, new windows will always render if they are written to
}
```

### windont.newWindow
```
windont.newWindow(number x, number y, number width, number height, table miscData)
```
Creates a new window located at (`x`, `y`), with the specified `width` and `height`.	
By default, the base terminal used will be `windont.default.baseTerm`, which is normally set to `term.current()`.
"Windon'ts" naturally can be used with `term.redirect`, but they also come with a `meta` value which contains all the information of the object, including cursor X and Y, width and height, the whole framebuffer, the cursor blinking, and more.

Windon't windows behave very similarly to regular ol' Window API windows, with a few differences. For one, **Windon't windows support transparency when drawing over one another**.
Secondly, **Windon'ts support the use of individual transformation functions for characters, text colors, background colors, and the whole meta function.** Transformation functions are, if given, called every time the window is rendered. More on that later.

Additional values can be given to the newly created window through the `miscData` argument, including the base terminal and visibility.
Here are all the values that you can set by default with `miscData`:
```
buffer			
renderBuddies		-- table, a list of other windon't objects that will render beneath this one every time this redraws
baseTerm		-- window, the terminal that this windon't object will render onto
isColor

charTransformation	-- function, ran on every X and Y on the window's base temrinal, I'll explain in a bit
textTransformation	-- function, in a bit
backTransformation	-- function, in a bit
metaTransformation	-- function, takes in the 'meta' value of a windon't object so it can be modified

cursorX			-- number, starting cursor X
cursorY			-- number, starting cursor Y

textColor		-- string, starting text color ("0" through "f", or "-"" for transparency)
backColor		-- string, starting background color (same range as textColor)

blink			-- boolean, cursor blinking
alwaysRender		-- boolean, if true, then all term.write or term.blit calls will immediately render to the base temrinal
visible			-- boolean, if false, then the window just like, won't render, man
```

The normal transformation function (`transformation`, not `metaTransformation`) are called on every (x, y) position on the screen per window, and each one takes in six arguments:
	1. X position on the screen relative to the window's X position
	2. Y position on the screen relative to the window's Y position
	3. Character on the window's (X, Y) (if outside the buffer, is `nil`)
	4. Text color on the window's (X, Y) (if outside the buffer, is `nil`)
	5. Background color on the window's (X, Y) (if outside the buffer, is `nil`)
	6. `meta` value of the window
and return the following information:
	1. Table containing `{new character X position, new character Y position, new character}` (all optional values)
	2. Table containing `{new text X position, new text Y position, new text color}` (all optional values)
	3. Table containing `{new background X position, new background Y position, new background color}` (all optional values)

For instance, it could take in:
```
win.transformation(2, 6, "r", "2", "f", win.meta)`
```

... and return:

```
{2, 6, "R"}, {2, 6, "3"}, {"2, 6, "-"}
```

...with a light blue "R" with a transparent background being placed at (2, 6) to replace the lowercase "r".

`metaTransformation` is different in that it takes one value, being the window's `meta` value, and returns nothing. The `metaTransformation` function just modifies the `meta` value and that's it.

All transformation functions (besides metaTransformation) will not change the contents of the buffer, only alter how they are drawn to the screen.

## windont.render
```
windont.render(table options, window_1, window_2, ...)
```
Renders one or more Windon't objects onto their base terminals. If two or more windows share a base terminal, they will render layered atop each other from top to bottom, meaning that `window_1` will draw on top of `window_2`.
If windows contain any transparent regions (designated by the color "-" usable with `term.blit`), then the next window down the list will peek through.
Transparency is applied individually for text colors and background colors. If you have a window with a solid BG color but a transparent text color, then the background color of the underlying window will now be the text color of the above window, kinda like a text-shaped stencil.

The argument `options` is a table, and comes before any windows.
```lson
-- Potential options:
local options = {
	onlyX1 = 3,
	onlyX2 = 25,
	onlyY = 7,
	force = false,
	baseTerm = term.current()
}
```
The number values `onlyX1`, `onlyX2`, and `onlyY` limit where `windont.render()` draws on the screen. Specifically, it limits rendering to: `(onlyX1 >= x <= onlyX2, y == onlyY)`.
The boolean `force` option disables the optimization where `windont.render()` would compare the buffer it is about to draw to the last buffer it drew to reduce blit calls.
The terminal `baseTerm` option basically ensures that every window being passed through `windont.render()` will draw on the specified terminal.


If a window's meta has `alwaysRender = true`, then `windont.render` is called with that window, as well as the positions of the write/blit call.
