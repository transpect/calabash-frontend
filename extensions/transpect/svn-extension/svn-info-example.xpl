<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:tr="http://transpect.io"
  xmlns:svn="http://transpect.io/svn" 
  name="pipeline" 
  version="1.0">

  <p:option name="username" select="'user'"/>
  <p:option name="password" select="'pass'"/>

  <p:option name="repo" select="'https://subversion.le-tex.de/common'"/>
  
  <p:output port="result" sequence="true"/>

  <p:import href="svn-info-declaration.xpl"/>

  <svn:info name="svn-info">
    <p:with-option name="username" select="$username"/>
    <p:with-option name="password" select="$password"/>
    <p:with-option name="repo"     select="$repo"/>
  </svn:info>

</p:declare-step>
