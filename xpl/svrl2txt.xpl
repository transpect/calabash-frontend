<?xml version="1.0" encoding="utf-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
  xmlns:tr="http://transpect.io" 
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  version="1.0"
  name="svrl2txt"
  type="tr:svrl2txt">

  <p:input port="source" primary="true" >
    <p:documentation>A c:reports wrapper document consisting of either c:errors or c:ok elements (the output of XSD
      validations as performed by tr:xsdval) and the SVRL output of one or more Schematron validations</p:documentation>
  </p:input>

  <p:input port="rendering-xslt">
    <p:inline>
      <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:s="http://purl.oclc.org/dsdl/schematron"
                version="2.0">

        <!-- only important if used standalone, outside of XProc: -->
        <xsl:output encoding="UTF-8" method="text"/>

        <xsl:key name="by-id" match="*[@id]" use="@id"/>

        <xsl:template match="/">
          <bogo>
            <xsl:text>&#xa;</xsl:text>
            <xsl:variable name="svrl-items" as="element(*)*" select="//svrl:failed-assert | //svrl:successful-report"/>
            <xsl:variable name="c-error-items" as="element(*)*" select="//c:error"/>
            <xsl:choose>
            <xsl:when test="exists($svrl-items | $c-error-items)">
              <xsl:value-of select="distinct-values(//svrl:active-pattern/@document)"/>
              <xsl:text>
XSD Validation:</xsl:text>
              <xsl:apply-templates select="$c-error-items" mode="c-error"/>
              <xsl:text>


Schematron Validation:
</xsl:text>
              <xsl:for-each-group select="$svrl-items" group-by="preceding-sibling::svrl:active-pattern[1]/@id">
                <xsl:variable name="active-pattern" select="key('by-id', current-grouping-key())" 
                  as="element(svrl:active-pattern)"/>
                <xsl:text>  
    ID:         </xsl:text>
                <xsl:value-of select="$active-pattern/@id" />
                <xsl:if test="$active-pattern/@name ne $active-pattern/@id">
                  <xsl:text>  
    title:      </xsl:text>
                  <xsl:value-of select="$active-pattern/@name"/>
                </xsl:if>
                <xsl:text>  
    test:       </xsl:text>
                <xsl:value-of select="@test"/>
                <xsl:for-each select="current-group()">
                  <xsl:text>
    location: </xsl:text>
                  <xsl:value-of select="@location"/>
                  <xsl:text>
    message: </xsl:text>
                  <xsl:value-of select="svrl:text"/>
                </xsl:for-each>
              </xsl:for-each-group>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>OK: </xsl:text>
              <xsl:value-of select="distinct-values(//svrl:active-pattern/@document)"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text>&#xa;</xsl:text>
</bogo></xsl:template>
        
        <xsl:template match="c:error" mode="c-error">
          <xsl:text xml:space="preserve">
    </xsl:text>
          <xsl:apply-templates select="@*" mode="#current"/>
          <xsl:text xml:space="preserve">
    </xsl:text>
          <xsl:value-of select="'message: ', replace(., '^.+Number: \d+;\s+', '')" separator=""/>
        </xsl:template>
        
        <xsl:template match="@*" mode="c-error">
          <xsl:text xml:space="preserve">
    </xsl:text>
          <xsl:value-of select="name(), ': ', ." separator=""/>
        </xsl:template>

      </xsl:stylesheet>
    </p:inline>
  </p:input>

  <p:output port="result" primary="true"/>
  <p:serialization port="result" method="text"/>

  <p:xslt>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
    <p:input port="stylesheet">
      <p:pipe port="rendering-xslt" step="svrl2txt"/>
    </p:input>
  </p:xslt>

</p:declare-step>
