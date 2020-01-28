<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:tr="http://transpect.io"
  xmlns:svn="http://transpect.io/svn" 
  name="pipeline" 
  version="1.0">

  <p:option name="username" select="'user'"/>
  <p:option name="password" select="'pass'"/>

  <p:option name="path"     select="'path-to-be-commited'"/>
  <p:option name="message" select="'my commit message'"/>
  
  <p:serialization port="result" indent="true"/>

  <p:output port="result" sequence="true"/>

  <p:import href="svn-commit-declaration.xpl"/>

  <svn:commit name="svn-commit">
    <p:with-option name="username" select="$username"/>
    <p:with-option name="password" select="$password"/>
    <p:with-option name="path"      select="$path"/>
    <p:with-option name="message"  select="$message"/>
  </svn:commit>

</p:declare-step>
