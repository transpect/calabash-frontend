# Sample pipelines

## xsdval.xpl

XSD validation that creates a `c:errors` or a `c:ok` document on the `report` port (which is primary).

## svrl2txt.xpl

Render SVRL and `c:errors` documents as plain text.

## xsd-sch-xsl.xpl

Validate the XML document on the `source` port against an XML Schema document on the `xsd` port, then validate the document 
against a Schematron document on the `sch` port, then transform the document using a stylesheet on the `xsl` port. Render the 
validation reports as text on a port `text-report`. The reports in XML format are available on the `report` port (wrapped in 
a `c:reports` element). There are defaults in the pipeline for the `xsl` and `sch` ports so you don’t have to specify anything
on these ports for testing.

Sample invocation (on Cygwin):

```
calabash/calabash.sh -o report=$(cygpath -ma /dev/null) \
                     -i xsd=file:/$(cygpath -ma ~/Dev/TEI-Simple/teisimple.xsd) \
                     -o result=$(cygpath -ma /dev/null) \
                     -i source=file:/$(cygpath -ma ~/Dev/TEI-Simple/teisimple.xml) \
                     calabash/xpl/xsd-sch-xsl.xpl
```

Sample output:

```

file:/C:/cygwin/home/gerrit/Dev/TEI-Simple/teisimple.xml
XSD Validation:
    
    line: 39
    column: 62
    message: cvc-complex-type.3.2.2: Attribute 'rend' is not allowed to appear in element 'hi'.
    
… … …

    line: 302
    column: 31
    message: cvc-complex-type.3.2.2: Attribute 'rend' is not allowed to appear in element 'hi'.


Schematron Validation:
  
    ID:         bogus-warning  
    test:       exists(*)
    location: /TEI
    message: There is a top-level element named 'TEI'.
```
