<?xml version="1.0"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc"
           xmlns:c="http://www.w3.org/ns/xproc-step"  
           xmlns:tr="http://transpect.io"
           xmlns:tr-internal="http://transpect.io/internal"
           xmlns:letex="http://www.le-tex.de/namespace"
           version="1.0">

  <p:documentation>This is just copied from the master declarations in their corresponding repositories.
  The letex: versions are here for compatibility reasons.</p:documentation>

  <p:declare-step type="tr-internal:unzip">
    <p:option name="zip" required="true"/>
    <p:option name="dest-dir" required="true"/>
    <p:option name="overwrite" required="false" select="'no'"/>
    <p:option name="file" required="false"/>
    <p:output port="result" primary="true"/>
  </p:declare-step>

  <p:declare-step type="tr:validate-with-rng">
    <p:input port="source" primary="true"/>	
    <p:input port="schema"/>	
    <p:output port="result" primary="true"/>
    <p:output port="report"/>
   </p:declare-step>
   
  <p:declare-step type="tr:image-identify">
    <p:input port="source" primary="true" sequence="true"/>
    <p:output port="result" primary="true" sequence="true"/>
    <p:output port="report" sequence="true"/>
    <p:option name="href"/>
  </p:declare-step>

  <p:declare-step type="letex:unzip">
    <p:option name="zip" required="true"/>
    <p:option name="dest-dir" required="true"/>
    <p:option name="overwrite" required="false" select="'no'"/>
    <p:option name="file" required="false"/>
    <p:output port="result" primary="true"/>
  </p:declare-step>

  <p:declare-step type="tr:epubcheck">
    <p:output port="result" primary="true" sequence="false"/>
    <p:option name="href"/>
  </p:declare-step>
  
  <p:declare-step type="letex:validate-with-rng">
    <p:input port="source" primary="true"/>	
    <p:input port="schema"/>	
    <p:output port="result" primary="true"/>
    <p:output port="report"/>
   </p:declare-step>
   
  <p:declare-step type="letex:image-identify">
    <p:input port="source" primary="true" sequence="true"/>
    <p:output port="result" primary="true" sequence="true"/>
    <p:output port="report" sequence="true"/>
    <p:option name="href"/>
  </p:declare-step>
    
</p:library>
