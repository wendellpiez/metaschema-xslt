<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:math="http://www.w3.org/2005/xpath-functions/math"
   xmlns:xvrl="http://www.xproc.org/ns/xvrl"
   xmlns:nm="http://csrc.nist.gov/ns/metaschema"
   exclude-result-prefixes="xs math"
   expand-text="true"
   version="3.0">
   
   <xsl:mode on-no-match="text-only-copy"/>
   
   <xsl:template match="/*">
         <xsl:apply-templates/>
         <xsl:text>&#xA;{ (1 to 12) ! ':::::' }</xsl:text>
   </xsl:template>
   
   <xsl:template match="REPORT/*">
      <xsl:text>&#xA;</xsl:text>
      <xsl:apply-templates/>
      <xsl:apply-templates select="@href"/>
   </xsl:template>
   
   <xsl:template match="@href">: { . }</xsl:template>
   
</xsl:stylesheet>