<?xml version="1.0"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:svn="http://transpect.io/svn" 
  version="1.0" 
  type="svn:update">

  <p:output port="result" sequence="true">
    <p:documentation>Performs a svn update on a whitespace-separated list of paths.</p:documentation>
  </p:output>
  
  <p:option name="username">
    <p:documentation>The username for authentification.</p:documentation>
  </p:option>
  <p:option name="password">
    <p:documentation>The password for authentification.</p:documentation>
  </p:option>
  <p:option name="path">
    <p:documentation>Whitespace-separated list of paths to be updated.</p:documentation>
  </p:option>
  <p:option name="revision" required="false">
    <p:documentation>SVN revision.</p:documentation>
  </p:option>
  
</p:declare-step>
