<?xml version="1.0"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:svn="http://transpect.io/svn" 
  version="1.0" 
  type="svn:info">

  <p:output port="result" sequence="true">
    <p:documentation>Provides the results as c:param-set</p:documentation>
  </p:output>

  <p:option name="repo">
    <p:documentation> Path to a working copy or URL to a repository,
    applicable values are:
    https://subversion.le-tex.de/common/
    C:/home/Martin/transpect
    ../transpect
    </p:documentation>
  </p:option>
  <p:option name="username">
    <p:documentation>The username for authentification.</p:documentation>
  </p:option>
  <p:option name="password">
    <p:documentation> The password for authentification.</p:documentation>
  </p:option>

</p:declare-step>
