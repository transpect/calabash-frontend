<?xml version="1.0"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:svn="http://transpect.io/svn" 
  version="1.0" 
  type="svn:add">

  <p:output port="result" sequence="true">
    <p:documentation>Adds one or more paths in a working copy like svn add.</p:documentation>
  </p:output>

  <p:option name="repo">
    <p:documentation>
    Path to a working copy e.g.
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
  <p:option name="path">
    <p:documentation>Whitespace-separated list of
    paths to be added.</p:documentation>
  </p:option>
  <p:option name="parents" select="'no'">
    <p:documentation>Whether to add unversioned parents in path.
    Permitted values are 'yes' and 'no' (default).</p:documentation>
  </p:option>

  
</p:declare-step>
