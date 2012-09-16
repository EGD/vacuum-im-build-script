#!/bin/bash

SOURCE=$HOME/Документы/projects/Vacuum-IM
TARGET=$HOME/Документы/projects/Vacuum-IM/home\:EGDFree\:vacuum-im\:git/vacuum-im

SVNIDOld=$(svn info $SOURCE/vacuum-im | grep 'Last Changed Rev: ' | grep -P -o '\d+')

svn up $SOURCE/vacuum-im 

SVNID=$(svn info $SOURCE/vacuum-im | grep 'Last Changed Rev: ' | grep -P -o '\d+')

if [[ $SVNID -eq $SVNIDOld ]]
then
  echo 'Last version now.'
  exit 0
fi

sed -i "s/\(%define rbuild \)[[:digit:]]*/\1$SVNID/" $TARGET/vacuum-im.spec

CURRENT_UTILS_VERSION=$(grep '%define libname ' $TARGET/vacuum-im.spec | grep -P -o '\d+$')
NEW_UTILS_VERSION=$(grep 'set(VACUUM_UTILS_ABI ' $SOURCE/vacuum-im/src/make/config.cmake | grep -Po '\d+')

if [[ (-n $CURRENT_UTILS_VERSION) && (-n $NEW_UTILS_VERSION) && ("$CURRENT_UTILS_VERSION" != "$NEW_UTILS_VERSION") ]]
then
  sed -i "s;\(%define libname libvacuumutils\)[[:digit:]]\{1,\};\1$NEW_UTILS_VERSION;" $TARGET/vacuum-im.spec
fi

sed -i 's/\r$//' $SOURCE/vacuum-im/AUTHORS $SOURCE/vacuum-im/CHANGELOG $SOURCE/vacuum-im/COPYING $SOURCE/vacuum-im/README $SOURCE/vacuum-im/INSTALL $SOURCE/vacuum-im/TRANSLATORS

rm -f $TARGET/vacuum-im-r*.tar.bz2
tar --exclude=.svn --exclude=.qm --exclude=resources/emoticons/kolobok_* -C $SOURCE -cjf $TARGET/vacuum-im-r$SVNID.tar.bz2 vacuum-im/

osc ar $TARGET
osc commit -m "updated to revision $SVNID" $TARGET

echo 'Done.'
exit 0
