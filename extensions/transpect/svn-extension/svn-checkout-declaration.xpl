<?xml version="1.0"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:svn="http://transpect.io/svn" 
  version="1.0" 
  type="svn:checkout">

  <p:output port="result" sequence="true">
    <p:documentation>Create a directory in a SVN repository</p:documentation>
  </p:output>
  
  <p:option name="username">
    <p:documentation>The username for authentification.</p:documentation>
  </p:option>
  <p:option name="password">
    <p:documentation>The password for authentification.</p:documentation>
  </p:option>
  <p:option name="repo">
    <p:documentation>URL to a SVN repository</p:documentation>
  </p:option>
  <p:option name="revision">
    <p:documentation>SVN revision number</p:documentation>
  </p:option>
  <p:option name="path">
    <p:documentation>Path where the SVN working copy is checked out.</p:documentation>
  </p:option>

  
</p:declare-step>
