#!/bin/bash

# If you want to use Saxon PE features, a valid saxon-license.lic is expected to reside in
# $TRANSPECTDIR/a9s/common/saxon
# Remember not to store a license file in a publicly accessible repository!

cygwin=false;
case "`uname`" in
  CYGWIN*) cygwin=true;;
esac

# readlink -f is unavailable on Mac OS X
function real_dir() {
    SOURCE="$1"
    while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
	DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
	SOURCE="$(readlink "$SOURCE")"
	[[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
    done
    echo "$( cd -P "$( dirname "$SOURCE" )" && pwd  )"
}

SCRIPT=$(basename "${BASH_SOURCE[0]}" .sh)

SCRIPTDIR="$( real_dir "${BASH_SOURCE[0]}" )"

TRANSPECTDIR="$( real_dir "$SCRIPTDIR/../../.." )"

READER=org.xmlresolver.tools.ResolvingXMLReader

if [ -z $ENTITYEXPANSIONLIMIT ]; then
    # 2**31 - 1
    # Set to 0 if unlimited, JVM default is probably 64000.
    # Applies only to source documents with many character entity references.
    ENTITYEXPANSIONLIMIT=2147483647
fi

if [ -z $HEAP ]; then
    HEAP=4000m
fi

if [ -z $OPT ]; then
    OPT=9
fi

if [ -z $STRIP ]; then
    STRIP=ignorable
fi

CLASSPATH="$TRANSPECTDIR/calabash/saxon/saxon10pe.jar:$TRANSPECTDIR/calabash/distro/lib/xmlresolver-5.2.2.jar:$TRANSPECTDIR/calabash/distro/lib/xmlresolver-5.2.2-data.jar:$TRANSPECTDIR/a9s/common/saxon"

if $cygwin; then
  CLASSPATH=$(cygpath -map "$CLASSPATH")
  OSDIR=$(cygpath -ma "$TRANSPECTDIR")
  TRANSPECTDIR=file:/"$OSDIR"
fi

CATALOGS=$TRANSPECTDIR/xmlcatalog/catalog.xml

java \
    -cp "$CLASSPATH" \
   -Djdk.xml.entityExpansionLimit=$ENTITYEXPANSIONLIMIT \
   -Dxml.catalog.files="$CATALOGS" \
   -Dfile.encoding=UTF8 \
   -Xmx$HEAP  \
   com.saxonica.Transform \
   -r:org.xmlresolver.Resolver \
   -x:$READER \
   -y:$READER \
   -strip:$STRIP \
   -expand:off \
   -l \
   -u \
   -opt:$OPT \
   "$@"
