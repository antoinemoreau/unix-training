#
# User API: smart_question, smart_question_dec, and sql_question
# Simplest way to define a question.
#
# $1 = short name for the question.
# $2 = number of points (coefficient).
#
# This will call:
#
# - desc_question_$1 to get the question (the question displayed
#   to the user will be the standard output of the function),
#
# - gen_question_$1 to generate required files. The expected answer is
#   passed as first argument of gen_question_$1 (it is computed as
#   $(hash "$1")).
smart_question () {
    if [ "$verbose" = "yes" ]; then
	echo "smart_question $@"
	time=time
    else
	time=""
    fi
    cd "$studentdir"
    eval $time gen_question_"$1" $(hash "$1")
    sql_question "$2" "$(desc_question_"$1")" $(hash "$1")
}

# Decimal variant of smart_question (used when the answer has to be
# decimal, and sufficiently small).
smart_question_dec () {
    if [ "$verbose" = "yes" ]; then
	echo "smart_question $@"
	time=time
    else
	time=""
    fi
    cd "$studentdir"
    eval $time gen_question_"$1" $(dechash "$1")
    sql_question "$2" "$(desc_question_"$1")" $(dechash "$1")
}

# Inserts a question in the database. This is a low-level function,
# you probably want to use smart_question and smart_question_dec
# instead.
#
# $1 = coefficient
# $2 = question
# $3 = expected answer
sql_question () {
    coefficients["$question"]="$1"
    printf "INSERT INTO exam_unix_question
       (id, id_subject, machine, session, question_text, correct_answer, student_answer)
VALUES ('%s',     '%s',    '%s',    '%s',          '%s',           '%s',           NULL);\n" \
       "$question" "$subject" "$machine" "$session" "$(sql_escape "$2")" "$(sql_escape "$3")" >> "$outsql"
    question=$((question + 1))
}

# End of user API.

if [ "$(command -v all_questions)" != all_questions ]; then
    echo "ERROR: function all_questions is not defined."
    echo "You should create an exam file defining this function and"
    echo "ending with:"
    echo
    echo "EXAM_DIR=where/gen-exam/is/"
    echo ". \"\$EXAM_DIR\"/exam-main.sh"
    echo
    exit 1
fi

if [ "$(command -v prepare_questions)" != prepare_questions ]; then
    prepare_questions () {
	echo "You did not define a function prepare_questions. Not preparing anything."
    }
fi

die () {
    echo "FATAL ERROR: $@"
    exit 1
}

absolute_path () {
    printf "%s/%s" "$(cd "$(dirname "$1")"; pwd)" "$(basename "$1")"
}

# CSV parsing functions.
get_logins () {
    cut -d \; -f 1 < "$list_students"
}

get_first_name () {
    grep "^$1;" "$list_students" | cut -d \; -f 2
}

get_familly_name () {
    grep "^$1;" "$list_students" | cut -d \; -f 3
}
    
get_session () {
    grep "^$1;" "$list_students" | cut -d \; -f 4
}

get_machine () {
    grep "^$1;" "$list_students" | cut -d \; -f 5
}

# hash "any string": makes a hash of $1, the student login, and
# some other arbitrary string.
hash () {
    echo "$login $1 exam unix 2010" | sha1sum | head -c 8
}

# array of arbitrary hashes. It's quicker to access an array than to
# actually compute the hash each time.
for i in $(seq 100); do
    hashes[$i]=$(hash $i)
done

dechash () {
    hash "$1" | tr '[a-f]' '[0-6]' | head -c 4
}

sql_escape_pipe () {
    sed -e "s/'/''/g" -e 's/\\/\\\\/g'
}

sql_escape () {
    printf "%s" "$1" | sql_escape_pipe
}

# Meant to be used in double quotes => does not escape '.
php_escape_pipe () {
    sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

php_escape () {
    printf "%s" "$1" | php_escape_pipe
}

sql_newline () {
    echo >> "$outsql"
}

sql_comment () {
    echo "$@" | sed 's/^/-- /' >> "$outsql"
}

sql_raw () {
    echo "$@" >> "$outsql"
}

# Inserts the coefficient associated to a question number in the
# database.
# 
# $1 = question number
# $2 = coefficient
sql_coef () {
    printf "INSERT INTO exam_unix_subject_questions
       (id_subject, id_question, coeff)
VALUES ('%s',       '%s',        '%s');\n" \
    "$subject" "$1" "$2" >> "$outsql"
}

exam_read_dbpass () {
    printf "%s" "Please, enter database password (to be inserted into config.php): " >&2
    stty -echo
    read passwd
    stty echo
    printf "%s" "$passwd"
    echo >&2
}

# Generate custom config.php file.
exam_config_php () {
    echo "<?php"
    echo "defined('_VALID_INCLUDE') or die('Direct access not allowed.');"
    if [ "$1" = "sql" ]; then
	echo "\$subject = $subject;"
	echo "\$session = 1; // To be changed manually between sessions"
	echo "\$dbname = '$exam_dbname';"
	echo "\$dbuser = '$exam_dbuser';"
	echo "\$dbhost = '$exam_dbhost';"
	echo "\$dbpass = '$(exam_read_dbpass)';"
	echo "\$dbtype = '$dbtype';"
    else
	echo "\$session = 'demo';"
    fi
echo "
\$mode = '$1'; // 'sql' or 'demo'

\$welcome_msg = \"$(exam_welcome | php_escape_pipe)\";
?>"
}
