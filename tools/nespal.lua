#!/usr/bin/env lua

-- Displays the complete 64-color NES palette in a 4x16 terminal table
-- with RGB backgrounds and readable hexadecimal indices.
-- Highlights color $0D and warns about potential compatibility issues.

local script_dir = arg[0]:match("(.*[/\\])") or "./"
package.path = script_dir .. "?.lua;" .. package.path

local ansi = require("ansicolors")

local colors = {
	"98 98 98", "00 00 BB", "37 00 BF", "84 00 A6",
	"BB 00 6A", "B7 00 1E", "B1 00 00", "91 26 00",
	"7B 2B 00", "00 3E 00", "00 48 0D", "00 3C 22",
	"00 32 5A", "00 00 00", "00 00 00", "00 00 00",

	"C8 C8 C8", "00 59 FF", "44 3C FF", "B7 2C FF",
	"FF 00 FF", "FF 00 5F", "FF 00 00", "D7 3E 00",
	"C7 5E 00", "00 7A 00", "00 8B 00", "00 7E 56",
	"00 70 9C", "00 00 00", "00 00 00", "00 00 00",

	"FF FF FF", "3F BF FF", "6F 8B FF", "D0 7B FF",
	"FF 6B FF", "FF 59 9F", "FF 5A 5A", "FF 8C 3F",
	"FF A8 00", "B9 C5 00", "8C D5 00", "4D D5 6A",
	"45 C9 B0", "00 00 00", "00 00 00", "00 00 00",

	"FF FF FF", "AB E7 FF", "C7 D7 FF", "E7 C7 FF",
	"FF C7 FF", "FF BF FF", "FF B3 B3", "FF DB AB",
	"FF E7 9C", "E7 F7 7B", "C7 FF 7B", "AB F7 B3",
	"B3 FF F3", "00 00 00", "00 00 00", "00 00 00",
}

local RESET = "\27[0m"

-- Convert an sRGB channel to linear RGB.
local function linearize(value)
	value = value / 255

	if value <= 0.04045 then
		return value / 12.92
	end

	return ((value + 0.055) / 1.055) ^ 2.4
end

-- Format a palette cell with a true-color ANSI background.
local function format_palette_cell(index, r, g, b)
	local luminance =
		0.2126 * linearize(r) +
		0.7152 * linearize(g) +
		0.0722 * linearize(b)

	local fg = luminance > 0.179
		and "\27[38;2;0;0;0m"
		or "\27[38;2;255;255;255m"

	local marker = index == 13 and "!" or " "

	return string.format(
		"\27[1;48;2;%d;%d;%dm%s%s$%02X %s ",
		r, g, b,
		fg,
		marker,
		index,
		RESET
	)
end

local function print_warning()
	io.write(ansi("%{bright white redbg}WARNING!  Do not use color $0D!") .. "\n")
	io.write(ansi("%{bright}It results in a 'blacker than black' signal that may cause problems for some TVs.") .. "\n")
end

-- Display palette as a 4x16 table.
for row = 0, 3 do
	for col = 0, 15 do
		local index = row * 16 + col
		local r, g, b = colors[index + 1]:match("(%x+) (%x+) (%x+)")

		r = tonumber(r, 16)
		g = tonumber(g, 16)
		b = tonumber(b, 16)

		io.write(format_palette_cell(index, r, g, b))
	end

	io.write("\n\n")
end

print_warning()
