<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:tr="http://transpect.io"
  xmlns:svn="http://transpect.io/svn" 
  name="pipeline" 
  version="1.0">

  <p:option name="username" select="'user'"/>
  <p:option name="password" select="'pass'"/>

  <p:option name="repo"     select="'my-repo'"/>

  <p:option name="path" select="'MyFile.xml'"/>
  
  <p:option name="parents" select="'no'"/>
  
  <p:output port="result" sequence="true"/>

  <p:import href="svn-add-declaration.xpl"/>

  <svn:add name="svn-add">
    <p:with-option name="username" select="$username"/>
    <p:with-option name="password" select="$password"/>
    <p:with-option name="repo"     select="$repo"/>
    <p:with-option name="path"     select="$path"/>
    <p:with-option name="parents"  select="$parents"/>
  </svn:add>

</p:declare-step>
