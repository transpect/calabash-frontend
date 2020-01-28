<?xml version="1.0"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:svn="http://transpect.io/svn" 
  version="1.0" 
  type="svn:commit">

  <p:output port="result" sequence="true">
    <p:documentation>Commits one or more paths in a SVN working copy
    to their respective SVN remote repository</p:documentation>
  </p:output>
  
  <p:option name="username">
    <p:documentation>The username for authentification.</p:documentation>
  </p:option>
  <p:option name="password">
    <p:documentation>The password for authentification.</p:documentation>
  </p:option>
  <p:option name="path">
    <p:documentation>Whitespace-separated list of paths to be commited.
    The paths must reside in a SVN working copy.</p:documentation>
  </p:option>
  <p:option name="message" select="'svn:commit'">
    <p:documentation>Provide a message for your commit.</p:documentation>
  </p:option>
  
</p:declare-step>
