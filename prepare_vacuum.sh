#!/bin/bash

SOURCE=$HOME/projects/Vacuum-IM
TARGET=$HOME/projects/Vacuum-IM/home\:EGDFree\:vacuum-im\:git/vacuum-im

GIT_DIR=$SOURCE/vacuum-im

git -C $GIT_DIR fetch --recurse-submodules=yes -q origin master

NO_NEED_WORK=$(git -C "$GIT_DIR" rev-list --count master...origin/master)

if [[ $NO_NEED_WORK -eq 0 ]]
then
  echo 'Last version now.'
  exit 0
fi

git -C $GIT_DIR checkout -q master
git -C $GIT_DIR pull -q origin master

GIT_TIME=$(git -C $GIT_DIR log -n 1 --format='%ct')
GIT_DATE=$(date -d "@$GIT_TIME" +%Y%m%d)
GIT_HASH=$(git -C $GIT_DIR log -n 1 --format='%h')

sed -i -r -e "/%define rdate / s/[^[:space:]]*$/$GIT_DATE/" \
	  -e "/%define rtime / s/[^[:space:]]*$/$GIT_TIME/" \
	  -e "/%define rhash / s/[^[:space:]]*$/$GIT_HASH/" \
	$TARGET/vacuum-im.spec

CURRENT_UTILS_VERSION=$(grep '%define libname ' $TARGET/vacuum-im.spec | grep -P -o '\d+$')
NEW_UTILS_VERSION=$(grep 'set(VACUUM_UTILS_ABI ' $SOURCE/vacuum-im/src/make/config.cmake | grep -Po '\d+')

if [[ "${CURRENT_UTILS_VERSION-0}" != "${NEW_UTILS_VERSION-0}" ]]
then
  sed -i -E "s/(%define libname libvacuumutils)[[:digit:]]*/\1$NEW_UTILS_VERSION/" $TARGET/vacuum-im.spec
fi

dos2unix -q -k $SOURCE/vacuum-im/AUTHORS \
	 $SOURCE/vacuum-im/CHANGELOG \
	 $SOURCE/vacuum-im/COPYING \
	 $SOURCE/vacuum-im/README \
	 $SOURCE/vacuum-im/INSTALL \
	 $SOURCE/vacuum-im/TRANSLATORS

rm -f $TARGET/vacuum-im-r*.tar.xz
tar --exclude-vcs --exclude='*.qm' --exclude='*/resources/emoticons/kolobok_*' \
    -cJf "$TARGET/vacuum-im-r$GIT_HASH.tar.xz" \
    -C $SOURCE \
    vacuum-im/
git -C $GIT_DIR checkout -- \
	     AUTHORS \
	     CHANGELOG \
	     COPYING \
	     README \
	     INSTALL \
	     TRANSLATORS &

osc ar $TARGET
osc commit -m "Update to revision $GIT_HASH." $TARGET

echo 'Done.'
exit 0
