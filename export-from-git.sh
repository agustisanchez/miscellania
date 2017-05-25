#!/bin/bash
# Exports from git into a temp directory
# and creates a ZIP archive.
set -e
trap clean EXIT
function clean {
   if [ -n "$TMPDIR" ]
   then
      rm -fR $TMPDIR
   fi
}
tag=$1
if [ -z "$tag" ]
then
        read -p "Tag: " tag
fi
TMPDIR=`mktemp -d`
nom=${PWD}/pam-portal-src-${tag}.zip
if [ -e "$nom" ]
then
        rm -v $nom
fi
git clone --depth 1 --branch $tag git@gitlab.com:<user>/<project>.git $TMPDIR
( cd $TMPDIR; zip -qr ${nom} . -x .\*  )
echo "${nom}"
