# The main machine is the one on which students usually work.
# Students must have access to a shared directory, to which
# we'll upload files corresponding to the steps of the hunt.
# One option is to have a big server with everybody logged-in on the
# same machine, and another is to have individual workstations with
# NFS-mounted directories (in this case, $mainmachine is the machine
# used for uploading files, and $main_user_home must be accessible
# through NFS by students)
mainmachine=${HUNT_MAINMACHINE:-pcserveur.ensimag.fr}

# Some of the steps are on the account of a particular user on
# $mainmachine, but not inside $maindir. This variable is the user's
# login ...
main_user=jdpunix
# ... and this one points to his $HOME directory.
main_user_home=/home/$main_user
# A variant of $main_user_home, to let the player get used to both
# notations
main_user_home_tilde="~${main_user}"

# Directory containing many steps of the hunt. You must have write
# access to it, and students must have read access (but won't be able
# to list the content of the directory).
maindir_base=jeu-de-piste
maindir=$main_user_home/$maindir_base
# A variant of $main_user_home, to let the player get used to both
# notations
maindir_tilde=$main_user_home_tilde/$maindir_base

# In my setup, the students access $main_user_home with a path
# different from the one I'm using to upload. If this is not your
# case, leave the default.
main_user_home_upload=$main_user_home
maindir_upload=$main_user_home_upload/$maindir_base

# Unix username used for uploading to servers (in my case, it's
# different from $main_user: I upload as myself, and the students
# access the files using ~jdpunix which is a dumb account, not allowed
# to log)
upload_user=$main_user

# Other machine (server) on which students have access. It will be
# used to practice various basic networking tools (SSH, sftp, ...).
# The first machine ($auxiliarymachine) should support 'ssh -X' (i.e.
# have xterm and xauth installed). Below are the machine name and the
# user on which this part will be installed:
auxiliarymachine=pcserveur.ensimag.fr
auxiliary_user=$main_user
auxiliary_user_upload=$auxiliary_user

# Yet another machine. This one is used only in text mode, nothing
# particular needed on the server.
auxiliary_machine2=depots.ensimag.fr
auxiliary_path2=/depots/2016/jeu-de-piste/
auxiliary_user_upload2=$auxiliary_user_upload

# The content of this directory should be uploaded to a website
web_base=jeu-de-piste
web=$HOME/WWW/$web_base

# Public URL of the website
web_url=http://www-verimag.imag.fr/~moy/$web_base

# Demo version of the exam, accessible to students (french and english
# versions).

# This is the name of the demo, used both in the URL of the generated
# demo, and as the name of the script to generate it. The generation
# script will be ../exam-expl/$demo_exam_name-$(gettext fr).sh.

# Version in use at Ensimag
demo_exam_name=demo-exam-ensimag2014
# Another Ensimag-free version
# demo_exam_name=simple-demo

# URL where the demo will be hosted (actually, they will be in
# "$demo_url/$demo_exam_name-$(gettext fr)/")
demo_url=$web_url

# One step sends an email to the user. The following variables
# configure how the email will be sent:
from_addr=Matthieu.Moy@imag.fr
smtp_server=ensiens.imag.fr
# and these two configure how the email will be prompted obtained from
# $LOGNAME and possibly by prompting the user. They are defined in
# mail-lib-runtime.sh (and generate-step-A5.sh for check_email_function_php).
get_email_function=get_email_ensimag
check_email_function=check_email_regex
check_email_function_php=check_email_regex_php
valid_email_regex='.@(imag.fr|.*grenoble-inp\.(fr|org)|inria.*\.fr|grenoble-em.com|univ-grenoble-alpes.fr)$'
# Example valid and invalid email addresses. Will be used to test the regexp.
valid_email_examples='Matthieu.Moy@grenoble-inp.fr
Foo@grenoble-inp.org Bar@grenoble-em.com boz@inria.fr
x@inrialpes.fr y@ensimag.grenoble-inp.fr z@imag.fr
Foo.Bar@univ-grenoble-alpes.fr'
invalid_email_examples='Foo.bar@gmail.com example@free.fr @imag.fr'
# When prompting the user for an email address, mention the school and
# the kind of email expected with these variables:
example_email=Prenom.Nom@grenoble-inp.org
school=Ensimag
# If machines have no way to send email themselves, you can use a PHP
# script to send emails. Set send_email_with_php to 'yes' if you want
# to enable this behavior.
send_email_with_php=yes
send_email_with_php_baseurl=$web_url

# URL of the monitoring system (see spy/README)
spy_url=http://www-verimag.imag.fr/~moy/monitoring-jdp

recompute () {
    auxiliary_user_upload2=$auxiliary_user_upload
    main_user_home_upload=$main_user_home
    maindir=$main_user_home/$maindir_base
    maindir_upload=$main_user_home_upload/$maindir_base
    auxiliary_user=$main_user
}

# I upload the game on multiple machines, with slightly different rules
case "$mainmachine" in
    ensiens|ensiens.imag.fr)
	: nothing
	;;
    129.88.240.211|ensipc*|ensipc*.imag.fr|pcserveur|pcserveur.ensimag.fr)
	# Not directly accessible, hence requires this in ~/.ssh/config:
	# Host ensipc*
	# ProxyCommand ssh -q ensiens.imag.fr nc %h 22
	main_user=jdpunix
	main_user_home=/matieres/3MMUNIX/
	upload_user=moy
	auxiliary_user_upload=moy
	recompute
	;;
    anie.imag.fr)
	main_user=moy
	main_user_home=/home/moy/
	example_email=First.Last@imag.fr
	school=Verimag
	smtp_server=""
	web_base=jeu-de-piste-verimag
	web=$HOME/WWW/$web_base
	web_url=http://www-verimag.imag.fr/~moy/$web_base
	demo_url=$web_url
	auxiliarymachine=anie.imag.fr
	get_email_function=get_email_verimag
	recompute
	;;
    *.imag.fr)
	maindir=$main_user_home/$maindir_base
	auxiliarymachine=$mainmachine
	;;
esac

variables="
mainmachine maindir auxiliarymachine web web_url
auxiliary_user
auxiliary_machine2 auxiliary_path2
demo_url demo_url_en spy_url
main_user_home main_user main_user_home_tilde maindir_tilde
upload_user
from_addr smtp_server get_email_function check_email_function
valid_email_regex check_email_function_php
send_email_with_php send_email_with_php_baseurl 
example_email school
"

# Useless Use Of Echo, in case the script is sourced from ZSH
for v in $(echo $variables)
do
    eval "export $v"
done
