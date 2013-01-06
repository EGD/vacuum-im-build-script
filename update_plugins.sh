#! /bin/bash

SOURCE=$HOME/Документы/projects/Vacuum-IM

for plugin_dir in $SOURCE/vacuum-im-plugins-*
do
  hg --cwd $plugin_dir incoming --insecure &>/dev/null
  
  if [[ "$?" -eq '0' ]]
  then
    plugin_name=$(basename "$plugin_dir")
    hg --cwd $plugin_dir pull --insecure -u &>/dev/null
    tar --exclude=.hg --exclude=.hg* --exclude=.qm -cjf $plugin_dir.tar.bz2 -C $SOURCE $plugin_name
    echo "updated: $plugin_name" 
  fi
done
