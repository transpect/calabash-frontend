
@REM The variable %~dp0 (the current script's directory) is not available
@REM in Windows versions prior to Windows 7. You need to set the scriptdir
@REM variable manually (with forward slashes and with a trailing slash), e.g.
@REM set scriptdir=C:/Users/joe/myproject/calabash/

@set heap=1024m
@set sd=%~dp0
@set scriptdir=%sd:\=/%
@set distro=%scriptdir%/distro/
@set extensions=%scriptdir%/extensions/
@set adaptionsdir=%scriptdir%/../a9s
@set localdefs=%adaptionsdir%/common/calabash/localdefs.bat

@set config=%scriptdir%extensions/transpect/transpect-config.xml

@echo %scriptdir%saxon/saxon9he.jar

@set classpath=%scriptdir%saxon/saxon9he.jar;%extensions%transpect/rng-extension/jing.jar;%distro%lib/;%distro%lib/xmlresolver-0.12.3.jar;%distro%lib/htmlparser-1.4.jar;%distro%xmlcalabash-1.1.14-96.jar;%extensions%transpect/unzip-extension;%extensions%transpect/rng-extension;%extensions%transpect/image-transform-extension;%extensions%transpect/image-transform-extension/*;%extensions%transpect/image-props-extension;%extensions%transpect/image-props-extension/commons-imaging-1.0-SNAPSHOT.jar;%extensions%transpect/image-props-extension/xmlgraphics-commons-1.5.jar

@REM call localdefs batch file to overwrite default values for classpath 
@REM or xproc-config
@if exist {%localdefs%} {call %localdefs%}


@java ^
   -cp %classpath% ^
   -Dfile.encoding=UTF8 ^
   -Dxml.catalog.files=file:///%scriptdir%xmlcatalog/catalog.xml ^
   -Dxml.catalog.catalog-class-name=org.apache.xml.resolver.Resolver ^
   -Xmx%heap% -Xss1024k ^
   com.xmlcalabash.drivers.Main ^
   -E org.xmlresolver.Resolver ^
   -U org.xmlresolver.Resolver ^
   -c %config% ^
   %*

