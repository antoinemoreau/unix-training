#! /bin/sh

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

exec > jeu-de-piste.sh

printf "%s\n\n" '#! /bin/sh'

cat rotlib-decode.sh
cat rotlib-encode.sh

printf "%s" '
echo "'

rot "Bonjour,

Cet email vous est envoye par le script jeu-de-piste.sh. Il fait
partie du TP 'Jeu de piste'.

L'etape suivante est une compilation de programme Ada. Un programme
Ada se trouve dans le fichier etape_b1.adb dans le repertoire
jeu-de-piste sur le compte de l'utilisateur moy.

Vous n'avez pas le droit d'utiliser la commande 'ls' dans ce
repertoire (vous pouvez essayer, mais ca ne marchera pas), mais vous
pouvez tout de meme recuperer le fichier en question (vous verrez plus
tard comment utiliser la commande chmod pour obtenir ce genre de
permissions).

Recuperez ce fichier chez vous, par exemple avec

  cp le-fichier-en-question ~

(~ veut dire 'mon repertoire personnel')

Puis revenez dans votre répertoire personnel et compilez le fichier
avec la commande

  gnatmake etape_b1

puis executez-le avec

  ./etape_b1

Le programme genere vous donnera les indications pour aller a l'etape
suivante."

echo '" | rotpipe | mail -s "Enonce etape B1" "$LOGNAME@$(hostname --long)"'

echo 'echo "Un message a ete envoye a $LOGNAME@$(hostname --long).
Consultez cette boite mail pour avoir les instructions pour l'"'"'etape suivante."'