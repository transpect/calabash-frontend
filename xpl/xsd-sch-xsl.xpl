<?xml version="1.0" encoding="utf-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
  xmlns:tr="http://transpect.io" 
  xmlns:xs = "http://www.w3.org/2001/XMLSchema"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  version="1.0"
  name="xsd-sch-xsl"
  type="tr:xsd-sch-xsl">

  <p:input port="source" primary="true"/>
  
  <p:input port="xsd"/>
  
  <p:input port="sch">
    <p:inline>
      <schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:tr="http://transpect.io" queryBinding="xslt2">
        <ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
        <pattern id="bogus-warning">
          <rule context="/">
            <report test="exists(*)" id="report-top-level-name" 
              role="warning">There is a top-level element named '<value-of select="*/name()"/>'.</report>
          </rule>
        </pattern>
      </schema>
    </p:inline>
  </p:input>
  
  <p:input port="xsl">
    <p:documentation>Identity transformation as default</p:documentation>
    <p:inline>
      <xsl:stylesheet version="2.0">
        <xsl:param name="fail-on-error" as="xs:boolean"/>
        <xsl:template match="node() | @*" mode="#default">
          <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="#current"/>
          </xsl:copy>
        </xsl:template>
        <xsl:template match="/" mode="#default">
          <xsl:message>fail-on-error: <xsl:value-of select="$fail-on-error"/></xsl:message>
          <xsl:next-match/>
        </xsl:template>
      </xsl:stylesheet>
    </p:inline>
  </p:input>

  <p:output port="result" primary="true">
    <p:pipe port="result" step="xslt"/>
  </p:output>

  <p:output port="report">
    <p:pipe step="consolidate-reports" port="result" />
    <p:documentation>A c:reports document consisting of either c:errors or c:ok (the output of the XSD validation)
    and the SVRL output of the Schematron validation</p:documentation>
  </p:output>
  <p:serialization port="report" indent="true"/>

  <p:output port="text-report">
    <p:pipe step="svrl2txt" port="result" />
  </p:output>
  <p:serialization port="text-report" method="text"/>

  <p:option name="fail-on-error" select="'false'">
    <p:documentation>Whether to throw an error when any of the validations fails.</p:documentation>
  </p:option>

  <p:import href="xsdval.xpl"/>
  <p:import href="svrl2txt.xpl"/>
  
  <tr:validate-with-xsd name="xsdval">
    <p:with-option name="fail-on-error" select="$fail-on-error"/>
    <p:input port="schema">
      <p:pipe port="xsd" step="xsd-sch-xsl"/>
    </p:input>
  </tr:validate-with-xsd>
  
  <p:sink name="sink1"/>
  
  <p:in-scope-names name="isn">
    <p:documentation>Make options and variables available as a c:param-set, see
    https://www.w3.org/TR/xproc-template/#c.in-scope-names</p:documentation>
  </p:in-scope-names>
  
  <p:validate-with-schematron name="schval">
    <p:with-option name="assert-valid" select="$fail-on-error"/>
    <p:input port="source">
      <p:pipe port="source" step="xsd-sch-xsl"/>
    </p:input>
    <p:input port="schema">
      <p:pipe port="sch" step="xsd-sch-xsl"/>
    </p:input>
    <p:with-param name="allow-foreign" select="'true'"/>
    <p:with-param name="full-path-notation" select="'2'">
      <p:documentation>See for ex.
        https://github.com/transpect/schematron/blob/master/dist/iso_schematron_skeleton_for_saxon.xsl#L82</p:documentation>
    </p:with-param>
  </p:validate-with-schematron>
  
  <p:xslt name="xslt">
    <p:input port="parameters">
      <p:pipe port="result" step="isn"/>
    </p:input>
    <p:input port="stylesheet">
      <p:pipe port="xsl" step="xsd-sch-xsl"/>
    </p:input>
  </p:xslt>
  
  <p:sink name="sink2"/>
  
  <p:wrap-sequence name="consolidate-reports" wrapper="c:reports">
    <p:input port="source">
      <p:pipe port="report" step="xsdval"/>
      <p:pipe port="report" step="schval"/>
    </p:input>
  </p:wrap-sequence>
  
  <tr:svrl2txt name="svrl2txt"/>
  
  <p:sink name="sink3">
    <p:documentation>The primary output is already connected to the primary output of the XSLT step.</p:documentation>
  </p:sink>

</p:declare-step>
