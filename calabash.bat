
@REM The variable %~dp0 (the current script's directory) is not available
@REM in Windows versions prior to Windows 7. You need to set the scriptdir
@REM variable manually (with forward slashes and with a trailing slash), e.g.
@REM set scriptdir=C:/Users/joe/myproject/calabash/
@if not defined entityexpansionlimit (
@set entityexpansionlimit=2147483647
)
@if not defined heap (
@set heap=1024m
)
@set sd=%~dp0
@set scriptdir=%sd:\=/%
@set distro=%scriptdir%/distro/
@set extensions=%scriptdir%/extensions/
@set projectdir=%scriptdir%/../
@set adaptationsdir=%projectdir%a9s/
@set localdefs=%adaptationsdir%/common/calabash/localdefs.bat

@set javascriptext=%extensions%transpect/javascript-extension;%extensions%transpect/javascript-extension/lib/*
@set epubckeckext=%extensions%transpect/epubcheck-extension/;%extensions%transpect/epubcheck-extension/lib/*
@set imagepropsext=%extensions%transpect/image-props-extension;%extensions%transpect/image-props-extension/lib/*
@set imagetransformext=%extensions%transpect/image-transform-extension;%extensions%transpect/image-transform-extension/lib/*
@set rngvalidext=%extensions%transpect/rng-extension;%extensions%transpect/rng-extension/lib/*
@set unzipext=%extensions%transpect/unzip-extension
@set mathtypeext=%extensions%transpect/mathtype-extension;%extensions%transpect/mathtype-extension/lib/*;%extensions%transpect/mathtype-extension/ruby/bindata-2.3.5/lib;%extensions%transpect/mathtype-extension/ruby/mathtype-0.0.7.5/lib;%extensions%transpect/mathtype-extension/ruby/nokogiri-1.7.0.1-java/lib;%extensions%transpect/mathtype-extension/ruby/ruby-ole-1.2.12.1/lib
@set mailext=%extensions%calabash/lib/xmlcalabash1-sendmail-1.1.4.jar;%extensions%calabash/lib/javax.mail.jar
set svnext=%extensions%transpect/svn-extension
@set jaf=%scriptdir%/lib/javax.activation.jar
@set config=%scriptdir%extensions/transpect/transpect-config.xml

@set classpath=%adaptationsdir%common/saxon/;%projectdir%saxon/saxon9ee.jar;%projectdir%saxon/saxon9pe.jar;%projectdir%saxon/saxon9he.jar;%scriptdir%saxon/saxon9he.jar;%rngvalidext%;%distro%lib/;%distro%lib/xmlresolver-1.0.4.jar;%distro%lib/commons-fileupload-1.3.3.jar;%distro%lib/classindex-3.3.jar;%distro%lib/htmlparser-1.4.jar;%mailext%;%distro%xmlcalabash-1.2.1-99.jar;%extensions%transpect/;%javascriptext%;%epubckeckext%;%imagetransformext%;%imagepropsext%;%unzipext%;%mathtypeext%;%svnext%;%jaf%

@REM call localdefs batch file to overwrite default values for classpath 
@REM or xproc-config
@if exist {%localdefs%} {call %localdefs%}

@set CALABASH=java ^
   -cp %classpath% ^
   -Dfile.encoding=UTF8 ^
   -Dsun.jnu.encoding=UTF-8 ^
   -Dxml.catalog.files="file:///%scriptdir%xmlcatalog/catalog.xml" ^
   -Djdk.xml.entityExpansionLimit=%entityexpansionlimit% ^
   -Xmx%heap% -Xss1024k ^
   com.xmlcalabash.drivers.Main ^
   -E org.xmlresolver.Resolver ^
   -U org.xmlresolver.Resolver ^
   -c %config% 

%CALABASH% %*
