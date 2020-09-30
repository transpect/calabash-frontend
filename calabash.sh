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

if [ -z $JAVA_FILE_ENCODING ]; then
    JAVA_FILE_ENCODING=UTF8
fi

if [ -z $ENTITYEXPANSIONLIMIT ]; then
    # 2**31 - 1
    # Set to 0 if unlimited, JVM default is probably 64000.
    # Applies only to source documents with many character entity references.
    ENTITYEXPANSIONLIMIT=2147483647
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
if [ -z "$SAXON_PROCESSOR" ]; then
    SAXON_PROCESSOR=--saxon-processor=${SAXON_JAR:(-6):2}
fi
# If you want to use Saxon PE or EE, you'll have to specify SAXON_JAR in your localdefs.sh
# or as an environment variable. You also need to prepend the directory that contains
# saxon-license.lic to CLASSPATH.
# Alternatively, particularly if your project also requires a standalone saxon, you may include
# https://subversion.le-tex.de/common/saxon-pe96/ or another repo that contains Saxon EE as an external,
# mounted to $PROJECT_DIR/saxon/ (convention over configuration).
# Since this Saxon PE repo is public, the license file has to be supplied by different means.
# Supposing that $ADAPTATIONS_DIR/common/saxon/ stems from a privately hosted repo, it is added
# to CLASSPATH by default, expecting saxon-license.lic to reside there.
# If you need a Saxon configuration file, you can prepend, for ex.,
# SAXON_PROCESSOR="--saxon-configuration a9s/common/calabash/saxon-conf.xml"
# to the calabash/calabash.sh invocation.

