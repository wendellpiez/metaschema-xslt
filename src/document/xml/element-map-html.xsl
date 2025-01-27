<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.w3.org/1999/xhtml" version="3.0"
   xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   exclude-result-prefixes="#all">

   <xsl:import href="../../common/datatypes.xsl"/>

   <xsl:output indent="yes"/>
   <xsl:variable as="xs:string" name="model-label" select="string(/map/@prefix)"/>

   <xsl:param as="xs:string" name="outline-page"   select="'xml/outline'"/>
   <xsl:param as="xs:string" name="reference-page" select="'xml/reference'"/>
   
   <!-- writes '../' times the number of steps in $outline-page  -->
   <xsl:variable name="path-to-common">
      <xsl:for-each select="tokenize($outline-page,'/')">../</xsl:for-each>
   </xsl:variable>
   <xsl:variable name="reference-link" select="$path-to-common || $reference-page"/>
      
<!--http://localhost:1313/OSCAL/documentation/schema/catalog-layer/catalog/xml-model-map/
http://localhost:1313/OSCAL/documentation/schema/catalog-layer/catalog/xml-schema/-->

   <xsl:output omit-xml-declaration="true"/>

   <xsl:template match="/" mode="make-page">
      <html lang="en">
         <head>
            <xsl:call-template name="css"/>
         </head>
         <body>
            <xsl:call-template name="make-map"/>
         </body>
      </html>
   </xsl:template>
   
   <xsl:template match="/" name="make-map">
      <!--<xsl:call-template name="legend"/>-->
      <div class="xml-outline">
         <div class="model-container">
            <xsl:apply-templates select="/*"/>
         </div>
      </div>
   </xsl:template>
   
   <!-- XXX needs work! start by pasting in HTML results... -->
   <xsl:template name="legend"/>
   
   
   <xsl:template name="css">
      <style type="text/css">
body, html {  font-family: monospace; font-weight: bold } 

div.OM-map { margin-top: 1ex; margin-bottom: 0ex; margin-left: 2em }

div.OM-choice, div.OM-map { border-left: thin solid darkgrey; margin-top: 1ex; margin-bottom: 0ex; margin-left: 0ex; padding-left: 1em  }
         
.OM-entry { margin: 0.5ex }

div.OM-map p { margin: 0ex }

.OM-lit, .OM-cardinality, .OM-datatype { font-family: sans-serif; font-size: 80%; font-weight: normal }

.OM-datatype { font-style: italic; font-size: 70% }

.OM-cardinality  { font-size: 80% }

.OM-map a { color: inherit; text-decoration: none }

