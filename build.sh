#!/bin/bash

function usage {
    echo "XML Calabash/Saxon distribution build script"
    echo
    echo "Please set the XML Calabash and Saxon version as argument, e.g." 
    echo "$ ./build.sh 1.5.7-120 12.5"
    exit -1
}

CALABASH_VERSION=$1
SAXON_VERSION="${2//./-}"
CALABASH_RELEASE_URL=https://github.com/ndw/xmlcalabash1/releases/download
SAXON_HE_RELEASE_URL=https://github.com/Saxonica/Saxon-HE/releases/download
SAXON_PE_RELEASE_URL=https://downloads.saxonica.com/SaxonJ/PE/${2//.*/}
BUILD_DIR_NAME=build
CALABASH_TARGET=$BUILD_DIR_NAME/calabash-frontend
CALABASH_DISTRO_ZIP=$BUILD_DIR_NAME/tmp/xmlcalabash-$CALABASH_VERSION.zip
SAXON_HE_ZIP=$BUILD_DIR_NAME/tmp/SaxonHE${SAXON_VERSION}J.zip
SAXON_PE_ZIP=$BUILD_DIR_NAME/tmp/SaxonPE${SAXON_VERSION}J.zip
BRANCH_NAME=calabash-${CALABASH_VERSION}_saxon-${SAXON_VERSION}

if [ -z "$1"  ]; then
    usage
fi
if [ -z "$2"  ]; then
    usage
fi

umask 0002

echo "[info] create dirs and clone calabash-frontend"

rm -rf $BUILD_DIR_NAME

mkdir -p $BUILD_DIR_NAME/tmp

echo "[info] download XML Calabash $CALABASH_VERSION and Saxon $SAXON_VERSION"

wget -O $CALABASH_DISTRO_ZIP ${CALABASH_RELEASE_URL}/${CALABASH_VERSION}/xmlcalabash-${CALABASH_VERSION}.zip

wget -O $SAXON_HE_ZIP ${SAXON_HE_RELEASE_URL}/SaxonHE$SAXON_VERSION/SaxonHE${SAXON_VERSION}J.zip

wget -O $SAXON_PE_ZIP ${SAXON_PE_RELEASE_URL}/SaxonPE${SAXON_VERSION}J.zip

git clone --recursive git@github.com:transpect/calabash-frontend.git $CALABASH_TARGET

cd $CALABASH_TARGET && git config core.fileMode false && git config core.autocrlf true

cd ../../

echo "[info] update calabash to $CALABASH_VERSION"

cd $CALABASH_TARGET/distro

git checkout master && git pull

git rm -r xmlcalabash-*.jar xpl schemas lib

git checkout -b $BRANCH_NAME

cd ../../../

echo "[info] unzip new files"

unzip -j $CALABASH_DISTRO_ZIP xmlcalabash-$CALABASH_VERSION/xmlcalabash-$CALABASH_VERSION.jar -d $CALABASH_TARGET/distro/
for dir in xpl schemas lib; do \
    unzip -j $CALABASH_DISTRO_ZIP xmlcalabash-$CALABASH_VERSION/$dir/* -d $CALABASH_TARGET/distro/$dir
done
unzip -j $SAXON_HE_ZIP saxon-he-$2.jar -d $CALABASH_TARGET/saxon
unzip -j $SAXON_PE_ZIP saxon-pe-$2.jar -d $CALABASH_TARGET/saxon

# enter distro dir

cd $CALABASH_TARGET/distro && git add xmlcalabash-$CALABASH_VERSION.jar xpl schemas lib

echo "[info] commit new release $CALABASH_VERSION"
echo

git status

read -p "[PROMPT] Commit and push the new distribution (or proceed with nothing to commit)? [y/n]. If asked for password, please enter your GitHub personal access token (https://github.com/settings/tokens)" -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]
then
    git commit -m "[info] update to version $CALABASH_VERSION"
    git push -u origin $BRANCH_NAME
else
    echo "[ERROR] commit aborted. Please check the working copy in $CALABASH_TARGET/distro"
    exit 1
fi

# enter calabash-frontend

cd ../

git checkout -b $BRANCH_NAME

git add distro

git add saxon

git status

read -p "[PROMPT] Commit and push the new frontend (or proceed with nothing to commit)? [y/n]." -n 1 -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
    ls -l
    git commit -m "update calabash to $CALABASH_VERSION / saxon to $SAXON_VERSION"
    git push -u origin $BRANCH_NAME
else
    echo "[ERROR] commit aborted. Please check the working copy in $CALABASH_TARGET"
    exit 1
fi


