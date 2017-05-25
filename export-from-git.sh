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
# tag local_name remote_name
if [ "$#" -ge "3" ]
then
    tag=$1
    local_name=$2
    remote_name=$3
else
    read -p "Tag: " tag
    read -p "Local name: " local_name
    read -p "Remote name: " remote_name
fi
TMPDIR=`mktemp -d`
base_name=${local_name}-src-${tag}
ZIPDIR=$TMPDIR/${base_name}
mkdir $ZIPDIR
zip_name=${PWD}/${base_name}.zip
if [ -e "${zip_name}" ]
then
        rm -v ${zip_name}
fi
git clone --depth 1 --branch $tag git@gitlab.com:sabart/${remote_name}.git $ZIPDIR
( cd $TMPDIR; zip -qr ${zip_name} . -x ${base_name}/.\*  )
echo "${zip_name}"
