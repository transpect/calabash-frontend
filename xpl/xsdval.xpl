<?xml version="1.0" encoding="utf-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
  xmlns:tr="http://transpect.io" 
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  version="1.0"
  name="xsdval"
  type="tr:validate-with-xsd">

  <p:input port="source" primary="true" />
  <p:input port="schema" sequence="true"/>

  <p:output port="report" primary="true">
    <p:pipe step="validate" port="report" />
  </p:output>
  <p:serialization port="report" indent="true"/>

  <p:option name="use-location-hints" select="'true'">
    <p:documentation>Apparently does not work with Calabash 1.1.5 (“Array index out of range: 0”)</p:documentation>
  </p:option>
  
  <p:option name="fail-on-error" select="'true'">
    <p:documentation>Whether to throw an error when validation fails.</p:documentation>
  </p:option>

  <p:variable name="var-file-uri" select="base-uri()"/>

  <p:try name="validate">
    <p:group>
      <p:output port="report" primary="true"/>
  
      <p:validate-with-xml-schema>
<!--        <p:with-option name="use-location-hints" select="$use-location-hints"/>-->
        <p:input port="source">
          <p:pipe step="xsdval" port="source"/>
        </p:input>
        <p:input port="schema">
          <p:pipe step="xsdval" port="schema"/>
        </p:input>
      </p:validate-with-xml-schema>
      <p:sink/>

      <p:identity name="ok">
        <p:input port="source">
          <p:inline>
            <c:report>ok</c:report>
          </p:inline>
        </p:input>
      </p:identity>
    </p:group>

    <p:catch name="catch1">
      <p:output port="report" primary="true">
        <p:pipe step="fwd-errors" port="result"/>
      </p:output>

      <p:identity name="fwd-errors">
        <p:input port="source">
          <p:pipe step="catch1" port="error"/>
        </p:input>
      </p:identity>
      
      <p:choose>
        <p:when test="$fail-on-error = 'true'">
          <p:error code="tr:XSD1">
            <p:input port="source">
              <p:pipe step="catch1" port="error"/>
            </p:input>
          </p:error>
        </p:when>
        <p:otherwise>
          <p:identity/>
        </p:otherwise>
      </p:choose>
      <p:sink/>
    </p:catch>
  </p:try>

</p:declare-step>
