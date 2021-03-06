#!/bin/sh

. rotlib.sh

# Set of functions useful to generate a Python exam/hunt.

# Run a piece of code using Python3 conventions.
python3_run () {
    python -c "from __future__ import division
from __future__ import print_function

$1"
}

# Print a big array literal
python_big_array() {
    printf '['
    printf '\n    1,2,     4,   -23,    5,      5432,                       666,   108,'
    for i in $(seq 9) $(seq 9); do # We can't go above 9 to allow dechashes[$i$j].
	printf '\n    '
	for j in $(seq 0 $(dechash_bound "$1$i" 40)); do
	    printf '%s, ' "${dechashes[$i$j]}"
	done
	if [ $i = 8 ]
	then
	    printf '\n    7175, 5648, 2345, 42, 105, -8447, 2562, 9944, 1677, 6995,'
	fi
    done
    printf '\n    1,2,\n    4,\n    23,    -555,      5432,                       -666,   114,'
    echo "42]" 
}

python_big_string() {
    printf '("blablabla"'
    for i in $(seq 9) $(seq 9); do
	for j in $(seq 9); do
	    printf '+ "%s"' "${hashes[$i]}${dechashes[$i$j]}ii"
	done
	if [ $i = 7 ]
	then
	    printf '+ "%s" + "%s"' "${hashes[$i]}ic" "i${dechashes[$i$j]}"
	fi
	for j in $(seq 9); do
	    printf '+ "%s"' "${hashes[$j]}i${dechashes[$i$j]}"
	done
	printf '\n'
    done
    printf ")"
}

python_numpy_array() {
    printf "numpy.array([\n"
    for k in $(seq 0 5); do
	for i in $(seq 9); do
	    python_print_line
	    echo ','
	done
    done
    python_print_line
    echo "])"
}

python_print_line() {
    printf '        ['
    for k in $(seq 0 5); do
	for j in $(seq 0 9); do
	    printf '%s, ' "${dechashes[$i$j]}"
	done
    done
    printf "${dechashes[$i]}]"
}

python_shebang_docstring() {
    echo "#! /usr/bin/env python3"
    if [ -n "$1" ]; then
	printf '"""\n%s\n"""\n\n' "$1"
    fi
    printf '%s\n' '# We are writing purposely unreadable code.'
    printf '%s\n' "# Don't let Pylint complain about it:"
    printf '%s\n' '# pylint: disable=exec-used,invalid-name'
    printf '%s\n' '# pylint: disable=using-constant-test,redefined-outer-name'
    printf '%s\n' '# pylint: disable=blacklisted-name,missing-docstring'
    echo
}

python_header() {
    cat <<EOF
dec = str.maketrans("$full_alphabetdecale",
                    "$full_alphabet")
EOF
}

python_obfuscate_code() {
    python_header
    python_obfuscate_lines
}

python_cut_string() {
    perl -pe 's/^(exec\('\''([^\\'\'']|\\.){45})/\1'\''\n     '\''/'
}

python_obfuscate_lines() {
    (
	IFS='\n'
	while read -r line;
	do
	    if printf "%s" "$line" | grep -q ':[ \t]*$'; then
		# Don't obfuscate control-flow
		printf '%s\n' "$line"
	    else
		indent="${line%%[^ ]*}"
		coded=$(printf "%s" "$line" | \
			       sed 's/^[ \t]*//' | \
			       decalepipe | \
			       python_escape_string
		     )
		printf "%sexec('%s'.translate(dec))\n" "$indent" "$coded"
	    fi
	done
    )
}

python_noise() {
    echo 'if 1 == 0: print("'$RANDOM$RANDOM'")' | python_obfuscate_lines
    echo 'if 1234 != 1234: print("'$RANDOM'")' | python_obfuscate_lines
    printf '# %s\n' "$(uuid)"
    if [ -n "$PYTHON_NO_MULTILINE" ]; then
	echo 'while False: print("'$(uuid)'")'
    else
	echo 'while False:
    print("'$(uuid)'")'
    fi
}

python_obfuscate_text_verbose() {
    python_header
    python_printify | python_obfuscate_lines | (
	IFS='\n'
	while read -r line;
	do
	    printf '%s\n' "$line"
	    python_noise
	done
    ) | python_cut_string
}

python_printify() {
    python_escape_string | \
	sed "s/.*/print('\0')/"
}

python_obfuscate_text() {
    python_printify | python_obfuscate_code | python_cut_string
}

python_comment_out() {
    sed 's/^/# /'
}

python_escape_string() {
    sed -e "s/['\\]/\\\\\0/g"
}
