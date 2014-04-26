#! /bin/bash

[[ $# -eq 0 ]] && exit 1

VACUUM_DIR=~/Документы/projects/Vacuum-IM/home\:EGDFree\:vacuum-im\:git/

for plugin in $(ls $VACUUM_DIR | grep vacuum-im-plugins)
do
  sed -i "s/libvacuumutils[[:digit:]]*/libvacuumutils$1/" $VACUUM_DIR/$plugin/$plugin.spec
  osc commit -m "change version libvacuumutils to $1" $VACUUM_DIR/$plugin
done

exit 0
