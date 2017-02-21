<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:tr="http://transpect.io"
  version="1.0">
  
  <p:output port="result"/>
  
  <p:option name="href" select="'test/EmptyDir20.epub'"/><!-- test/test.epub -->
  
  <p:import href="epubcheck-declaration.xpl"/>
  
  <tr:epubcheck>
    <p:with-option name="href" select="$href"/>
  </tr:epubcheck>
  
</p:declare-step>
