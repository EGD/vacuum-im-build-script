#!/bin/bash

SOURCE=$HOME/Документы/projects/Vacuum-IM
TARGET=$HOME/Документы/projects/Vacuum-IM/home\:EGDFree\:vacuum-im\:git/vacuum-im

SVN_ID_Old=$(svn info $SOURCE/vacuum-im | grep 'Last Changed Rev: ' | grep -P -o '\d+')

svn up $SOURCE/vacuum-im

SVN_ID=$(svn info $SOURCE/vacuum-im | grep 'Last Changed Rev: ' | grep -P -o '\d+')

if [[ $SVN_ID -eq $SVN_ID_Old ]]
then
  echo 'Last version now.'
  exit 0
fi

sed -i "s/\(%define rbuild \)[[:digit:]]*/\1$SVN_ID/" $TARGET/vacuum-im.spec

CURRENT_UTILS_VERSION=$(grep '%define libname ' $TARGET/vacuum-im.spec | grep -P -o '\d+$')
NEW_UTILS_VERSION=$(grep 'set(VACUUM_UTILS_ABI ' $SOURCE/vacuum-im/src/make/config.cmake | grep -Po '\d+')

if [[ "${CURRENT_UTILS_VERSION-0}" != "${NEW_UTILS_VERSION-0}" ]]
then
  sed -i "s;\(%define libname libvacuumutils\)[[:digit:]]\{1,\};\1$NEW_UTILS_VERSION;" $TARGET/vacuum-im.spec
fi

sed -i 's/\r$//' $SOURCE/vacuum-im/AUTHORS \
				 $SOURCE/vacuum-im/CHANGELOG \
				 $SOURCE/vacuum-im/COPYING \
				 $SOURCE/vacuum-im/README \
				 $SOURCE/vacuum-im/INSTALL \
				 $SOURCE/vacuum-im/TRANSLATORS

rm -f $TARGET/vacuum-im-r*.tar.xz
tar --exclude=.svn --exclude=.qm --exclude=*/resources/emoticons/kolobok_* \
    -cJf $TARGET/vacuum-im-r$SVN_ID.tar.xz \
    -C $SOURCE \
    vacuum-im/
svn revert $SOURCE/vacuum-im/AUTHORS \
	   $SOURCE/vacuum-im/CHANGELOG \
	   $SOURCE/vacuum-im/COPYING \
	   $SOURCE/vacuum-im/README \
	   $SOURCE/vacuum-im/INSTALL \
	   $SOURCE/vacuum-im/TRANSLATORS &

osc ar $TARGET
osc commit -m "Update to revision $SVN_ID." $TARGET

echo 'Done.'
exit 0
