#! /bin/bash

set -x
set -e

. ./treasure-setup.sh
. ./i18n-lib.sh

generate_all () {
    ./generate-step-A2.sh
    ./generate-step-A5.sh
    
    ./generate-step-B1.sh

    ./generate-step-C1.sh
    ./generate-step-C3.sh

    ./generate-step-D1.sh
    ./generate-step-D2.sh
    ./generate-step-D3.sh

    ./generate-step-E10.sh
    ./generate-step-E11.sh
    ./generate-step-E13.sh

    rm -fr ./"$demo_exam_name"-$(gettext fr)/
    (cd ../exam-expl/ && ls && ./"$demo_exam_name"-$(gettext fr).sh)
    mv ../exam-expl/exam_genere/php/ ./"$demo_exam_name"-$(gettext fr)/
    maindir_tilde_sq=$(echo "$maindir_tilde" | sed 's@/@\\\/@g')
    perl -pi -e "s/\\@MAINDIR_TILDE\\@/$maindir_tilde_sq/" \
	./"$demo_exam_name"-$(gettext fr)/inc/$(gettext etape-suivante).php

    ./generate-step-E1.sh
    ./generate-step-E2.sh
    ./generate-step-E4.sh
    ./generate-step-E5.sh
# Must come after E4 and E5.
    ./generate-step-E3.sh
    ./generate-step-E6.sh
    ./generate-step-E9.sh

    ./generate-step-F2.sh

    ./generate-step-G2.sh
    ./generate-step-G3.sh

    ./generate-step-H2.sh
    ./generate-step-H5.sh
    ./generate-step-H8.sh
    ./generate-step-H9.sh
    ./generate-step-H10.sh
}

multilingual_do generate_all

(
    echo 'Hunt generated on:'
    date
    echo 'From Git version:'
    git log -1 --oneline
) > version.txt
