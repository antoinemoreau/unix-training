#! /bin/bash

. ./treasure-setup.sh
. ./spy-lib.sh
. i18n-lib.sh

alphabet="abcdefghijklmnopqrstuvwxyz"
alphabetdecale="zabcdefghijklmnopqrstuvwxy"

alphabet1="abcdefghijklm"
alphabet2="nopqrstuvwxyz"
ALPHABET1="ABCDEFGHIJKLM"
ALPHABET2="NOPQRSTUVWXYZ"

rotpipe () {
    tr "${alphabet1}${alphabet2}${ALPHABET1}${ALPHABET2}" \
	"${alphabet2}${alphabet1}${ALPHABET2}${ALPHABET1}"
}

rot () {
    echo "$1" | rotpipe
}

exec > $(gettext jeu-de-piste.sh)

printf "%s\n\n" '#! /bin/bash'
chmod +x $(gettext jeu-de-piste.sh)

cat rotlib-decode.sh
cat rotlib-encode.sh
. ./mail-lib.sh

monitor_step_cmd A5

echo "send_email_with_php_url=$send_email_with_php_baseurl/email-$(gettext fr).php"

email_ok_msg=$(gettext "Un message a ete envoye a %s.
Consultez cette boite mail pour avoir les instructions pour l'etape suivante.")
subject=$(gettext "Enonce etape B1")
body=$(gettext "Bonjour,

Cet email vous est envoyé par le script jeu-de-piste.sh. Il fait
partie du TP 'Jeu de piste'.

L'étape suivante est une compilation de programme Ada. Un programme
Ada se trouve dans le fichier etape_b1.adb dans le répertoire
jeu-de-piste sur le compte de l'utilisateur \${main_user}.

Si vous préférez le langage C, une version C se trouve dans le même
répertoire, dans le fichier etape_b1.c (à compiler avec la commande
gcc).

Vous n'avez pas le droit d'utiliser la commande 'ls' dans ce
répertoire (vous pouvez essayer, mais ça ne marchera pas), mais vous
pouvez tout de même récupérer le fichier en question (vous verrez plus
tard comment utiliser la commande chmod pour obtenir ce genre de
permissions).

Récupérez ce fichier chez vous, par exemple avec

  cp le-fichier-en-question ~

(~ veut dire 'mon répertoire personnel')

Puis revenez dans votre répertoire personnel et compilez le fichier
avec la commande

  gnatmake etape_b1

puis exécutez-le avec

  ./etape_b1

Le programme généré vous donnera les indications pour aller a l'étape
suivante.
" | envsubst)
token=92d62c27-2971-412e-9cc2-2741e406891a

# Has to come after assignments to $token and $email_ok_msg
mail_config

echo 'email=$(get_email "$LOGNAME")'

printf "%s" '
echo "'

printf '%s' "$body" | rotpipe

echo '" | rotpipe | send_mail "'"$subject"'" "$email"'

cat >email-$(gettext fr).php <<EOF
<?php

if (\$_GET['code'] != '$token') {
	die("Sorry, access denied\n");
}

header("Content-Type: text/plain; charset=utf-8");

\$to   = \$_GET['to'];

\$subject = "$subject";
\$body = "$body\n";

if (isset(\$_GET['HUNT_FORCE']) && \$_GET['HUNT_FORCE'] == 'yes') {
	echo(\$body);
	exit(0);
}

function check_email_regex_php(\$email) {
	return preg_match('/$valid_email_regex/', \$email);
}

// If needed, write other check_email_* function here and let
// $check_email_function_php point to it in treasure-setup.sh.

if (!$check_email_function_php(\$to)) {
	die(sprintf("Sorry, email '%s' is not in the allowed list.\n", \$to));
}

// Set Message-ID manually. Not used as of now.
//\$mid = sha1('$from_addr' . \$to . uniqid() . time()) . '@' . gethostname();
//\$mid = 'Message-ID: <' . \$mid . ">\r\n";

\$headers = 'From: $from_addr' . "\r\n" .
            'Content-type: text/plain; charset=utf-8' . "\r\n" .
            // send error message to $from_addr
            'Return-Path: $from_addr' . "\r\n";

// Setting Return-Path in headers does not always work. Adding -faddr
// can help.
\$args = '-f$from_addr';

mail(\$to, \$subject, \$body, \$headers, \$args);

printf("OK\n");
printf("$email_ok_msg", \$to);
?>
EOF
