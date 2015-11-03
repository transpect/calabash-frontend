#!/bin/bash
cygwin=false;
case "`uname`" in
  CYGWIN*) cygwin=true;
esac

export JAVA=java

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

DIR="$( real_dir "${BASH_SOURCE[0]}" )"

EXT_BASE=$DIR/extensions

DISTRO="$DIR/distro"

if [ -z "$PROJECT_DIR" ]; then
  PROJECT_DIR=$( real_dir "$DIR" )
fi

# try the legacy name for adaptations first:
if [ -z "$ADAPTATIONS_DIR" ]; then
    ADAPTATIONS_DIR="$PROJECT_DIR/adaptions"
fi

# if it doesn't exist, set it to the current canonical name:
if [ ! -d $ADAPTATIONS_DIR ]; then
    ADAPTATIONS_DIR="$PROJECT_DIR/a9s"
fi
if [ -z $LOCALDEFS ]; then
    LOCALDEFS="$ADAPTATIONS_DIR/common/calabash/localdefs.sh"
fi

DRIVER=Main
SCRIPT=$(basename "${BASH_SOURCE[0]}" .sh)
if [ -z $PORT ]; then
    PORT=8089
fi
if [ -z $EXPIRES ]; then
    EXPIRES=86400
fi

if [ $SCRIPT == piperack ]; then
    DRIVER=Piperack
    PIPERACK_PORT="--piperack-port $PORT --piperack-default-expires=$EXPIRES"
fi

if [ -f "$LOCALDEFS" ]; then
  echo Using local Calabash settings file "$LOCALDEFS" >&2
  source "$LOCALDEFS"
fi

if [ -z $HEAP ]; then
    HEAP=1024m
fi

if [ -z $UI_LANG ]; then
    UI_LANG=en
fi

if [ -z $CFG ]; then
    CFG=$EXT_BASE/transpect/transpect-config.xml
fi

# SAXON_JAR is the path to a Saxon PE or EE jar file. Its name should match the following
# regex: /[ehp]e\.jar$/ so that we can extract the substring 'ee', 'he', or 'pe':
if [ -z $SAXON_JAR ]; then
    SAXON_JAR=$DIR/saxon/saxon9he.jar
fi
SAXON_PROCESSOR=--saxon-processor=${SAXON_JAR:(-6):2}

CLASSPATH="$SAXON_JAR:$DIR/saxon/:$EXT_BASE/transpect/rng-extension/jing.jar:$DISTRO/xmlcalabash-1.1.5-96.jar:$DISTRO/lib/:$DISTRO/lib/xmlresolver-0.12.3.jar:$DISTRO/lib/htmlparser-1.4.jar:$PROJECT_DIR/a9s/common/calabash:$DISTRO/lib/org.restlet.jar:$EXT_BASE/transpect/rng-extension/:$EXT_BASE/transpect/unzip-extension/:$EXT_BASE/transpect/image-props-extension:$EXT_BASE/transpect/image-props-extension/commons-imaging-1.0-SNAPSHOT.jar:$EXT_BASE/transpect/image-props-extension/xmlgraphics-commons-1.5.jar:$DISTRO/lib/tagsoup-1.2.1.jar:$CLASSPATH"

OSDIR=$DIR
if $cygwin; then
  CLASSPATH=$(cygpath -map "$CLASSPATH")
  EXT_BASE=$(cygpath -ma "$EXT_BASE")
  CFG=$(cygpath -ma "$CFG")
  PROJECT_DIR=file:/$(cygpath -ma "$PROJECT_DIR")
  OSDIR=$(cygpath -ma "$DIR")
  DIR=file:/"$OSDIR"
fi

# CATALOGS are always semicolon-separated, see 
# https://github.com/ndw/xmlresolver/blob/e1ea653ae8a98c8a46b7ad017ebd18ea1d2e8fac/src/org/xmlresolver/Configuration.java#L26
CATALOGS="$CATALOGS;$DIR/xmlcatalog/catalog.xml;$PROJECT_DIR/xmlcatalog/catalog.xml;$PROJECT_DIR/a9s/common/calabash/catalog.xml"
# In principle, $DIR/xmlcatalog/catalog.xml should be sufficient since it includes the $PROJECT_DIR catalogs via nextCatalog.
# If, however, this calabash dir is not a subdir of $PROJECT_DIR, then it makes sense to explicitly include them here.
# Please note that it is _essential_ that your project contains an xmlcatalog/catalog.xml that includes the catalogs
# of all transpect modules that you use.

# show variables for debugging
if [ "$DEBUG" == "yes" ]; then
       echo "CLASSPATH: $CLASSPATH"
       echo "SAXON_PROCESSOR: $SAXON_PROCESSOR"
       echo "XPROC-CONFIG: $CFG"
       echo "DIR: $DIR"
       echo "CATALOGS: $CATALOGS"
       echo "LOCALDEFS: $LOCALDEFS"
fi

$JAVA \
   -cp "$CLASSPATH" \
   -Dfile.encoding=UTF-8 \
   "-Dxml.catalog.files=$CATALOGS" \
   -Dxml.catalog.staticCatalog=1 \
   -Duser.language=$UI_LANG \
   $SYSPROPS \
   -Xmx$HEAP -Xss1024k \
   com.xmlcalabash.drivers.Main \
   -Xtransparent-json \
   -E org.xmlresolver.Resolver \
   -U org.xmlresolver.Resolver \
   $SAXON_PROCESSOR \
   -c $CFG \
   $PIPERACK_PORT \
   "$@"
