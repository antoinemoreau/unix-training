. "$EXAM_DIR"/exam-lib.sh
. "$EXAM_DIR"/exam-obfuscation-lib.sh

usage () {
            cat << EOF
Usage: $(basename $0) [options]
Options:
	--help		This help message.
	--output DIR, -o DIR
			Output directory
	--cleanup	Remove output directory
	--cleanup-db	Remove existing lines for this subject in database
	--apply		Apply generated SQL direcly
	--subject N	Subject number
	--verbose	Be verbose
	--postgresql	Use PostgreSQL syntax
	--mysql		Use MySQL syntax
	--list list.csv	Use list.csv as student list file
EOF
}

list_students=list_students.csv
outdir=exam_genere
outsql=
cleanup=no
clean_db=no
apply=no
# $exam_subject_number may be defined in the exam file.
subject=$exam_subject_number
basedir=$(pwd)
verbose=no
dbtype=${exam_dbtype:-mysql}

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
	"--cleanup-db")
	    cleanup_db=yes
	    ;;
	"--apply")
	    apply=yes
	    ;;
	"--subject")
	    shift
	    subject=$1
	    ;;
	"--verbose")
	    verbose=yes
	    ;;
	"--postgresql")
	    dbtype=postgresql
	    ;;
	"--mysql")
	    dbtype=mysql
	    ;;
	"--demo")
	    die "--demo must be the first option, sorry"
	    ;;
	"--list")
	    shift
	    list_students="$1"
	    ;;
        *)
            echo "ERROR: Unrecognized option $1"
            usage
            exit 1
            ;;
    esac
    shift
done

if [ "$outsql" = "" ]; then
    outsql=$outdir/questions.sql
fi

if [ "$subject" = "" ]; then
    die "Please specify subject number with --subject N."
fi

if [ "$cleanup" = "yes" ]; then
    rm -fr "$outdir"
    rm -f "$outsql"
fi

mkdir -p "$outdir" || die "Cannot create directory $outdir"
list_students=$(absolute_path "$list_students")
outsql=$(absolute_path "$outsql")
EXAM_DIR=$(absolute_path "$EXAM_DIR")

if [ -f "$outsql" ]; then
    die "$outsql already exists.
Remove it manually or use --cleanup."
fi

cd "$outdir" || die "Cannot enter directory $outdir"
# make outdir absolute.
outdir=$(pwd)

prepare_questions

case "$dbtype" in
    "postgresql")
	sql_raw "SET client_encoding = 'UTF8';"
	;;
    "mysql")
	sql_raw "SET NAMES 'UTF8';"
	;;
esac

if [ "$cleanup_db" = "yes" ]; then
    sql_raw "DELETE FROM exam_unix_subject_questions WHERE id_subject = '$subject';"
    sql_raw "DELETE FROM exam_unix_question WHERE id_subject = '$subject';"
    sql_raw "DELETE FROM exam_unix_logins   WHERE id_subject = '$subject';"
    sql_raw "DELETE FROM exam_unix_subject  WHERE id         = '$subject';"
fi
sql_raw "INSERT INTO exam_unix_subject(id, descriptif) VALUES ('$subject', '$(sql_escape "$exam_subject_title")');"

sql_newline

coefficients=()

for login in $(get_logins); do
    question=1
    session=$(get_session "$login")
    machine=$(get_machine "$login")
    first_name=$(get_first_name "$login" | sql_escape_pipe)
    familly_name=$(get_familly_name "$login" | sql_escape_pipe)
    echo "login = $login; session = $session; machine = $machine; first_name = $first_name; familly_name = $familly_name"
    studentdir="$outdir/$session/$machine"
    mkdir -p "$studentdir"
    cd "$studentdir"

    sql_comment "Etudiant $login"
    sql_raw "INSERT INTO exam_unix_logins (id_subject, session, machine, login, first_name, familly_name)
             VALUES ('$subject', '$session', '$machine', '$login', '$first_name', '$familly_name');"

    all_questions

    sql_newline
done

sql_comment "Coefficients of questions"

sum=0
for (( i = 1 ; i <= ${#coefficients[@]} ; i++ )); do
    sql_coef $i ${coefficients[$i]}
    sum=$((sum + ${coefficients[$i]}))
done

echo "Number of questions: ${#coefficients[@]}"
echo "Total coefficients: $sum"


if [ "$apply" = "yes" ]; then
    # needs a password.
    case "$dbtype" in
	"postgresql")
	    psql -h olan.imag.fr -d moy -U moywww -f "$outsql"
	    ;;
	"mysql")
	    mysql -h arpont.imag.fr -p --database=moy < "$outsql"
	    ;;
	*)
	    echo "Unknown database type $dbtype"
	    ;;
    esac
fi

(cd "$EXAM_DIR"; git ls-files php | tar cf - -T -) | \
    (cd "$outdir"; tar xf -)
exam_config_php sql > "$outdir"/php/inc/config.php


echo
echo "Generated files in $outdir"
echo "- $outsql"
echo "- 1/ and 2/ : files to put on students account for sessions 1 and 2"
echo "- php/ : PHP files to put on the server. php/inc/config.php is the configuration file."
