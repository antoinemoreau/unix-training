#! /bin/bash

# Usage:
# echo 'some text' | txt2img file.png
# echo 'another text' | txt2img file.jpg 12
# with very old version of convert
# txt2img () {
#     mv -f "$1" "$1"~ 2>/dev/null || true
#     recode utf-8..latin1 | \
# 	a2ps -1 --font-size="${2:-16}" --landscape -o - 2>/dev/null | \
# 	convert -scale 1600 -rotate 90 -background white -flatten - "$1"
#     if [ ! -f "$1" ]; then
# 	echo "Conversion failed (more than 1 page?)"
# 	exit 1
#     fi
# }

txt2img () {
    mv -f "$1" "$1"~ 2>/dev/null || true
    convert text:- "$1"
    if [ ! -f "$1" ]; then
	echo "Conversion failed (more than 1 page?)"
	exit 1
    fi
}
