#!/usr/bin/env bash
# Fails when a control sets a size with a number instead of a Theme token.
# 0 is allowed (it means "none"), and so is arithmetic on tokens (`height / 2`).
# Usage: check-size-literals.sh <Controls dir>
set -u
dir=${1:?usage: check-size-literals.sh <Controls dir>}

props='(Layout\.)?(implicitWidth|implicitHeight|width|height|minimumWidth|maximumWidth|preferredWidth|preferredHeight|radius|spacing|padding|leftPadding|rightPadding|topPadding|bottomPadding|horizontalPadding|verticalPadding|[a-zA-Z]*[mM]argins?|border\.width|font\.pixelSize|font\.letterSpacing|size|iconSize|icon\.width|icon\.height)'
sizeProp='property (int|real) [a-zA-Z]*(Width|Height|Size|size|Radius|radius|Thickness|thickness|Padding|Spacing|Gap|gap|Inset|notch)'
nonzero='([0-9]*[1-9][0-9]*(\.[0-9]+)?|0?\.[0-9]*[1-9][0-9]*)'

found=$(grep -nE \
    -e "^\s*(${props}|${sizeProp})\s*:\s*${nonzero}\s*$" \
    -e "^\s*${props}\s*:.*\?\s*${nonzero}\s*:" \
    -e "^\s*${props}\s*:.*\?[^:]*:\s*${nonzero}\s*\)?\s*$" \
    -e "Theme\.spacing\.[a-zA-Z]+\s*[-+]\s*[0-9]" \
    "$dir"/*.qml | grep -vE 'property int pageSize:')

if [ -n "$found" ]; then
    echo "Size literals in controls; use a Theme.size or Theme.controls token:"
    echo "$found"
    exit 1
fi
