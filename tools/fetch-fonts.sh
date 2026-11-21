#!/usr/bin/env bash
# Fetches the customisers' fonts (#/create, #/typeset) from Google Fonts into
# docs/bin/fonts/: for each family, its upright latin subset as one variable
# woff2 (the wght axis's full range), and its licence. Only families under
# the SIL Open Font License are fetched (google/fonts keeps them in ofl/);
# the others are listed disabled in the pickers. Run from the repository's
# root; needs curl.
set -euo pipefail
out=docs/bin/fonts
mkdir -p "$out"
ua="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120 Safari/537.36"
gh=https://raw.githubusercontent.com/google/fonts/main

# name (shadcn's id) | Google Fonts family
while IFS='|' read -r name family; do
	dir=$(echo "$family" | tr -d ' ' | tr '[:upper:]' '[:lower:]')
	if ! meta=$(curl -sfL "$gh/ofl/$dir/METADATA.pb"); then
		echo "skip  $name: not under ofl/" >&2
		continue
	fi
	min=$(echo "$meta" | awk '/tag: "wght"/{f=1} f&&/min_value/{print $2; exit}')
	max=$(echo "$meta" | awk '/tag: "wght"/{f=1} f&&/max_value/{print $2; exit}')
	q=$(echo "$family" | tr ' ' '+')
	if [ -n "$min" ]; then q="$q:wght@${min%.0}..${max%.0}"; fi
	css=$(curl -sfL -A "$ua" "https://fonts.googleapis.com/css2?family=$q&display=swap")
	url=$(echo "$css" | awk '/\/\* latin \*\//{f=1} f&&/src: url/{match($0,/https:[^)]*/); print substr($0,RSTART,RLENGTH); exit}')
	curl -sfL "$url" -o "$out/$name.woff2"
	curl -sfL "$gh/ofl/$dir/OFL.txt" -o "$out/$name-OFL.txt"
	echo "ok    $name (${min%.0}..${max%.0}) $(stat -c %s "$out/$name.woff2")B"
done <<'LIST'
geist|Geist
inter|Inter
noto-sans|Noto Sans
nunito-sans|Nunito Sans
figtree|Figtree
roboto|Roboto
raleway|Raleway
dm-sans|DM Sans
public-sans|Public Sans
outfit|Outfit
oxanium|Oxanium
manrope|Manrope
space-grotesk|Space Grotesk
montserrat|Montserrat
ibm-plex-sans|IBM Plex Sans
source-sans-3|Source Sans 3
instrument-sans|Instrument Sans
jetbrains-mono|JetBrains Mono
geist-mono|Geist Mono
noto-serif|Noto Serif
roboto-slab|Roboto Slab
merriweather|Merriweather
lora|Lora
playfair-display|Playfair Display
eb-garamond|EB Garamond
instrument-serif|Instrument Serif
LIST
