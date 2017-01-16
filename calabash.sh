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
    if [ -e $PROJECT_DIR/saxon/saxon9ee.jar ]; then
	SAXON_JAR=$PROJECT_DIR/saxon/saxon9ee.jar
    elif [ -e $PROJECT_DIR/saxon/saxon9pe.jar ]; then
        SAXON_JAR=$PROJECT_DIR/saxon/saxon9pe.jar
    else
	SAXON_JAR=$DIR/saxon/saxon9he.jar
    fi
fi
SAXON_PROCESSOR=--saxon-processor=${SAXON_JAR:(-6):2}
# If you want to use Saxon PE or EE, you'll have to specify SAXON_JAR in your localdefs.sh
# or as an environment variable. You also need to prepend the directory that contains
# saxon-license.lic to CLASSPATH.
# Alternatively, particularly if your project also requires a standalone saxon, you may include
# https://subversion.le-tex.de/common/saxon-pe96/ or another repo that contains Saxon EE as an external,
# mounted to $PROJECT_DIR/saxon/ (convention over configuration).
# Since this Saxon PE repo is public, the license file has to be supplied by different means.
# Supposing that $ADAPTATIONS_DIR/common/saxon/ stems from a privately hosted repo, it is added
# to CLASSPATH by default, expecting saxon-license.lic to reside there.

EPUBCHECKEXT_JAR="$EXT_BASE/transpect/epubcheck-extension/lib/common-image-3.1.2.jar:$EXT_BASE/transpect/epubcheck-extension/lib/common-io-3.1.2.jar:$EXT_BASE/transpect/epubcheck-extension/lib/common-lang-3.1.2.jar:$EXT_BASE/transpect/epubcheck-extension/lib/commons-compress-1.5.jar:$EXT_BASE/transpect/epubcheck-extension/lib/epubcheck_saxon-9.6.0.7.jar:$EXT_BASE/transpect/epubcheck-extension/lib/guava-14.0.1.jar:$EXT_BASE/transpect/epubcheck-extension/lib/imageio-core-3.1.2.jar:$EXT_BASE/transpect/epubcheck-extension/lib/imageio-jpeg-3.1.2.jar:$EXT_BASE/transpect/epubcheck-extension/lib/imageio-metadata-3.1.2.jar:$EXT_BASE/transpect/epubcheck-extension/lib/jackson-core-asl-1.9.12.jar:$EXT_BASE/transpect/epubcheck-extension/lib/jackson-mapper-asl-1.9.12.jar:$EXT_BASE/transpect/epubcheck-extension/lib/jing-20120724.0.0.jar:$EXT_BASE/transpect/epubcheck-extension/lib/sac-1.3.jar:$EXT_BASE/transpect/epubcheck-extension"

CLASSPATH="$ADAPTATIONS_DIR/common/saxon/:$SAXON_JAR:$DIR/saxon/:$EXT_BASE/transpect/rng-extension/jing.jar:$DISTRO/xmlcalabash-1.1.14-96.jar:$DISTRO/lib/:$DISTRO/lib/xmlresolver-0.12.3.jar:$DISTRO/lib/htmlparser-1.4.jar:$PROJECT_DIR/a9s/common/calabash:$DISTRO/lib/org.restlet-2.2.2.jar:$EXT_BASE/transpect/rng-extension/:$EXT_BASE/transpect/unzip-extension/:$EXT_BASE/transpect/image-props-extension:$EXT_BASE/transpect/image-props-extension/commons-imaging-1.0-SNAPSHOT.jar:$EXT_BASE/transpect/image-props-extension/xmlgraphics-commons-1.5.jar:$DISTRO/lib/tagsoup-1.2.1.jar:$DISTRO/lib/xmlprojector-1.4.8.jar:$EPUBCHECKEXT_JAR:$CLASSPATH"

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
   com.xmlcalabash.drivers.$DRIVER \
   -Xtransparent-json \
   -E org.xmlresolver.Resolver \
   -U org.xmlresolver.Resolver \
   $SAXON_PROCESSOR \
   -c $CFG \
   $PIPERACK_PORT \
   "$@"
