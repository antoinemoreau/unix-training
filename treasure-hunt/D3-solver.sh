#!/bin/sh

# Not the expected solution, but allows us to test the step easily ;-).

if [ -f text_editor.adb ]; then
    echo "text_editor.adb already exists, aborting"
    exit 1
fi

if [ -f text_editor ]; then
    echo "text_editor already exists, aborting"
    exit 1
fi

cat > text_editor.adb
perl -pi -e 's/^--//; s/\[/\(/g; s/\]/\)/g' text_editor.adb
perl -pi -e 's/end if$/end if;/; s/Put\("";/Put\(""\);/; s/==/=/;' text_editor.adb
gnatmake text_editor.adb
echo
./text_editor
echo
rm -f text_editor.adb text_editor.ali text_editor.o text_editor
