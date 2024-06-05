<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   
   xmlns:mx="http://csrc.nist.gov/ns/csd/metaschema-xslt"
   xmlns:math="http://www.w3.org/2005/xpath-functions/math"
   exclude-result-prefixes="xs math mx"
   xmlns="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   version="3.0">
   
   <xsl:strip-space elements="*"/>
   
   <xsl:preserve-space elements="p h1 h2 h3 h4 h5 h6 pre li td
      a insert code em i b strong sub sup"/>
   
   <xsl:mode on-no-match="shallow-copy"/>
   
   <xsl:function name="mx:scrub-up" as="element()">
      <xsl:param name="in" as="node()"/>
      <xsl:apply-templates select="$in"/>
   </xsl:function>
   
</xsl:stylesheet>