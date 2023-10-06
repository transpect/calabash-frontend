MAKEFILEDIR = $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

ifeq ($(shell uname -o),Cygwin)
win_path = $(shell cygpath -ma "$(1)")
uri = $(shell echo file:///$(call win_path,$(1))  | sed -r 's/ /%20/g')
else
win_path = $(shell readlink -m "$(1)")
uri = $(shell echo file:$(abspath $(1))  | sed -r 's/ /%20/g')
endif

# Override these variables by declaring them before you include this Makefile from your project’s Makefile.
JAVAC		?= javac
# Since this Makefile will be included, the . directory will be your transpect project directory:
TR_PROJ		?= .
BUILD_DIR	?= $(TR_PROJ)/build
# All non-jar files in these directories (relative to the parent directory, i.e., the transpect project dir)
# will be copied to the build directory. Overwrite in your Makefile.
DIRS            ?= calabash a9s cascade conf htmlreports schema schematron xmlcatalog xpl xproc-util xsl xslt-util
MAIN_CLASS	?= MyWrapper
WRAPPER_DIR	?= $(TR_PROJ)/JarWrapper
WRAPPER_TARGET_DIR ?=  $(TR_PROJ)/JarWrapper
# Assuming that it is in no package for the time being:
MAIN_CLASS_FILE	?= $(BUILD_DIR)/$(MAIN_CLASS).class
JAR_MANIFEST	?= $(WRAPPER_DIR)/src/Manifest.txt

# These variables pertain to contents of this calabash-frontend repo and should not need be overwritten in your project:
PATCHES_DIR	= $(MAKEFILEDIR)/patches/monolithic-jar-builder/java
PATCHED_CLASSES	= $(addprefix $(PATCHES_DIR)/,com/xmlcalabash/io/URLDataStore.class)
DISTRO		= $(MAKEFILEDIR)/distro
TR_EXT		= $(MAKEFILEDIR)/extensions/transpect
# We omit jing-2009111.jar from CALABASH_JARS since a patched jing.jar is contained in RNG_EXTENSION_JARS.
# This one is needed for parsing the command line options of the resulting monolithic Jar:
WRAPPER_JARS	= $(MAKEFILEDIR)/lib/commons-cli-1.4.jar
CALABASH_JARS	=  $(DISTRO)/lib/ant-1.9.4.jar \
 $(DISTRO)/lib/ant-launcher-1.9.4.jar \
 $(DISTRO)/lib/classindex-3.3.jar \
 $(DISTRO)/lib/commons-codec-1.9.jar \
 $(DISTRO)/lib/commons-fileupload-1.3.3.jar \
 $(DISTRO)/lib/commons-io-2.2.jar \
 $(DISTRO)/lib/commons-logging-1.2.jar \
 $(DISTRO)/lib/hamcrest-core-1.3.jar \
 $(DISTRO)/lib/htmlparser-1.4.jar \
 $(DISTRO)/lib/httpclient-4.5.2.jar \
 $(DISTRO)/lib/httpcore-4.4.5.jar \
 $(DISTRO)/lib/icu4j-49.1.jar \
 $(DISTRO)/lib/isorelax-20090621.jar \
 $(DISTRO)/lib/javax.servlet-api-3.1.0.jar \
 $(DISTRO)/lib/jcl-over-slf4j-1.7.10.jar \
 $(DISTRO)/lib/junit-4.12.jar \
 $(DISTRO)/lib/log4j-api-2.1.jar \
 $(DISTRO)/lib/log4j-core-2.1.jar \
 $(DISTRO)/lib/log4j-slf4j-impl-2.1.jar \
 $(DISTRO)/lib/msv-core-2013.6.1.jar \
 $(DISTRO)/lib/nwalsh-annotations-1.0.0.jar \
 $(DISTRO)/lib/org.restlet.ext.fileupload-2.2.2.jar \
 $(DISTRO)/lib/org.restlet.ext.slf4j-2.2.2.jar \
 $(DISTRO)/lib/org.restlet-2.2.2.jar \
 $(DISTRO)/lib/relaxngDatatype-20020414.jar \
 $(DISTRO)/lib/slf4j-api-1.7.10.jar \
 $(DISTRO)/lib/slf4j-simple-1.7.30.jar \
 $(DISTRO)/lib/tagsoup-1.2.1.jar \
 $(DISTRO)/lib/xmlresolver-0.14.0.jar \
 $(DISTRO)/lib/xsdlib-2013.6.1.jar \
 $(DISTRO)/xmlcalabash-1.3.2-100.jar
SAXON_JARS		= $(MAKEFILEDIR)/saxon/saxon9he.jar
RNG_EXTENSION_JARS	= $(TR_EXT)/rng-extension/jar/ValidateWithRelaxNG.jar \
 $(TR_EXT)/rng-extension/lib/jing.jar
UNZIP_EXTENSION_JARS	= $(TR_EXT)/unzip-extension/jar/UnZip.jar
# More extensions will go here...

IMAGEIDENTIFY_EXTENSION_JARS	= $(TR_EXT)/image-props-extension/jar/ImageIdentify.jar $(TR_EXT)/image-props-extension/lib/xmlgraphics-commons-1.5.jar $(TR_EXT)/image-props-extension/lib/xmpcore-6.0.6.jar $(TR_EXT)/image-props-extension/lib/metadata-extractor-2.14.0.jar $(TR_EXT)/image-props-extension/lib/commons-imaging-1.0-alpha2.jar $(TR_EXT)/image-props-extension/lib/junit-4.12.jar $(TR_EXT)/image-props-extension/lib/hamcrest-core-1.3.jar


#currently you need to use image-props-extension r7125 to run image-identify properly. use the IMAGEIDENITY_EXTENSION_JARS below or debug the on above with the current extension libs
#IMAGEIDENTIFY_EXTENSION_JARS	= $(TR_EXT)/image-props-extension/jar/ImageIdentify.jar $(TR_EXT)/image-props-extension/lib/xmlgraphics-commons-1.5.jar $(TR_EXT)/image-props-extension/lib/commons-imaging-1.0-SNAPSHOT.jar

# This variable may be configured again in the including Makefile:
JARS			?= $(WRAPPER_JARS) $(CALABASH_JARS) $(SAXON_JARS) $(RNG_EXTENSION_JARS) $(UNZIP_EXTENSION_JARS) $(IMAGEIDENTIFY_EXTENSION_JARS)

.PHONY: build_jar clean unzip_jars copy_dirs monolithic_jar_patches

usage_jarbuild:
	@echo "The purpose of this Makefile is to build a monolithic Jar of your transpect project."
	@echo "It is not meant to run your pipelines. A project-specific Makefile may be set up "
	@echo "in the containing directory (= transpect project directory) for running your pipelines."
	@echo "The main target is 'build_jar'."
	@echo "It doesn't clean up before by default; use the 'clean' target for removing intermediate artifacts."
	@echo "Include it from the transpect project's Makefile after the first target like this: "
	@echo "  include calabash/Makefile"
	@echo "Some customization (overwriting the JARS, DIRS, and MAIN_CLASS variables, for example) will be inevitable."
	@echo "You need to create a source file for the main class in the first place. There is no public example yet."

build_jar: $(BUILD_DIR) unzip_jars monolithic_jar_patches $(MAIN_CLASS_FILE) copy_dirs $(BUILD_DIR)/META-INF/catalog.xml
	echo "JARS:" $(JARS);\
	echo "DIRS" $(DIRS);\
	echo "TRPROJ:" $(TR_PROJ);\
	echo "BUILD_DIR:" $(BUILD_DIR);\
	echo "WRAPPER_DIR:" $(WRAPPER_DIR);\
	echo "JAR_MANIFEST:" $(JAR_MANIFEST);\
	echo "WRAPPER_TARGET_DIR:" $(WRAPPER_TARGET_DIR);\
	echo "MAIN_CLASS_FILE:" $(MAIN_CLASS_FILE);\
	jar cfm $(call win_path,$(WRAPPER_TARGET_DIR)/$(MAIN_CLASS).jar) $(call win_path,$(JAR_MANIFEST)) -C $(call win_path,$(BUILD_DIR)/) .

$(BUILD_DIR):
	-mkdir $@

$(BUILD_DIR)/META-INF/catalog.xml: $(MAKEFILEDIR)/xmlcatalog/catalog.forjar.xml
	-mkdir $(dir $@)
	cp $< $@

$(BUILD_DIR)/%.class: $(WRAPPER_DIR)/src/%.java
# Will be created in no package dir, i.e., immediately in the build directory
	$(JAVAC) -cp '$(call win_path,$(BUILD_DIR))' -Xlint:-options -source 1.7 $(call win_path,$<) -d '$(call win_path,$(BUILD_DIR))/' -target 1.7

monolithic_jar_patches: $(PATCHED_CLASSES)
	cd $(MAKEFILEDIR)/patches/monolithic-jar-builder/java && find . -name '*.class' -exec cp -u --parents {} $(abspath $(BUILD_DIR)) \;

%.class: %.java
	cd $(MAKEFILEDIR)/patches/monolithic-jar-builder/java && $(JAVAC) -cp '$(call win_path,$(BUILD_DIR))' -Xlint:-options -source 1.7 $(call win_path,$<) -target 1.7

unzip_jars: $(JARS)
	$(foreach jar,$(JARS),unzip -u -n $(jar) -x META-INF/MANIFEST.MF META-INF/INDEX.LIST META-INF/*.SF -d "$(BUILD_DIR)";)

copy_dirs:
	echo $(DIRS) | tr " " "\n" | tar c --exclude=.svn --exclude=.git --exclude='*.jar' -C "$(TR_PROJ)" -T - | tar x -C "$(BUILD_DIR)"

clean:
	-rm -r $(BUILD_DIR)/*
	find $(MAKEFILEDIR)/patches/monolithic-jar-builder/java -name '*.class' -exec rm {} \;

