. "$EXAM_DIR"/exam-lib.sh
. "$EXAM_DIR"/exam-obfuscation-lib.sh

usage () {
            cat << EOF
Usage: $(basename $0) [options]
Options:
	--help		This help message.
	--output, -o	Specify output file
	--cleanup	Clean existing directories before running
	--verbose	Show more output
EOF
}

outdir=exam_genere
outphp=
cleanup=no
basedir=$(pwd)
verbose=no

while test $# -ne 0; do
    case "$1" in
        "--help"|"-h")
            usage
            exit 0
            ;;
	"--output"|"-o")
	    shift
	    outdir=$1
	    ;;
	"--cleanup")
	    cleanup=yes
	    ;;
	"--verbose")
	    verbose=yes
	    ;;
	"--demo")
	    # Already dealt with
	    ;;
        *)
            echo "unrecognized option $1"
            usage
            exit 1
            ;;
    esac
    shift
done

if [ "$cleanup" = "yes" ]; then
    rm -fr "$outdir"
    rm -f "$outphp"
fi

if [ -f "$outphp" ]; then
    die "$outphp already exists.
Remove it manually or use --cleanup."
fi

if [ "$outphp" = "" ]; then
    outphp=$outdir/php/inc/demo-questions.php
fi

mkdir -p "$outdir" || die "Cannot create directory $outdir"
mkdir -p "$(dirname "$outphp")" || die "Cannote create base directory for $outphp"

# make $outphp absolute
outphp=$(absolute_path "$outphp")
EXAM_DIR=$(absolute_path "$EXAM_DIR")

cd "$outdir"
# make outdir absolute.
outdir=$(pwd)

prepare_questions

echo '<?php' > "$outphp"
echo "defined('_VALID_INCLUDE') or die('Direct access not allowed.');

\$demo_questions = array();
\$demo_forms = array();
" >> "$outphp"

login=guest
question=1
session=1
machine=demo
studentdir="$outdir/php/subjects/$session/$machine"
mkdir -p "$studentdir"
cd "$studentdir"

# Redefine multiple-choice questions function not to do SQL
form_option () {
    form_text="${form_text}${form_sep}'$(php_escape "$1")' => '$(php_escape "$2")'"
    form_sep=', '
}

# Redefine basic_question not to do SQL ...
basic_question () {
    printf '$demo_questions[] = array("question_text" => "%s",
    "correct_answer" => "%s",
    "coeff" => %s);\n' \
	"$(php_escape "$2")" \
	"$(php_escape "$3")" \
	"$(php_escape "$1")" \
	>> "$outphp"
    if [ "$(command -v form_question_"$4")" = form_question_"$4" ]; then
	form_text='array('
	form_sep=''
	form_question_"$4"
	form_text="${form_text})"
    else
	form_text="null"
    fi
    
    printf '$demo_forms[] = %s;\n\n' "$form_text" >> "$outphp"
}

all_questions

echo '?>' >> "$outphp"

exam_install_php
exam_config_php demo > "$outdir"/php/inc/config.php

cd "$studentdir"/..
tar czf demo.tar.gz demo/
zip -r demo.zip demo/
mv demo.tar.gz demo.zip "$outdir"/php

echo "
Generated files:
- $outphp
- $outdir/php/inc/config.php
- $outdir/php/demo.tar.gz

Hopefully, the $output/php/ directory should be ready to be copied on
a webserver to start the demo."
