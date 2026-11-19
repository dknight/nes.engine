#!/usr/bin/env bash

set -euo pipefail

# Displays the complete 64-color NES palette in a 4×16 terminal table with RGB
# backgrounds and readable hexadecimal indices. Highlights color $0D and warns
# about its potential compatibility issues with some TVs.

colors=(
	"98 98 98" "00 00 BB" "37 00 BF" "84 00 A6"
	"BB 00 6A" "B7 00 1E" "B1 00 00" "91 26 00"
	"7B 2B 00" "00 3E 00" "00 48 0D" "00 3C 22"
	"00 32 5A" "00 00 00" "00 00 00" "00 00 00"

	"C8 C8 C8" "00 59 FF" "44 3C FF" "B7 2C FF"
	"FF 00 FF" "FF 00 5F" "FF 00 00" "D7 3E 00"
	"C7 5E 00" "00 7A 00" "00 8B 00" "00 7E 56"
	"00 70 9C" "00 00 00" "00 00 00" "00 00 00"

	"FF FF FF" "3F BF FF" "6F 8B FF" "D0 7B FF"
	"FF 6B FF" "FF 59 9F" "FF 5A 5A" "FF 8C 3F"
	"FF A8 00" "B9 C5 00" "8C D5 00" "4D D5 6A"
	"45 C9 B0" "00 00 00" "00 00 00" "00 00 00"

	"FF FF FF" "AB E7 FF" "C7 D7 FF" "E7 C7 FF"
	"FF C7 FF" "FF BF FF" "FF B3 B3" "FF DB AB"
	"FF E7 9C" "E7 F7 7B" "C7 FF 7B" "AB F7 B3"
	"B3 FF F3" "00 00 00" "00 00 00" "00 00 00"
)

RESET='\033[0m'

# Convert hexadecimal RGB channel to linear luminance.
linearize() {
	local value=$((16#$1))

	awk -v c="$value" 'BEGIN {
		c = c / 255
		if (c <= 0.04045)
			print c / 12.92
		else
			print ((c + 0.055) / 1.055) ^ 2.4
	}'
}

# Display palette as a 4x16 table.
for row in {0..3}; do
	for col in {0..15}; do
		index=$((row * 16 + col))

		read -r r g b <<< "${colors[$index]}"

		# Calculate relative luminance.
		lr=$(linearize "$r")
		lg=$(linearize "$g")
		lb=$(linearize "$b")

		luminance=$(awk \
			-v r="$lr" -v g="$lg" -v b="$lb" \
			'BEGIN {
				print 0.2126*r + 0.7152*g + 0.0722*b
			}')

		# Select contrasting foreground color.
		if awk -v l="$luminance" 'BEGIN { exit !(l > 0.179) }'; then
			fg="0;0;0"
		else
			fg="255;255;255"
		fi

		marker=" "
		if (( index == 13 )); then
			marker="!"
		fi

		printf '\033[1;48;2;%d;%d;%dm\033[38;2;%sm%s$%02X \033[0m ' \
			"$((16#$r))" "$((16#$g))" "$((16#$b))" \
			"$fg" "$marker" "$index"
	done

	echo
	echo
done

echo -e "\033[1;97;41mWARNING!  Do not use color \$0D!\033[0m"
echo -e "\033[1mIt results in a 'blacker than black' signal that may cause problems for some TVs.\033[0m"

