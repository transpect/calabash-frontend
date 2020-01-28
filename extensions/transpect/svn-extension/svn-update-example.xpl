<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:tr="http://transpect.io"
  xmlns:svn="http://transpect.io/svn" 
  name="pipeline" 
  version="1.0">

  <p:option name="username" select="'user'"/>
  <p:option name="password" select="'pass'"/>
  <p:option name="path"     select="'path'"/>
  <p:option name="revision" select="'HEAD'"/>

  <p:serialization port="result" indent="true"/>

  <p:output port="result" sequence="true"/>

  <p:import href="svn-update-declaration.xpl"/>

  <svn:update name="svn-update">
    <p:with-option name="username" select="$username"/>
    <p:with-option name="password" select="$password"/>
    <p:with-option name="path"     select="$path"/>
    <p:with-option name="revision" select="$revision"/>
  </svn:update>

</p:declare-step>