.OM-map a:hover { text-decoration: underline }

            </style>
   </xsl:template>

   <xsl:template match="m:metadata"/>
   
   <xsl:template match="m:formal-name | m:description | m:remarks | m:constraint"/>
   
   <xsl:template match="m:formal-name | m:description | m:remarks | m:constraint" mode="contents"/>
   
   
   <xsl:template match="*[exists(@_tree-xml-id)]" mode="linked-name">
      <a class="OM-name{ if (@deprecated) then ' OM-name-deprecated' else ''}" href="{ $reference-link }#{ @_tree-xml-id }">
         <xsl:value-of select="(@gi,@name)[1]"/>
      </a>
   </xsl:template> 
   
   <xsl:template match="*" mode="linked-name">
      <xsl:value-of select="(@gi,@name)[1]"/>
   </xsl:template> 
   
   <xsl:template priority="2" mode="linked-datatype" match="*" expand-text="true">
      <xsl:variable name="type" select="(@as-type,'string')[1]"/>
      <span class="OM-datatype">
         <xsl:sequence select="m:datatype-create-link($type)"/>
      </span>
   </xsl:template>
   
   <xsl:template match="m:element">
      <details class="OM-entry">
         <xsl:for-each select="parent::m:map">
            <xsl:attribute name="open">open</xsl:attribute>
         </xsl:for-each>
         <summary>
            <!--<div class="OM-flex">-->
               <xsl:call-template name="summary-line-content"/>
            <!--</div>-->
         </summary>
         <xsl:apply-templates select="." mode="contents"/>
         <xsl:if test="exists(m:element | m:value)">
            <p class="close-tag nobr">
               <xsl:text>&lt;/</xsl:text>
               <xsl:value-of select="(@gi,@name)[1]"/>
               <xsl:text>></xsl:text>
            </p>
         </xsl:if>
      </details>
   </xsl:template>

   <xsl:template match="m:element[(@recursive='true') or empty(* except (m:attribute|m:value))]">
      <div class="OM-entry">
         <p class="OM-line">
            <xsl:call-template name="summary-line-content"/>
         </p>
      </div>
   </xsl:template>
   
   <xsl:template name="summary-line-content">
      <xsl:variable name="recurses" select="@recursive = 'true'"/>
      <span class="sq">
         <span class="nobr">
            <xsl:text>&lt;</xsl:text>
            <xsl:apply-templates select="." mode="linked-name"/>
         </span>
         <xsl:apply-templates select="m:attribute" mode="as-attribute"/>
         <xsl:if test="empty(m:element | m:value) and not($recurses)">/</xsl:if>
         <xsl:text>&gt;</xsl:text>
         <xsl:if test="exists(m:element | m:value) or $recurses">
            <span class="show-closed">
               <xsl:apply-templates select="." mode="summary-contents"/>
               <span class="nobr">
                  <xsl:text>&lt;/</xsl:text>
                  <xsl:value-of select="(@gi, @name)[1]"/>
                  <xsl:text>></xsl:text>
               </span>
            </span>
         </xsl:if>
      </span>
      <span class="sq cardinality">
         <xsl:call-template name="cardinality-note"/>
      </span>
   </xsl:template>
 

   <xsl:template match="m:attribute" mode="as-attribute">
      <xsl:text> </xsl:text>
      <span class="nobr" id="{@_tree-xml-id}">
         <xsl:apply-templates select="." mode="linked-name"/>
         <xsl:text>="</xsl:text>
         <xsl:apply-templates select="." mode="linked-datatype"/>
         <xsl:text>"</xsl:text>
      </span>
   </xsl:template>
   
   <xsl:template priority="5" match="m:attribute"/>
   
   <xsl:template priority="5" mode="contents" match="m:element[exists(descendant::m:element)]" expand-text="true">
      <div class="model-container">
         <!--<xsl:for-each select="@formal-name">
            <p class="OM-map-name">
               <xsl:apply-templates select="."/>
            </p>
         </xsl:for-each>-->
         <xsl:apply-templates/>
      </div>
   </xsl:template>
   
   <xsl:template match="@formal-name" expand-text="true">
      <span class="frmname">{ . }</span>
   </xsl:template>
   
   <xsl:template mode="contents" match="m:element[empty(.//m:element) and empty(m:value)]" expand-text="true">
      <p class="OM-map-name">
         <!--<xsl:apply-templates select="@formal-name"/>-->
         <xsl:text>[Empty]</xsl:text>
      </p>
     <!-- <p>&lt;/{ (@gi,@name)[1] }></p>-->
   </xsl:template>
   
   <xsl:template match="*" mode="datatype-link">
      <xsl:variable name="type" select="(@as-type,'string')[1]"/>
      <xsl:text expand-text="true">{ if (matches($type,'^(a|e|i|o|A|E|I|O|NC)')) then 'an ' else 'a '}</xsl:text>
      <xsl:apply-templates select="." mode="linked-datatype"/>
      <xsl:text> value</xsl:text>
   </xsl:template>
   
   <xsl:template match="*[@as-type='markup-multiline']" mode="datatype-link">
      <xsl:text>One or more blocks of text: </xsl:text>
      <xsl:next-match/>
   </xsl:template>
   
   <xsl:template mode="contents" match="m:element[exists(m:value)]" expand-text="true">
      <p class="OM-map-name">
         <!--<xsl:apply-templates select="@formal-name"/>-->
         <!--<xsl:text> element with a value of type </xsl:text>-->
         <xsl:apply-templates select="m:value" mode="datatype-link"/>
      </p>
      <xsl:apply-templates mode="#current"/>
   </xsl:template>
   
   <xsl:template match="m:choice">
      <div class="OM-choices">
         <p class="OM-lit">
            <xsl:text>A choice of:</xsl:text>
         </p>
         <xsl:apply-templates/>
      </div>
   </xsl:template>
   
   <xsl:template match="m:choice/*" priority="5">
      <div class="OM-choice">
         <xsl:next-match/>
      </div>
   </xsl:template>
   
   <xsl:template priority="3" mode="contents" match="m:value">
      <xsl:apply-templates select="m:value" mode="linked-datatype"/>
   </xsl:template>
   
   <xsl:template priority="3" mode="contents" match="m:attribute">
      <xsl:apply-templates select="m:value" mode="linked-datatype"/>
   </xsl:template>
   
   <xsl:template priority="4" mode="contents" match="m:value[@as-type='markup-line']">
      <div class="OM-entry">
         <p class="OM-line OM-lit OM-gloss"> Text and inline markup including <code>&lt;insert></code> <code>&lt;em></code>, <code>&lt;strong></code>, <code>&lt;code></code>. </p>
      </div>
   </xsl:template>
   
   <xsl:template priority="4" mode="contents #default" match="m:value[@as-type='markup-multiline']">
      <div class="OM-entry">
         <p class="OM-line">&lt;p> <span class="OM-lit OM-gloss"><!-- — -->or other elements defined as <xsl:apply-templates select="." mode="linked-datatype"/></span> <xsl:call-template name="cardinality-note"/></p>
            <!--: block-level markup including <span class="OM-name">&lt;p></span>, <span class="OM-name">&lt;ul></span>, <span class="OM-name">&lt;ol></span>, headers (<span class="OM-name">&lt;h1></span>-<span class="OM-name">&lt;h6></span>) and <span class="OM-name">&lt;table></span>. -->
      </div>
   </xsl:template>
   
   <xsl:template mode="summary-contents" match="m:element[empty(m:element) and exists(m:value)]" expand-text="true">
      <xsl:apply-templates select="m:value" mode="linked-datatype"/>
   </xsl:template>
   
   <!-- XXX -->
   <xsl:template mode="summary-contents" match="m:element[empty(.//m:element) and empty(m:value)]"/>
   
   <xsl:template mode="summary-contents" match="m:element">
      <xsl:text> &#8230; </xsl:text>
   </xsl:template>
   
   <xsl:template mode="summary-contents" match="m:element[@_key-name=parent::element/@_key-name]" priority="11" expand-text="true">
      <span class="OM-lit OM-gloss"> (recursive: model like parent <span class="OM-ref">{ @gi }</span>) </span>
   </xsl:template>
   
   <xsl:template mode="summary-contents" match="m:element[@_key-name=ancestor::*/@_key-name]" priority="10" expand-text="true">
      <span class="OM-lit OM-gloss"> (recursive: model like ancestor <span class="OM-ref">{ @gi }</span>) </span>
   </xsl:template>

   <xsl:template name="cardinality-note">
      <xsl:text> </xsl:text>
      <span class="OM-cardinality">
         <xsl:apply-templates select="." mode="occurrence-code"/>
      </span>
   </xsl:template>

   <xsl:template mode="occurrence-code" match="*">
      <xsl:param name="on" select="." tunnel="true"/>
      <xsl:variable name="minOccurs" select="($on/@min-occurs,'0')[1]"/>
      <xsl:variable name="maxOccurs" select="($on/@max-occurs,'1')[1] ! (if (. eq 'unbounded') then '&#x221e;' else .)"/>
      <xsl:text>[</xsl:text>
      <xsl:choose>
         <xsl:when test="$minOccurs = $maxOccurs" expand-text="true">{ $minOccurs }</xsl:when>
         <xsl:when test="number($maxOccurs) = number($minOccurs) + 1" expand-text="true">{ $minOccurs } or { $maxOccurs }</xsl:when>
         <xsl:otherwise expand-text="true">{ $minOccurs } to { $maxOccurs }</xsl:otherwise>
      </xsl:choose>
      <xsl:text>]</xsl:text>
   </xsl:template>

   <xsl:template mode="occurrence-code" match="m:value[@as-type='markup-multiline']">
      <xsl:param name="on" select="." tunnel="true"/>
      <xsl:text expand-text="true">[0 to &#x221e;]</xsl:text>
   </xsl:template>

</xsl:stylesheet>