# The class paths of the custom Calabash extension steps
IMAGEPROPS_EXT="$EXT_BASE/transpect/image-props-extension:$EXT_BASE/transpect/image-props-extension/lib/xmlgraphics-commons-1.5.jar:$EXT_BASE/transpect/image-props-extension/lib/commons-imaging-1.0-alpha2.jar:$EXT_BASE/transpect/image-props-extension/lib/metadata-extractor-2.14.0.jar:$EXT_BASE/transpect/image-props-extension/lib/xmpcore-6.0.6.jar"
IMAGETRANSFORM_EXT="$EXT_BASE/transpect/image-transform-extension:$EXT_BASE/transpect/image-transform-extension/lib/twelvemonkeys-common-image-3.2-SNAPSHOT.jar:$EXT_BASE/transpect/image-transform-extension/lib/twelvemonkeys-common-io-3.2-SNAPSHOT.jar:$EXT_BASE/transpect/image-transform-extension/lib/twelvemonkeys-common-lang-3.2-SNAPSHOT.jar:$EXT_BASE/transpect/image-transform-extension/lib/twelvemonkeys-imageio-core-3.2-SNAPSHOT.jar:$EXT_BASE/transpect/image-transform-extension/lib/twelvemonkeys-imageio-jpeg-3.2-SNAPSHOT.jar:$EXT_BASE/transpect/image-transform-extension/lib/twelvemonkeys-imageio-metadata-3.2-SNAPSHOT.jar"
JAVASCRIPT_EXT="$EXT_BASE/transpect/javascript-extension:$EXT_BASE/transpect/javascript-extension/lib/rhino-1.7.8.jar:$EXT_BASE/transpect/javascript-extension/lib/trireme.0.9.1.jar"
EPUBCHECK_EXT="$EXT_BASE/transpect/epubcheck-extension:$EXT_BASE/transpect/epubcheck-extension/lib"
RNGVALID_EXT="$EXT_BASE/transpect/rng-extension:$EXT_BASE/transpect/rng-extension/lib/jing.jar"
UNZIP_EXT="$EXT_BASE/transpect/unzip-extension"
MATHTYPE_EXT="$EXT_BASE/transpect/mathtype-extension:$EXT_BASE/transpect/mathtype-extension/lib/jruby-complete-9.1.8.0.jar:$EXT_BASE/transpect/mathtype-extension/ruby/bindata-2.3.5/lib:$EXT_BASE/transpect/mathtype-extension/ruby/mathtype-0.0.7.5/lib:$EXT_BASE/transpect/mathtype-extension/ruby/nokogiri-1.7.0.1-java/lib:$EXT_BASE/transpect/mathtype-extension/ruby/ruby-ole-1.2.12.1/lib"
SVN_EXT="$EXT_BASE/transpect/svn-extension:$EXT_BASE/transpect/svn-extension/lib/antlr-runtime-3.4.jar:$EXT_BASE/transpect/svn-extension/lib/jna-4.1.0.jar:$EXT_BASE/transpect/svn-extension/lib/jna-platform-4.1.0.jar:$EXT_BASE/transpect/svn-extension/lib/jsch.agentproxy.connector-factory-0.0.7.jar:$EXT_BASE/transpect/svn-extension/lib/jsch.agentproxy.core-0.0.7.jar:$EXT_BASE/transpect/svn-extension/lib/jsch.agentproxy.pageant-0.0.7.jar:$EXT_BASE/transpect/svn-extension/lib/jsch.agentproxy.sshagent-0.0.7.jar:$EXT_BASE/transpect/svn-extension/lib/jsch.agentproxy.svnkit-trilead-ssh2-0.0.7.jar:$EXT_BASE/transpect/svn-extension/lib/jsch.agentproxy.usocket-jna-0.0.7.jar:$EXT_BASE/transpect/svn-extension/lib/jsch.agentproxy.usocket-nc-0.0.7.jar:$EXT_BASE/transpect/svn-extension/lib/lz4-java-1.4.1.jar:$EXT_BASE/transpect/svn-extension/lib/sequence-library-1.0.4.jar:$EXT_BASE/transpect/svn-extension/lib/sqljet-1.1.12.jar:$EXT_BASE/transpect/svn-extension/lib/svnkit-1.10.1.jar:$EXT_BASE/transpect/svn-extension/lib/svnkit-cli-1.10.1.jar:$EXT_BASE/transpect/svn-extension/lib/svnkit-javahl16-1.10.1.jar:$EXT_BASE/transpect/svn-extension/lib/svnkit-javahl16-1.10.1-javadoc.jar:$EXT_BASE/transpect/svn-extension/lib/svnkit-javahl16-1.10.1-sources.jar:$EXT_BASE/transpect/svn-extension/lib/trilead-ssh2-1.0.0-build222.jar"
MAIL_EXT="$EXT_BASE/calabash/lib/xmlcalabash1-sendmail-1.1.4.jar:$EXT_BASE/calabash/lib/javax.mail.jar"
JAF="$DIR/lib/javax.activation.jar"

CLASSPATH="$ADAPTATIONS_DIR/common/saxon/:$SAXON_JAR:$DIR/saxon/:$RNGVALID_EXT:$DISTRO/xmlcalabash-1.2.1-99.jar:$DISTRO/lib/:$DISTRO/lib/xmlresolver-1.0.4.jar:$DISTRO/lib/commons-fileupload-1.3.3.jar:$DISTRO/lib/classindex-3.3.jar:$DISTRO/lib/htmlparser-1.4.jar:$PROJECT_DIR/a9s/common/calabash:$DISTRO/lib/org.restlet-2.2.2.jar:$MAIL_EXT:$DISTRO/lib/tagsoup-1.2.1.jar:$EPUBCHECK_EXT:$JAVASCRIPT_EXT:$IMAGEPROPS_EXT:$IMAGETRANSFORM_EXT:$UNZIP_EXT:$MATHTYPE_EXT:$SVN_EXT:$JAF:$CLASSPATH"

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
       echo "ENTITYEXPANSIONLIMIT: $ENTITYEXPANSIONLIMIT"
fi

$JAVA \
   -cp "$CLASSPATH" \
   -Dfile.encoding=$JAVA_FILE_ENCODING \
   "-Dxml.catalog.files=$CATALOGS" \
   -Djruby.compile.mode=OFF \
   -Dxml.catalog.staticCatalog=1 \
   -Djdk.xml.entityExpansionLimit=$ENTITYEXPANSIONLIMIT \
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

