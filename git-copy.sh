#! /bin/sh
# http://blog.neutrino.es/2012/git-copy-a-file-or-directory-from-another-repository-preserving-history/

if [ "$3" == "" ]; then
    echo "Usage: `basename $0` source_repo_dir target_repo_dir filename"
    echo "Example: cd source_repo && `basename $0` . ../target_repo dir/filename.c"
    exit
fi

source_repo="$1"
target_repo="$2"
filename="$3"

MERGEDIR="`mktemp -d /tmp/mergepatchs.XXXXXXXX`" || exit 1
curdir="`pwd`"

cd "$source_repo"
git format-patch -o $MERGEDIR $(git log $filename|grep ^commit|tail -1|awk '{print $2}')^..HEAD $filename
cd "$target_repo"
git am $MERGEDIR/*.patch
rm -rf $MERGEDIR

cd "$curdir"

