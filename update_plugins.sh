#! /bin/bash

for plugin in $(ls | grep vacuum-im-plugins-)
do
  hg --cwd $plugin incoming --insecure &>/dev/null
  
  if [[ "$?" -eq '0' ]]
  then
    hg --cwd $plugin pull --insecure -u &>/dev/null
    tar --exclude=.hg --exclude=.hg* --exclude=.qm -cjf $plugin.tar.bz2 $plugin
    echo "updated: $plugin"
  fi
done
