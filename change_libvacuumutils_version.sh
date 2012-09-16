#! /bin/bash

[[ $# -eq 0 ]] && exit 1

path=~/Документы/projects/Vacuum-IM/home\:EGDFree\:vacuum-im\:git/

for plugin in $(ls $path | grep vacuum-im-plugins)
do
  sed -i "s/libvacuumutils[[:digit:]]*/libvacuumutils$1/" $path/$plugin/$plugin.spec
  osc commit -m "change version libvacuumutils to $1" $path/$plugin
done

exit 0
