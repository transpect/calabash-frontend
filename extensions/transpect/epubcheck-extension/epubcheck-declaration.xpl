<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:tr="http://transpect.io"
  type="tr:epubcheck" 
  version="1.0">
  
  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    Checks EPUB files with IPDF epubcheck.
  </p:documentation>
  
  <p:output port="result" sequence="false">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      The output port provides a jhove XML report. Please see the code below for a sample:
      <pre><code>&lt;jhove xmlns="http://hul.harvard.edu/ois/xml/ns/jhove" date="2012-10-31" name="epubcheck" release="4.0.2">
 &lt;date>2017-01-23T14:57:52+01:00&lt;/date>
 &lt;repInfo uri="EmptyDir20.epub">
    &lt;format>application/octet-stream&lt;/format>
    &lt;status>Not well-formed&lt;/status>
    &lt;messages>
       &lt;message severity="error" subMessage="PKG-004">PKG-004, FATAL, [Corrupted EPUB ZIP header.], EmptyDir20.epub&lt;/message>
       &lt;message severity="error" subMessage="PKG-008">PKG-008, FATAL, [Unable to read file 'error in opening zip file'.], EmptyDir20.epub&lt;/message>
    &lt;/messages>
    &lt;properties>
       &lt;property>
          &lt;name>Info&lt;/name>
          &lt;values arity="List" type="Property"/>
       &lt;/property>
    &lt;/properties>
 &lt;/repInfo>
&lt;/jhove></code></pre>
    </p:documentation>
  </p:output>
  
  <p:option name="href" required="true">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      Submit the path to the file with the <code>href</code> option.
    </p:documentation>
  </p:option>
  
</p:declare-step>