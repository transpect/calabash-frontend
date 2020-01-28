<?xml version="1.0"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:svn="http://transpect.io/svn" 
  version="1.0" 
  type="svn:mkdir">

  <p:output port="result" sequence="true">
    <p:documentation>Create a directory in a SVN repository</p:documentation>
  </p:output>

  <p:option name="repo">
    <p:documentation>
    Path to a working copy or URL to a repository, e.g.
    https://subversion.le-tex.de/common/mydir
    C:/cygwin64/home/Martin/transpect/mydir
    ../transpect/mydir
    </p:documentation>
  </p:option>
  <p:option name="username">
    <p:documentation>The username for authentification.</p:documentation>
  </p:option>
  <p:option name="password">
    <p:documentation>The password for authentification.</p:documentation>
  </p:option>
    <p:option name="dir">
      <p:documentation>Whitespace-separated list of
      directory paths to be created.</p:documentation>
  </p:option>
  <p:option name="parents" select="'no'">
    <p:documentation>Whether to create parent directories if necessary.
    Applicable values are 'yes' or 'no' (default).</p:documentation>
  </p:option>
  <p:option name="message" select="'svn:mkdir create dir'">
    <p:documentation>Provide a message for your commit. Please note that
    commits are just caried out for remote repositories. This behaviour
    corresponds to the default svn mkdir command.
    </p:documentation>
  </p:option>
  
</p:declare-step>
