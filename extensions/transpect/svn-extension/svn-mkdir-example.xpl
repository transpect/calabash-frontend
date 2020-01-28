<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:tr="http://transpect.io"
  xmlns:svn="http://transpect.io/svn" 
  name="pipeline" 
  version="1.0">

  <p:option name="username" select="'user'"/>
  <p:option name="password" select="'pass'"/>
  <p:option name="repo"     select="'https://subversion.le-tex.de/common/sandbox'"/>
  <p:option name="dir" select="'mydir-created-with-xproc'"/>
  <p:option name="parents" select="'yes'"/>
  <p:option name="message" select="'my commit message'"/>
  
  <p:output port="result" sequence="true"/>

  <p:import href="svn-mkdir-declaration.xpl"/>

  <svn:mkdir name="svn-mkdir">
    <p:with-option name="username" select="$username"/>
    <p:with-option name="password" select="$password"/>
    <p:with-option name="repo"     select="$repo"/>
    <p:with-option name="dir"      select="$dir"/>    
    <p:with-option name="parents"  select="$parents"/>
    <p:with-option name="message"  select="$message"/>
  </svn:mkdir>

</p:declare-step>
