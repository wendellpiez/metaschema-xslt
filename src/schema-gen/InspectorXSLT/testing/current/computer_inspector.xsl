<?xml version="1.0" encoding="us-ascii"?>
<xsl:transform xmlns="http://www.w3.org/1999/xhtml"
               xmlns:mx="http://csrc.nist.gov/ns/csd/metaschema-xslt"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               version="3.0"
               xpath-default-namespace="http://example.com/ns/computer"
               exclude-result-prefixes="#all"><!-- Generated 2023-11-02T17:08:21.5400742-04:00 -->
   <xsl:mode on-no-match="fail"/>
   <xsl:mode name="test" on-no-match="shallow-skip"/>
   <!-- .     .     .     .     .     .     .     .     .     .     .     .     .     .     .     .     . -->
   <!--    Templates copied from boilerplate    -->
   <!-- .     .     .     .     .     .     .     .     .     .     .     .     .     .     .     .     . -->
   <xsl:output indent="true" encoding="us-ascii" omit-xml-declaration="true"/>
   <xsl:param name="format" as="xs:string">inspected</xsl:param>
   <!-- format = (plaintext|markdown|html|mx-report|inspected) -->
   <xsl:param name="form" as="xs:string">full</xsl:param>
   <!-- form = (full|summary|one-line) -->
   <xsl:param name="echo" as="xs:string">none</xsl:param>
   <!-- echo = (none|invalid-only|docs|info|warnings|all) - runtime messaging provided with grab-mx mode - does not work with format=inspected -->
   <!-- Entry points - or use initial-template or initial-mode in supporting processors  -->
   <xsl:template mode="#default"
                 priority="101"
                 name="xsl:initial-template"
                 match="root()[$format='inspected']">
      <xsl:call-template name="inspect"/>
   </xsl:template>
   <xsl:template mode="#default" priority="101" match="root()[$format='mx-report']">
      <xsl:call-template name="mx-report"/>
   </xsl:template>
   <xsl:template mode="#default" priority="101" match="root()[$format='html']">
      <xsl:call-template name="html"/>
   </xsl:template>
   <xsl:template mode="#default" priority="101" match="root()[$format='markdown']">
      <xsl:call-template name="markdown"/>
   </xsl:template>
   <xsl:template mode="#default" priority="101" match="root()[$format='plaintext']">
      <xsl:call-template name="plaintext"/>
   </xsl:template>
   <!-- these modes are reserved for entry points matching "/" and should never match otherwise  -->
   <xsl:mode name="inspect" on-no-match="fail"/>
   <xsl:mode name="mx-report" on-no-match="fail"/>
   <xsl:mode name="mx" on-no-match="fail"/>
   <xsl:mode name="html" on-no-match="fail"/>
   <xsl:mode name="markdown" on-no-match="fail"/>
   <xsl:mode name="md" on-no-match="fail"/>
   <xsl:mode name="plaintext" on-no-match="fail"/>
   <!-- entering with no mode or 'inspect' mode, or by name 'inspect' returns an annotated copy of input tree   -->
   <xsl:template match="/" name="inspect" mode="inspect">
      <mx:validation src="{ base-uri(.) }">
         <xsl:apply-templates select="." mode="metaschema-metadata"/>
         <!-- initiates the actual validation traversal          -->
         <xsl:apply-templates mode="validate"/>
      </mx:validation>
   </xsl:template>
   <xsl:template match="/" mode="mx-report mx">
      <xsl:call-template name="mx-report"/>
   </xsl:template>
   <!-- returns mx reports only, with a summary - can be parameterized to filter -->
   <xsl:template name="mx-report">
      <xsl:variable name="mx-validation">
         <xsl:call-template name="inspect"/>
      </xsl:variable>
      <xsl:apply-templates mode="grab-mx" select="$mx-validation/*"/>
   </xsl:template>
   <xsl:template name="mx">
      <xsl:call-template name="mx-report"/>
   </xsl:template>
   <xsl:template match="/" mode="html">
      <xsl:call-template name="html"/>
   </xsl:template>
   <xsl:template name="html">
      <xsl:variable name="mx-reports">
         <!-- reports has a summary along with any reports -->
         <xsl:call-template name="mx-report"/>
      </xsl:variable>
      <xsl:apply-templates mode="mx-to-html" select="$mx-reports/*"/>
   </xsl:template>
   <xsl:template match="/" mode="markdown md">
      <xsl:call-template name="markdown"/>
   </xsl:template>
   <xsl:template name="markdown">
      <xsl:variable name="html-report">
         <xsl:call-template name="html"/>
      </xsl:variable>
      <xsl:apply-templates mode="html-to-md" select="$html-report/*"/>
   </xsl:template>
   <xsl:template match="/" mode="plaintext">
      <xsl:call-template name="plaintext"/>
   </xsl:template>
   <xsl:template name="plaintext">
      <xsl:variable name="html-report">
         <xsl:call-template name="html"/>
      </xsl:variable>
      <xsl:apply-templates mode="html-to-md" select="$html-report/*">
         <!--single lf passed to override double lf -->
         <xsl:with-param name="lf2"
                         tunnel="true"
                         as="xs:string"
                         select="codepoints-to-string(10)"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template name="md">
      <xsl:call-template name="markdown"/>
   </xsl:template>
   <xsl:mode name="validate" on-no-match="shallow-copy"/>
   <xsl:mode name="value-only" on-no-match="text-only-copy"/>
   <xsl:mode name="validate-markup-line" on-no-match="text-only-copy"/>
   <xsl:mode name="validate-markup-multiline" on-no-match="shallow-skip"/>
   <xsl:mode name="constraint-cascade"
             on-no-match="fail"
             on-multiple-match="use-last"/>
   <xsl:template match="* | @*" priority="1" mode="constraint-cascade"/>
   <xsl:template match="*" mode="validate">
      <xsl:copy>
         <xsl:namespace name="mx">http://csrc.nist.gov/ns/csd/metaschema-xslt</xsl:namespace>
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates select="." mode="test"/>
         <xsl:apply-templates mode="validate"/>
      </xsl:copy>
   </xsl:template>
   <!-- tossing these as preventive measure -->
   <xsl:template mode="validate" match="processing-instruction()"/>
   <!-- as they may however be informative, comments are kept   -->
   <xsl:template mode="validate" match="comment()">
      <xsl:copy-of select="."/>
   </xsl:template>
   <xsl:template match="text()" mode="validate">
      <xsl:apply-templates select="." mode="test"/>
      <xsl:copy-of select="."/>
   </xsl:template>
   <!-- wrapper template for testing on each node, to be overridden
         and extended for known elements -->
   <xsl:template match="*" mode="test">
      <!-- report if not recognized -->
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">av.118</xsl:with-param>
         <xsl:with-param name="class">_UE unmatched-element</xsl:with-param>
         <xsl:with-param name="msg" expand-text="true">Unrecognized element <mx:gi>{ name() }</mx:gi>.</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="text()[not(matches(., '\S'))]" priority="0.1" mode="test"/>
   <xsl:template match="text()" mode="test">
      <!-- report if not recognized -->
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">av.129</xsl:with-param>
         <xsl:with-param name="class">_UT unexpected-text</xsl:with-param>
         <xsl:with-param name="msg" expand-text="true">Errant text content.</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <!-- report if not recognized -->
   <xsl:template match="*" mode="validate-markup-multiline" name="notice-multiline">
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">av.138</xsl:with-param>
         <xsl:with-param name="class">_UMM unmatched-markup-multiline</xsl:with-param>
         <xsl:with-param name="msg" expand-text="true">Unrecognized element <mx:gi>{ name() }</mx:gi> in multiline
            markup.</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <xsl:variable name="markup-multline-blocks"
                 select="          'p', 'pre', 'ul', 'ol', 'table',          'h1', 'h2', 'h3', 'h4', 'h5'"/>
   <!--<xsl:template match="p | pre | h1 | h2 | h3 | h5 | h5 | h6 | li | td" mode="validate-markup-multiline">
        <xsl:apply-templates mode="validate-markup-line"/>
    </xsl:template>
    
    <xsl:template match="ul | ol" mode="validate-markup-multiline">
        <xsl:apply-templates select="li" mode="validate-markup-multiline"/>
        <xsl:for-each select="* except li">
            <xsl:call-template name="notice-multiline"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="table" mode="validate-markup-multiline">
        <xsl:apply-templates select="tr" mode="validate-markup-multiline"/>
        <xsl:for-each select="* except tr">
            <xsl:call-template name="notice-multiline"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="tr" mode="validate-markup-multiline">
        <xsl:apply-templates select="td" mode="validate-markup-multiline"/>
        <xsl:for-each select="* except td">
            <xsl:call-template name="notice-multiline"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="em | strong | i | b | sub | sup | q | a | insert" mode="validate-markup-line">
        <xsl:apply-templates mode="validate-markup-line"/>
    </xsl:template>
    
    <xsl:template match="text()" mode="validate-markup-line"/>-->
   <xsl:template match="*" mode="validate-markup-line">
      <!-- report if not recognized -->
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">av.181</xsl:with-param>
         <xsl:with-param name="class">_UM unmatched-markup</xsl:with-param>
         <xsl:with-param name="msg" expand-text="true">Unrecognized element <mx:gi>{ name() }</mx:gi>.</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <!-- ... and attributes ...  -->
   <xsl:template match="@*" mode="test validate-markup-line validate-markup-multiline">
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">av.190</xsl:with-param>
         <xsl:with-param name="class">_UA unmatched-attribute</xsl:with-param>
         <xsl:with-param name="msg" expand-text="true">Unrecognized attribute <mx:gi>@{ name() }</mx:gi> on element <mx:gi>{ name(..) }</mx:gi>.</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <xsl:template xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                 mode="test"
                 match="@xsi:*"/>
   <xsl:template name="notice">
      <xsl:param name="cf" as="xs:string" select="AV.199"/>
      <!-- default expecting override -->
      <xsl:param name="rule-id" as="xs:string*" select="()"/>
      <!-- rule-id may be multiple -->
      <xsl:param name="condition" as="xs:boolean" select="true()"/>
      <xsl:param name="testing" as="xs:string">exists(.)</xsl:param>
      <!-- hints at why something is reported -->
      <xsl:param name="class" as="xs:string">__U uncategorized</xsl:param>
      <xsl:param name="matching" as="xs:string">*</xsl:param>
      <xsl:param name="msg">[info]</xsl:param>
      <xsl:param name="level" as="xs:string">ERROR</xsl:param>
      <xsl:if test="$condition">
         <xsl:variable name="xpath">
            <!-- handmade paths avoid namespaces and other complications of path(.) -->
            <xsl:apply-templates select="." mode="xpath"/>
         </xsl:variable>
         <mx:report cf="{$cf}"
                    test="{ $testing }"
                    class="{$class}"
                    xpath="{ $xpath }"
                    level="{ $level }">
            <xsl:if test="exists($rule-id[matches(., '\S')])">
               <xsl:attribute name="rule-id" select="string-join($rule-id[matches(., '\S')], ' ')"/>
            </xsl:if>
            <xsl:if test="not($matching = '*')">
               <xsl:attribute name="matching" select="$matching"/>
            </xsl:if>
            <xsl:sequence select="$msg"/>
         </mx:report>
      </xsl:if>
   </xsl:template>
   <xsl:template name="echoing">
      <xsl:param name="msg">[info]</xsl:param>
      <xsl:if test="not($echo = 'none')">
         <xsl:message>
            <xsl:sequence select="$msg"/>
         </xsl:message>
      </xsl:if>
   </xsl:template>
   <xsl:template mode="xpath" match="*">
      <xsl:apply-templates select="parent::*" mode="#current"/>
      <xsl:text expand-text="true">/{ name() }</xsl:text>
   </xsl:template>
   <xsl:template mode="xpath"
                 match="*[node-name() = (../* except current())/node-name()]">
      <xsl:apply-templates select="parent::*" mode="#current"/>
      <xsl:variable name="kin" select="../*[node-name() = current()/node-name()]"/>
      <xsl:text expand-text="true">/{ name() }[{ mx:element-position(.)[count($kin) gt 1] }]</xsl:text>
   </xsl:template>
   <xsl:template mode="xpath" match="@*">
      <xsl:apply-templates select="parent::*" mode="#current"/>
      <xsl:text expand-text="true">/@{ name() }</xsl:text>
   </xsl:template>
   <xsl:template mode="xpath" match="text()">
      <xsl:apply-templates select="parent::*" mode="#current"/>
      <xsl:variable name="kin" select="../text()"/>
      <xsl:variable name="place" expand-text="true">[{ count(preceding-sibling::text()|.) }]</xsl:variable>
      <xsl:text expand-text="true">/text(){ (count($kin)[. gt 1]) ! $place }</xsl:text>
   </xsl:template>
   <xsl:template mode="xpath" match="comment()">
      <xsl:apply-templates select="parent::*" mode="#current"/>
      <xsl:variable name="kin" select="../comment()"/>
      <xsl:variable name="place" expand-text="true">[{ count(preceding-sibling::comment()|.) }]</xsl:variable>
      <xsl:text expand-text="true">/text(){ (count($kin)[. gt 1]) ! $place }</xsl:text>
   </xsl:template>
   <xsl:template mode="xpath" match="processing-instruction()">
      <xsl:apply-templates select="parent::*" mode="#current"/>
      <xsl:variable name="kin" select="../processing-instruction()"/>
      <xsl:variable name="place" expand-text="true">[{ count(preceding-sibling::processing-instruction()|.)
         }]</xsl:variable>
      <xsl:text expand-text="true">/text(){ (count($kin)[. gt 1]) ! $place }</xsl:text>
   </xsl:template>
   <xsl:template name="check-datatype">
      <xsl:apply-templates select="." mode="test-datatype"/>
   </xsl:template>
   <xsl:template mode="test-datatype" match="*"/>
   <xsl:function name="mx:element-position">
      <xsl:param name="for" as="element()"/>
      <xsl:variable name="qname" select="node-name($for)"/>
      <xsl:sequence select="count($for | $for/preceding-sibling::*[node-name() = $qname])"/>
   </xsl:function>
   <xsl:function name="mx:pluralize" as="xs:string" expand-text="true">
      <xsl:param name="for" as="xs:double"/>
      <xsl:param name="as" as="xs:string"/>
      <xsl:choose>
         <xsl:when test="$for eq 1">{ $as }</xsl:when>
         <xsl:otherwise>{ $as }s</xsl:otherwise>
         <!-- we could dive into templates if we hit a special case -->
      </xsl:choose>
   </xsl:function>
   <xsl:template name="check-markup-line-datatype">
      <xsl:apply-templates mode="validate-markup-line"/>
   </xsl:template>
   <xsl:template name="check-markup-multiline-datatype">
      <xsl:apply-templates mode="validate-markup-multiline"/>
   </xsl:template>
   <!-- stub to be replaced with results from produce-datatype-functions.xsl  -->
   <xsl:function name="mx:datatype-validate" as="xs:boolean">
      <xsl:param name="value" as="item()"/>
      <xsl:param name="nominal-type" as="item()?"/>
      <xsl:sequence select="true()"/>
   </xsl:function>
   <!-- given a node, a key name, value (sequence) and scope for evaluation, and a sequence of items,
     returns those items that are returned by the key (in document order) -->
   <xsl:function name="mx:key-matches-among-items" as="node()*">
      <xsl:param name="item" as="item()"/>
      <xsl:param name="items" as="item()+"/>
      <xsl:param name="keyname" as="xs:string"/>
      <xsl:param name="keyval" as="item()*"/>
      <xsl:param name="keyscope" as="node()"/>
      <xsl:sequence select="$item!key($keyname,$keyval,$keyscope/root()) intersect $items"/>
   </xsl:function>
   <!-- Mode grab-mx filters mx from its 'host' XML -->
   <xsl:mode name="grab-mx" on-no-match="shallow-skip"/>
   <!--copied from mx-grabber.xsl -->
   <xsl:template match="mx:*" mode="grab-mx">
      <xsl:copy-of select="." copy-namespaces="false"/>
   </xsl:template>
   <!-- Nominally invalid examples has errors or critical along with warning and info reports but no errors or critical -->
   <xsl:template match="/mx:validation[descendant::mx:report/@level = ('CRITICAL', 'ERROR')]"
                 priority="103"
                 mode="grab-mx">
      <xsl:variable name="report-count" select="count(.//mx:report)"/>
      <xsl:variable name="error-count"
                    select="count(.//mx:report[@level = ('CRITICAL', 'ERROR')])"/>
      <xsl:call-template name="echoing" expand-text="true">
         <xsl:with-param name="msg">
            <xsl:choose>
               <xsl:when test="$report-count eq $error-count">File { replace(@src,'.*/','') } has { $error-count } {
                  mx:pluralize($error-count,'error')}.</xsl:when>
               <xsl:otherwise>File { replace(@src,'.*/','') } has { $report-count } {
                  mx:pluralize($report-count,'issue') } reported including { $error-count } {
                  mx:pluralize($error-count,'error')}.</xsl:otherwise>
            </xsl:choose>
         </xsl:with-param>
      </xsl:call-template>
      <xsl:next-match/>
   </xsl:template>
   <!-- Nominally valid examples may have warning or info reports but no errors or critical -->
   <xsl:template match="/mx:validation[not(descendant::mx:report/@level = ('CRITICAL', 'ERROR'))]"
                 priority="102"
                 mode="grab-mx">
      <xsl:if test="not($echo = 'invalid-only')">
         <xsl:call-template name="echoing" expand-text="true">
            <xsl:with-param name="msg">File { replace(@src,'.*/','') } is reported VALID, no issues ...
            </xsl:with-param>
         </xsl:call-template>
      </xsl:if>
      <xsl:next-match/>
   </xsl:template>
   <xsl:template match="/mx:validation" priority="101" mode="grab-mx">
      <xsl:copy copy-namespaces="false">
         <xsl:copy-of select="@*"/>
         <xsl:attribute name="elements"
                        select="count(descendant::* except .//mx:*/descendant-or-self::*)"/>
         <xsl:attribute name="attributes"
                        select="count(descendant::*/@* except .//mx:*/descendant-or-self::*/@*)"/>
         <xsl:attribute name="reports" select="count(.//mx:report)"/>
         <xsl:attribute name="severe-reports"
                        select="count(.//mx:report[@level = ('CRITICAL', 'ERROR')])"/>
         <xsl:apply-templates mode="grab-mx"/>
      </xsl:copy>
   </xsl:template>
   <!-- copy reports but do not announce them -->
   <xsl:template match="mx:report[$echo = ('docs', 'info')][@level = ('ERROR', 'CRITICAL', 'WARNING')]"
                 mode="grab-mx">
      <xsl:copy-of select="." copy-namespaces="false"/>
   </xsl:template>
   <xsl:template match="mx:report[$echo = 'warnings'][@level = ('ERROR', 'CRITICAL')]"
                 mode="grab-mx">
      <xsl:copy-of select="." copy-namespaces="false"/>
   </xsl:template>
   <xsl:template match="mx:report" mode="grab-mx" expand-text="true">
      <xsl:if test="not($form = ('summary', 'one-line'))">
         <xsl:call-template name="echoing" expand-text="true">
            <xsl:with-param name="msg">{ (@level,'ERROR')[1] } [CLASS) { @class } ][PATH) { @xpath } ][REPORT) {
               string(.) }]</xsl:with-param>
         </xsl:call-template>
      </xsl:if>
      <xsl:next-match/>
   </xsl:template>
   <xsl:mode name="mx-to-html" on-no-match="text-only-copy"/>
   <xsl:template match="/mx:validation" mode="mx-to-html" expand-text="true">
      <xsl:variable name="reported-valid" select="@reports = 0"/>
      <xsl:variable name="validating-filename" select="replace(@src, '.*/', '')"/>
      <xsl:variable name="checked"
                    select="             if ($reported-valid) then                '&#x2714;'             else                '&#x2718;'"/>
      <html>
         <head>
            <title>{ $validating-filename } - { $checked } - { mx:metaschema/@shortname } validation</title>
            <xsl:call-template name="html-css"/>
         </head>
         <body>
            <h1>{ $checked } Validating <a href="{ @src }">{ $validating-filename }</a> - { mx:metaschema } - found {
               'IN'[not($reported-valid)] }VALID</h1>
            <xsl:if test="not($form = 'one-line')">
               <xsl:apply-templates mode="#current" select="mx:metaschema"/>
               <p>
                  <code>{ $validating-filename }</code> contains { @elements} {
                  mx:pluralize(@elements/number(),'element') } and { @attributes } {
                  mx:pluralize(@attributes/number(),'attribute') }.</p>
               <xsl:apply-templates select="." mode="summary"/>
               <xsl:if test="not($form = ('one-line', 'summary'))">
                  <main>
                     <xsl:apply-templates mode="#current" select="child::* except mx:metaschema"/>
                  </main>
               </xsl:if>
            </xsl:if>
         </body>
      </html>
   </xsl:template>
   <xsl:template name="html-css" xml:space="preserve" expand-text="false">
<style type="text/css">
main { max-width: fit-content }
details { margin-top: 0.5em; padding: 0.5em; outline: thin solid black }
details.WARNING { outline: thin dotted grey }
details.INFORMATIONAL { outline: medium solid slateblue }
summary { margin: 0em }
details p { margin: 0.2em 0em }   
.xpath    { font-family: monospace }
.exc { font-size: 85%; padding: 0.2em; background-color: cornsilk; font-family: sans-serif }
</style>
   </xsl:template>
   <xsl:template match="mx:validation" mode="summary" expand-text="true">
      <div class="summary">
         <p>{ count(.//mx:report) } { mx:pluralize(count(.//mx:report),'issue') } reported.</p>
         <p>{ (1 to count(.//mx:report)) ! '&#x1f4a5;' }</p>
      </div>
   </xsl:template>
   <xsl:template match="mx:validation[empty(descendant::mx:report)]" mode="summary">
      <div class="summary valid">
         <p>Good news - nothing to report - the instance is valid. &#x1f680;</p>
      </div>
   </xsl:template>
   <xsl:template match="mx:metaschema" mode="mx-to-html" expand-text="true">
      <p class="metadata">Checking against the rules defined in metaschema <b>{ . }</b>{ @version ! (', version ' || .)} (namespace <code>{ @namespace
            }</code>)</p>
   </xsl:template>
   <xsl:template match="mx:report" mode="mx-to-html" expand-text="true">
      <details class="report { @class }{ @level[not(.='ERROR')] ! (' ' || .) }">
         <summary>
            <xsl:apply-templates mode="#current"/>
         </summary>
         <p class="exc">{ @class }{ @level[not(.='ERROR')] ! (' ' || .) }</p>
         <ul>
            <xsl:for-each select="@rule-id">
               <li class="test">Rule ID: <code>{ . }</code>
               </li>
            </xsl:for-each>
            <li class="test">test: <code>{ @test }</code>
            </li>
            <xsl:if test="@matching != '*'">
               <li class="matching">matching: <code>{ @matching }</code>
               </li>
            </xsl:if>
            <li>XPath: <code class="xpath">{ @xpath }</code>
            </li>
         </ul>
      </details>
   </xsl:template>
   <xsl:template match="mx:gi" mode="mx-to-html" priority="1">
      <b>
         <xsl:apply-templates mode="#current"/>
      </b>
   </xsl:template>
   <xsl:template match="mx:code | mx:tt" mode="mx-to-html" priority="1">
      <code style="white-space:pre-wrap">
         <xsl:apply-templates mode="#current"/>
      </code>
   </xsl:template>
   <xsl:template match="mx:report/mx:*" mode="mx-to-html">
      <i>
         <xsl:apply-templates mode="#current"/>
      </i>
   </xsl:template>
   <xsl:mode name="html-to-md" on-no-match="text-only-copy"/>
   <xsl:variable name="lf" as="xs:string" expand-text="true">{ codepoints-to-string(10) }</xsl:variable>
   <xsl:template mode="html-to-md"
                 match="html"
                 xpath-default-namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates mode="#current" select="body"/>
   </xsl:template>
   <xsl:template mode="html-to-md"
                 match="style"
                 xpath-default-namespace="http://www.w3.org/1999/xhtml"/>
   <xsl:template mode="html-to-md"
                 match="body"
                 expand-text="true"
                 xpath-default-namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates mode="#current"/>
      <xsl:text>{ $lf }</xsl:text>
   </xsl:template>
   <xsl:template mode="html-to-md"
                 match="div | details"
                 expand-text="true"
                 xpath-default-namespace="http://www.w3.org/1999/xhtml">
      <xsl:param name="lf2" tunnel="true" as="xs:string" select="$lf || $lf"/>
      <xsl:text>{ $lf2 }---</xsl:text>
      <xsl:apply-templates mode="#current"/>
   </xsl:template>
   <xsl:template mode="html-to-md"
                 match="body/*[1]/self::h1"
                 expand-text="true"
                 xpath-default-namespace="http://www.w3.org/1999/xhtml">
      <xsl:text># </xsl:text>
      <xsl:apply-templates mode="#current"/>
   </xsl:template>
   <xsl:template mode="html-to-md"
                 match="h1"
                 expand-text="true"
                 xpath-default-namespace="http://www.w3.org/1999/xhtml">
      <xsl:param name="lf2" tunnel="true" as="xs:string" select="$lf || $lf"/>
      <xsl:text>{ $lf2 }# </xsl:text>
      <xsl:apply-templates mode="#current"/>
   </xsl:template>
   <xsl:template mode="html-to-md"
                 match="h2"
                 expand-text="true"
                 xpath-default-namespace="http://www.w3.org/1999/xhtml">
      <xsl:param name="lf2" tunnel="true" as="xs:string" select="$lf || $lf"/>
      <xsl:text>{ $lf2 }## </xsl:text>
      <xsl:apply-templates mode="#current"/>
   </xsl:template>
   <xsl:template mode="html-to-md"
                 match="h3 | details/summary"
                 expand-text="true"
                 xpath-default-namespace="http://www.w3.org/1999/xhtml">
      <xsl:param name="lf2" tunnel="true" as="xs:string" select="$lf || $lf"/>
      <xsl:text>{ $lf2 }### </xsl:text>
      <xsl:apply-templates mode="#current"/>
   </xsl:template>
   <xsl:template mode="html-to-md"
                 match="p"
                 expand-text="true"
                 xpath-default-namespace="http://www.w3.org/1999/xhtml">
      <xsl:param name="lf2" tunnel="true" as="xs:string" select="$lf || $lf"/>
      <xsl:text>{ $lf2 }</xsl:text>
      <xsl:apply-templates mode="#current"/>
   </xsl:template>
   <xsl:template mode="html-to-md"
                 match="ul"
                 expand-text="true"
                 xpath-default-namespace="http://www.w3.org/1999/xhtml">
      <xsl:param name="lf2" tunnel="true" as="xs:string" select="$lf || $lf"/>
      <xsl:sequence select="replace($lf2, '&#xA;$', '')"/>
      <xsl:apply-templates mode="#current"/>
   </xsl:template>
   <xsl:template mode="html-to-md"
                 match="li"
                 expand-text="true"
                 xpath-default-namespace="http://www.w3.org/1999/xhtml">
      <xsl:text>{ $lf }- </xsl:text>
      <xsl:apply-templates mode="#current"/>
   </xsl:template>
   <xsl:template mode="html-to-md"
                 match="b"
                 priority="2"
                 xpath-default-namespace="http://www.w3.org/1999/xhtml">
      <xsl:text>**</xsl:text>
      <xsl:apply-templates mode="#current"/>
      <xsl:text>**</xsl:text>
   </xsl:template>
   <xsl:template mode="html-to-md"
                 match="i | p/*"
                 xpath-default-namespace="http://www.w3.org/1999/xhtml">
      <xsl:text>*</xsl:text>
      <xsl:apply-templates mode="#current"/>
      <xsl:text>*</xsl:text>
   </xsl:template>
   <xsl:template mode="html-to-md"
                 match="code"
                 priority="2"
                 xpath-default-namespace="http://www.w3.org/1999/xhtml">
      <xsl:text>`</xsl:text>
      <xsl:apply-templates mode="#current"/>
      <xsl:text>`</xsl:text>
   </xsl:template>
   <xsl:template mode="metaschema-metadata" match="*">
      <mx:metaschema version="0.0.5"
                     shortname="computer"
                     namespace="http://example.com/ns/computer">Computer Model</mx:metaschema>
   </xsl:template>
   <!-- .     .     .     .     .     .     .     .     .     .     .     .     .     .     .     .     . -->
   <!--    Generated rules - first, any roots    -->
   <!-- .     .     .     .     .     .     .     .     .     .     .     .     .     .     .     .     . -->
   <!-- .     .     .     .     .     .     .     .     .     .     .     .     .     .     .     .     . -->
   <!--     Root     -->
   <!-- .     .     .     .     .     .     .     .     .     .     .     .     .     .     .     .     . -->
   <xsl:template match="/computer" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="require-for-computer-assembly"/>
      <xsl:apply-templates select="." mode="constraint-cascade"/>
   </xsl:template>
   <xsl:key name="UNQ_3" match="computer/(usb-device)" use="(@uuid)"/>
   <xsl:template priority="108" mode="constraint-cascade" match="computer">
      <xsl:variable name="within" select="."/>
      <xsl:variable name="selected" select="usb-device"/>
      <xsl:for-each select="usb-device">
         <xsl:call-template name="notice">
            <xsl:with-param name="cf">gix.651</xsl:with-param>
            <xsl:with-param name="rule-id"/>
            <xsl:with-param name="matching" as="xs:string">computer/(usb-device)</xsl:with-param>
            <xsl:with-param name="class">UNIQ uniqueness-violation</xsl:with-param>
            <xsl:with-param name="testing" as="xs:string">not(count(mx:key-matches-among-items(.,$selected,'UNQ_3',(@uuid),$within))=1)</xsl:with-param>
            <xsl:with-param name="condition"
                            select="not(count(mx:key-matches-among-items(.,$selected,'UNQ_3',(@uuid),$within))=1)"/>
            <xsl:with-param name="msg" expand-text="true">With respect to its assigned <mx:gi>(@uuid)</mx:gi>, this <mx:gi>{name(.)}</mx:gi> instance of <mx:code>computer/(usb-device)</mx:code> is expected to be unique within its <mx:gi>{$within/name(.)}</mx:gi>. {count(mx:key-matches-among-items(.,$selected,'UNQ_3',(@uuid),$within))} items are found with the value <mx:code>{string-join(((@uuid)),',')}</mx:code>.</xsl:with-param>
         </xsl:call-template>
      </xsl:for-each>
      <xsl:next-match/>
   </xsl:template>
   <xsl:template priority="107"
                 mode="constraint-cascade"
                 match="computer/(.//prop[not(@ns) or @ns=('http://example.com/ns/computer')]/@name)">
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.526</xsl:with-param>
         <xsl:with-param name="rule-id"/>
         <xsl:with-param name="matching" as="xs:string">computer/(.//prop[not(@ns) or @ns=('http://example.com/ns/computer')]/@name)</xsl:with-param>
         <xsl:with-param name="class">AVCV value-not-allowed</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">not(.=('model'))</xsl:with-param>
         <xsl:with-param name="condition" select="not(.=('model'))"/>
         <xsl:with-param name="msg" expand-text="true">Value <mx:code>{ string(.) }</mx:code>{ .[not(string(.))] ! ' (empty)' } does not appear among permissible (enumerated) values for this <mx:gi>{ name() }</mx:gi>: <mx:code>model</mx:code>.</xsl:with-param>
         <xsl:with-param name="level" select="'ERROR'"/>
      </xsl:call-template>
      <xsl:next-match/>
   </xsl:template>
   <xsl:template priority="106" mode="constraint-cascade" match="computer">
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.617</xsl:with-param>
         <xsl:with-param name="rule-id"/>
         <xsl:with-param name="matching" as="xs:string">computer</xsl:with-param>
         <xsl:with-param name="class">HCCV cardinality-violation</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">not(count(.//prop[not(@ns) or @ns=('http://example.com/ns/computer')]) ge 1 and true())</xsl:with-param>
         <xsl:with-param name="condition"
                         select="not(count(.//prop[not(@ns) or @ns=('http://example.com/ns/computer')]) ge 1 and true())"/>
         <xsl:with-param name="msg" expand-text="true">Counting <mx:gi>.//prop[not(@ns) or @ns=('http://example.com/ns/computer')]</mx:gi> under <mx:code>computer</mx:code> finds {count(.//prop[not(@ns) or @ns=('http://example.com/ns/computer')])} - expecting at least 1.</xsl:with-param>
      </xsl:call-template>
      <xsl:next-match/>
   </xsl:template>
   <xsl:template priority="105" mode="constraint-cascade" match="computer">
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.617</xsl:with-param>
         <xsl:with-param name="rule-id"/>
         <xsl:with-param name="matching" as="xs:string">computer</xsl:with-param>
         <xsl:with-param name="class">HCCV cardinality-violation</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">not(true() and count(.//prop[not(@ns) or @ns=('http://example.com/ns/computer')]) le 1)</xsl:with-param>
         <xsl:with-param name="condition"
                         select="not(true() and count(.//prop[not(@ns) or @ns=('http://example.com/ns/computer')]) le 1)"/>
         <xsl:with-param name="msg" expand-text="true">Counting <mx:gi>.//prop[not(@ns) or @ns=('http://example.com/ns/computer')]</mx:gi> under <mx:code>computer</mx:code> finds {count(.//prop[not(@ns) or @ns=('http://example.com/ns/computer')])} - expecting no more than 1.</xsl:with-param>
      </xsl:call-template>
      <xsl:next-match/>
   </xsl:template>
   <xsl:key name="NDX_internal-links"
            match="computer/(descendant::*[exists(@id|@uuid)])"
            use="(@id|@uuid)"/>
   <xsl:template priority="103" mode="constraint-cascade" match="computer">
      <xsl:variable name="within" select="."/>
      <xsl:variable name="selected" select="//computer/descendant::*[exists(@id|@uuid)]"/>
      <xsl:for-each select="//a">
         <xsl:call-template name="notice">
            <xsl:with-param name="cf">gix.649</xsl:with-param>
            <xsl:with-param name="rule-id"/>
            <xsl:with-param name="matching" as="xs:string">computer/(//a)</xsl:with-param>
            <xsl:with-param name="class">NXHK index-lookup-fail</xsl:with-param>
            <xsl:with-param name="testing" as="xs:string">not(exists(mx:key-matches-among-items(.,$selected,'NDX_internal-links',(@href)[matches(.,'^#(.+)$')] ! replace(.,'^#(.+)$','$1'),$within)))</xsl:with-param>
            <xsl:with-param name="condition"
                            select="not(exists(mx:key-matches-among-items(.,$selected,'NDX_internal-links',(@href)[matches(.,'^#(.+)$')] ! replace(.,'^#(.+)$','$1'),$within)))"/>
            <xsl:with-param name="msg" expand-text="true">With respect to its assigned index  value, this <mx:gi>{name(.)}</mx:gi> is expected to correspond within its <mx:gi>{$within/name(.)}</mx:gi> to a value listed under index <mx:b>internal-links</mx:b>. This index has no entry under the key value <mx:code>{string-join(((@href)[matches(.,'^#(.+)$')] ! replace(.,'^#(.+)$','$1')),',')}</mx:code>.</xsl:with-param>
         </xsl:call-template>
      </xsl:for-each>
      <xsl:next-match/>
   </xsl:template>
   <!-- .     .     .     .     .     .     .     .     .     .     .     .     .     .     .     .     . -->
   <!--     Occurrences - templates in mode 'test'     -->
   <!-- .     .     .     .     .     .     .     .     .     .     .     .     .     .     .     .     . -->
   <xsl:template priority="5" match="computer/motherboard/vendor" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::vendor) gt 1</xsl:with-param>
         <xsl:with-param name="condition" select="count(. | preceding-sibling::vendor) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>vendor</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::type | preceding-sibling::cpu | preceding-sibling::ata-socket | preceding-sibling::memory | preceding-sibling::cooling | preceding-sibling::expansion-card)</xsl:with-param>
         <xsl:with-param name="condition"
                         select="exists(preceding-sibling::type | preceding-sibling::cpu | preceding-sibling::ata-socket | preceding-sibling::memory | preceding-sibling::cooling | preceding-sibling::expansion-card)"/>
         <xsl:with-param name="msg">Element <mx:gi>vendor</mx:gi> is unexpected following <mx:gi>type</mx:gi>, <mx:gi>cpu</mx:gi>, <mx:gi>ata-socket</mx:gi>, <mx:gi>memory</mx:gi>, <mx:gi>cooling</mx:gi>, or <mx:gi>expansion-card</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-vendor-assembly"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template priority="5" match="motherboard/cpu/vendor" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::vendor) gt 1</xsl:with-param>
         <xsl:with-param name="condition" select="count(. | preceding-sibling::vendor) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>vendor</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::product-name | preceding-sibling::cost | preceding-sibling::architecture | preceding-sibling::speed | preceding-sibling::prop | preceding-sibling::remarks)</xsl:with-param>
         <xsl:with-param name="condition"
                         select="exists(preceding-sibling::product-name | preceding-sibling::cost | preceding-sibling::architecture | preceding-sibling::speed | preceding-sibling::prop | preceding-sibling::remarks)"/>
         <xsl:with-param name="msg">Element <mx:gi>vendor</mx:gi> is unexpected following <mx:gi>product-name</mx:gi>, <mx:gi>cost</mx:gi>, <mx:gi>architecture</mx:gi>, <mx:gi>speed</mx:gi>, <mx:gi>prop</mx:gi>, or <mx:gi>remarks</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-vendor-assembly"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template priority="5" match="motherboard/cpu/prop" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::prop) gt 1</xsl:with-param>
         <xsl:with-param name="condition" select="count(. | preceding-sibling::prop) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>prop</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::remarks)</xsl:with-param>
         <xsl:with-param name="condition" select="exists(preceding-sibling::remarks)"/>
         <xsl:with-param name="msg">Element <mx:gi>prop</mx:gi> is unexpected following <mx:gi>remarks</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-property-assembly"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template priority="5" match="motherboard/ata-socket/vendor" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::vendor) gt 1</xsl:with-param>
         <xsl:with-param name="condition" select="count(. | preceding-sibling::vendor) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>vendor</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::product-name | preceding-sibling::cost | preceding-sibling::type | preceding-sibling::prop | preceding-sibling::remarks)</xsl:with-param>
         <xsl:with-param name="condition"
                         select="exists(preceding-sibling::product-name | preceding-sibling::cost | preceding-sibling::type | preceding-sibling::prop | preceding-sibling::remarks)"/>
         <xsl:with-param name="msg">Element <mx:gi>vendor</mx:gi> is unexpected following <mx:gi>product-name</mx:gi>, <mx:gi>cost</mx:gi>, <mx:gi>type</mx:gi>, <mx:gi>prop</mx:gi>, or <mx:gi>remarks</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-vendor-assembly"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template priority="5" match="motherboard/ata-socket/prop" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::prop) gt 1</xsl:with-param>
         <xsl:with-param name="condition" select="count(. | preceding-sibling::prop) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>prop</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::remarks)</xsl:with-param>
         <xsl:with-param name="condition" select="exists(preceding-sibling::remarks)"/>
         <xsl:with-param name="msg">Element <mx:gi>prop</mx:gi> is unexpected following <mx:gi>remarks</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-property-assembly"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template priority="5" match="motherboard/memory/vendor" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::vendor) gt 1</xsl:with-param>
         <xsl:with-param name="condition" select="count(. | preceding-sibling::vendor) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>vendor</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::product-name | preceding-sibling::cost | preceding-sibling::byte-size | preceding-sibling::prop | preceding-sibling::remarks)</xsl:with-param>
         <xsl:with-param name="condition"
                         select="exists(preceding-sibling::product-name | preceding-sibling::cost | preceding-sibling::byte-size | preceding-sibling::prop | preceding-sibling::remarks)"/>
         <xsl:with-param name="msg">Element <mx:gi>vendor</mx:gi> is unexpected following <mx:gi>product-name</mx:gi>, <mx:gi>cost</mx:gi>, <mx:gi>byte-size</mx:gi>, <mx:gi>prop</mx:gi>, or <mx:gi>remarks</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-vendor-assembly"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template priority="5" match="motherboard/memory/prop" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::prop) gt 1</xsl:with-param>
         <xsl:with-param name="condition" select="count(. | preceding-sibling::prop) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>prop</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::remarks)</xsl:with-param>
         <xsl:with-param name="condition" select="exists(preceding-sibling::remarks)"/>
         <xsl:with-param name="msg">Element <mx:gi>prop</mx:gi> is unexpected following <mx:gi>remarks</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-property-assembly"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template priority="5" match="computer/motherboard/cooling" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::cooling) gt 1</xsl:with-param>
         <xsl:with-param name="condition" select="count(. | preceding-sibling::cooling) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>cooling</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::expansion-card)</xsl:with-param>
         <xsl:with-param name="condition" select="exists(preceding-sibling::expansion-card)"/>
         <xsl:with-param name="msg">Element <mx:gi>cooling</mx:gi> is unexpected following <mx:gi>expansion-card</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-cooling-assembly"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template priority="5" match="motherboard/expansion-card/vendor" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::vendor) gt 1</xsl:with-param>
         <xsl:with-param name="condition" select="count(. | preceding-sibling::vendor) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>vendor</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::product-name | preceding-sibling::cost | preceding-sibling::type | preceding-sibling::prop | preceding-sibling::remarks)</xsl:with-param>
         <xsl:with-param name="condition"
                         select="exists(preceding-sibling::product-name | preceding-sibling::cost | preceding-sibling::type | preceding-sibling::prop | preceding-sibling::remarks)"/>
         <xsl:with-param name="msg">Element <mx:gi>vendor</mx:gi> is unexpected following <mx:gi>product-name</mx:gi>, <mx:gi>cost</mx:gi>, <mx:gi>type</mx:gi>, <mx:gi>prop</mx:gi>, or <mx:gi>remarks</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-vendor-assembly"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template priority="5" match="motherboard/expansion-card/prop" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::prop) gt 1</xsl:with-param>
         <xsl:with-param name="condition" select="count(. | preceding-sibling::prop) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>prop</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::remarks)</xsl:with-param>
         <xsl:with-param name="condition" select="exists(preceding-sibling::remarks)"/>
         <xsl:with-param name="msg">Element <mx:gi>prop</mx:gi> is unexpected following <mx:gi>remarks</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-property-assembly"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template priority="5" match="computer/usb-device/vendor" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::vendor) gt 1</xsl:with-param>
         <xsl:with-param name="condition" select="count(. | preceding-sibling::vendor) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>vendor</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::product-name | preceding-sibling::cost | preceding-sibling::prop | preceding-sibling::remarks)</xsl:with-param>
         <xsl:with-param name="condition"
                         select="exists(preceding-sibling::product-name | preceding-sibling::cost | preceding-sibling::prop | preceding-sibling::remarks)"/>
         <xsl:with-param name="msg">Element <mx:gi>vendor</mx:gi> is unexpected following <mx:gi>product-name</mx:gi>, <mx:gi>cost</mx:gi>, <mx:gi>prop</mx:gi>, or <mx:gi>remarks</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-vendor-assembly"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template priority="5" match="computer/usb-device/prop" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::prop) gt 1</xsl:with-param>
         <xsl:with-param name="condition" select="count(. | preceding-sibling::prop) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>prop</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::remarks)</xsl:with-param>
         <xsl:with-param name="condition" select="exists(preceding-sibling::remarks)"/>
         <xsl:with-param name="msg">Element <mx:gi>prop</mx:gi> is unexpected following <mx:gi>remarks</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-property-assembly"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template priority="5" match="/computer/prop" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::prop) gt 1</xsl:with-param>
         <xsl:with-param name="condition" select="count(. | preceding-sibling::prop) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>prop</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::remarks)</xsl:with-param>
         <xsl:with-param name="condition" select="exists(preceding-sibling::remarks)"/>
         <xsl:with-param name="msg">Element <mx:gi>prop</mx:gi> is unexpected following <mx:gi>remarks</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-property-assembly"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template priority="5" match="/computer/motherboard" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::motherboard) gt 1</xsl:with-param>
         <xsl:with-param name="condition"
                         select="count(. | preceding-sibling::motherboard) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>motherboard</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::usb-device | preceding-sibling::prop | preceding-sibling::remarks)</xsl:with-param>
         <xsl:with-param name="condition"
                         select="exists(preceding-sibling::usb-device | preceding-sibling::prop | preceding-sibling::remarks)"/>
         <xsl:with-param name="msg">Element <mx:gi>motherboard</mx:gi> is unexpected following <mx:gi>usb-device</mx:gi>, <mx:gi>prop</mx:gi>, or <mx:gi>remarks</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-computer_..._motherboard-assembly"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template priority="112"
                 mode="constraint-cascade"
                 match="/computer/motherboard/(ata-socket/@slot-no)">
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.591</xsl:with-param>
         <xsl:with-param name="rule-id"/>
         <xsl:with-param name="matching" as="xs:string">/computer/motherboard/(ata-socket/@slot-no)</xsl:with-param>
         <xsl:with-param name="class">XPKT expectation-violation</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">not(. = (0 to count(../../ata-socket)))</xsl:with-param>
         <xsl:with-param name="condition" select="not(. = (0 to count(../../ata-socket)))"/>
         <xsl:with-param name="msg" expand-text="true">Expression result for <mx:gi>/computer/motherboard/(ata-socket/@slot-no)</mx:gi> does not conform to expectation <mx:code>. = (0 to count(../../ata-socket))</mx:code>.</xsl:with-param>
      </xsl:call-template>
      <xsl:next-match/>
   </xsl:template>
   <xsl:key name="UNQ_1"
            match="/computer/motherboard/(ata-socket)"
            use="(@slot-no)"/>
   <xsl:template priority="111"
                 mode="constraint-cascade"
                 match="/computer/motherboard">
      <xsl:variable name="within" select="."/>
      <xsl:variable name="selected" select="ata-socket"/>
      <xsl:for-each select="ata-socket">
         <xsl:call-template name="notice">
            <xsl:with-param name="cf">gix.651</xsl:with-param>
            <xsl:with-param name="rule-id"/>
            <xsl:with-param name="matching" as="xs:string">/computer/motherboard/(ata-socket)</xsl:with-param>
            <xsl:with-param name="class">UNIQ uniqueness-violation</xsl:with-param>
            <xsl:with-param name="testing" as="xs:string">not(count(mx:key-matches-among-items(.,$selected,'UNQ_1',(@slot-no),$within))=1)</xsl:with-param>
            <xsl:with-param name="condition"
                            select="not(count(mx:key-matches-among-items(.,$selected,'UNQ_1',(@slot-no),$within))=1)"/>
            <xsl:with-param name="msg" expand-text="true">With respect to its assigned <mx:gi>(@slot-no)</mx:gi>, this <mx:gi>{name(.)}</mx:gi> instance of <mx:code>/computer/motherboard/(ata-socket)</mx:code> is expected to be unique within its <mx:gi>{$within/name(.)}</mx:gi>. {count(mx:key-matches-among-items(.,$selected,'UNQ_1',(@slot-no),$within))} items are found with the value <mx:code>{string-join(((@slot-no)),',')}</mx:code>.</xsl:with-param>
         </xsl:call-template>
      </xsl:for-each>
      <xsl:next-match/>
   </xsl:template>
   <xsl:key name="NDX_socket-by-slot"
            match="/computer/motherboard/(ata-socket)"
            use="(@slot-no)"/>
   <xsl:template priority="109"
                 mode="constraint-cascade"
                 match="/computer/motherboard">
      <xsl:variable name="within" select="."/>
      <xsl:variable name="selected" select="//motherboard/ata-socket"/>
      <xsl:for-each select="expansion-card">
         <xsl:call-template name="notice">
            <xsl:with-param name="cf">gix.649</xsl:with-param>
            <xsl:with-param name="rule-id"/>
            <xsl:with-param name="matching" as="xs:string">/computer/motherboard/(expansion-card)</xsl:with-param>
            <xsl:with-param name="class">NXHK index-lookup-fail</xsl:with-param>
            <xsl:with-param name="testing" as="xs:string">not(exists(mx:key-matches-among-items(.,$selected,'NDX_socket-by-slot',(@socket-no),$within)))</xsl:with-param>
            <xsl:with-param name="condition"
                            select="not(exists(mx:key-matches-among-items(.,$selected,'NDX_socket-by-slot',(@socket-no),$within)))"/>
            <xsl:with-param name="msg" expand-text="true">With respect to its assigned index  value, this <mx:gi>{name(.)}</mx:gi> is expected to correspond within its <mx:gi>{$within/name(.)}</mx:gi> to a value listed under index <mx:b>socket-by-slot</mx:b>. This index has no entry under the key value <mx:code>{string-join(((@socket-no)),',')}</mx:code>.</xsl:with-param>
         </xsl:call-template>
      </xsl:for-each>
      <xsl:next-match/>
   </xsl:template>
   <xsl:template priority="5" match="computer/motherboard/cpu" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::cpu) gt 1</xsl:with-param>
         <xsl:with-param name="condition" select="count(. | preceding-sibling::cpu) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>cpu</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::ata-socket | preceding-sibling::memory | preceding-sibling::cooling | preceding-sibling::expansion-card)</xsl:with-param>
         <xsl:with-param name="condition"
                         select="exists(preceding-sibling::ata-socket | preceding-sibling::memory | preceding-sibling::cooling | preceding-sibling::expansion-card)"/>
         <xsl:with-param name="msg">Element <mx:gi>cpu</mx:gi> is unexpected following <mx:gi>ata-socket</mx:gi>, <mx:gi>memory</mx:gi>, <mx:gi>cooling</mx:gi>, or <mx:gi>expansion-card</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-computer_..._motherboard_..._cpu-assembly"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template priority="5" match="computer/motherboard/ata-socket" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::ata-socket) gt 1</xsl:with-param>
         <xsl:with-param name="condition" select="count(. | preceding-sibling::ata-socket) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>ata-socket</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::memory | preceding-sibling::cooling | preceding-sibling::expansion-card)</xsl:with-param>
         <xsl:with-param name="condition"
                         select="exists(preceding-sibling::memory | preceding-sibling::cooling | preceding-sibling::expansion-card)"/>
         <xsl:with-param name="msg">Element <mx:gi>ata-socket</mx:gi> is unexpected following <mx:gi>memory</mx:gi>, <mx:gi>cooling</mx:gi>, or <mx:gi>expansion-card</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-computer_..._motherboard_..._ata-socket-assembly"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template priority="5" match="computer/motherboard/memory" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::cooling | preceding-sibling::expansion-card)</xsl:with-param>
         <xsl:with-param name="condition"
                         select="exists(preceding-sibling::cooling | preceding-sibling::expansion-card)"/>
         <xsl:with-param name="msg">Element <mx:gi>memory</mx:gi> is unexpected following <mx:gi>cooling</mx:gi> or <mx:gi>expansion-card</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-computer_..._motherboard_..._memory-assembly"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template priority="5"
                 match="computer/motherboard/expansion-card"
                 mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="require-for-computer_..._motherboard_..._expansion-card-assembly"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template priority="5" match="/computer/usb-device" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::prop | preceding-sibling::remarks)</xsl:with-param>
         <xsl:with-param name="condition"
                         select="exists(preceding-sibling::prop | preceding-sibling::remarks)"/>
         <xsl:with-param name="msg">Element <mx:gi>usb-device</mx:gi> is unexpected following <mx:gi>prop</mx:gi> or <mx:gi>remarks</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-computer_..._usb-device-assembly"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template priority="5" match="motherboard/cooling/fan" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.298</xsl:with-param>
         <xsl:with-param name="class">EATI element-appears-too-infrequently</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">empty(following-sibling::fan) and (count(. | preceding-sibling::fan) lt 2)</xsl:with-param>
         <xsl:with-param name="condition"
                         select="empty(following-sibling::fan) and (count(. | preceding-sibling::fan) lt 2)"/>
         <xsl:with-param name="msg">Element <mx:gi>fan</mx:gi> appears too few times: 2 minimum are required.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::fan) gt 12</xsl:with-param>
         <xsl:with-param name="condition" select="count(. | preceding-sibling::fan) gt 12"/>
         <xsl:with-param name="msg">Element <mx:gi>fan</mx:gi> appears too many times: 12 maximum are permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.324</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">empty(preceding-sibling::fan) and exists(../(water))</xsl:with-param>
         <xsl:with-param name="condition"
                         select="empty(preceding-sibling::fan) and exists(../(water))"/>
         <xsl:with-param name="class">VEXC violates-exclusive-choice</xsl:with-param>
         <xsl:with-param name="msg">Element <mx:gi>fan</mx:gi> is unexpected along with <mx:gi>water</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-cooling_..._fan-assembly"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template priority="5" match="motherboard/cooling/water" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::water) gt 1</xsl:with-param>
         <xsl:with-param name="condition" select="count(. | preceding-sibling::water) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>water</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.324</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">empty(preceding-sibling::water) and exists(../(fan))</xsl:with-param>
         <xsl:with-param name="condition"
                         select="empty(preceding-sibling::water) and exists(../(fan))"/>
         <xsl:with-param name="class">VEXC violates-exclusive-choice</xsl:with-param>
         <xsl:with-param name="msg">Element <mx:gi>water</mx:gi> is unexpected along with <mx:gi>fan</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-cooling_..._water-assembly"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template match="motherboard/cpu/product-name/text()" mode="test"/>
   <xsl:template priority="5" match="motherboard/cpu/product-name" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::product-name) gt 1</xsl:with-param>
         <xsl:with-param name="condition"
                         select="count(. | preceding-sibling::product-name) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>product-name</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::cost | preceding-sibling::architecture | preceding-sibling::speed | preceding-sibling::prop | preceding-sibling::remarks)</xsl:with-param>
         <xsl:with-param name="condition"
                         select="exists(preceding-sibling::cost | preceding-sibling::architecture | preceding-sibling::speed | preceding-sibling::prop | preceding-sibling::remarks)"/>
         <xsl:with-param name="msg">Element <mx:gi>product-name</mx:gi> is unexpected following <mx:gi>cost</mx:gi>, <mx:gi>architecture</mx:gi>, <mx:gi>speed</mx:gi>, <mx:gi>prop</mx:gi>, or <mx:gi>remarks</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-product-name-field"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template match="motherboard/cpu/cost/text()" mode="test"/>
   <xsl:template priority="5" match="motherboard/cpu/cost" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::cost) gt 1</xsl:with-param>
         <xsl:with-param name="condition" select="count(. | preceding-sibling::cost) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>cost</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::architecture | preceding-sibling::speed | preceding-sibling::prop | preceding-sibling::remarks)</xsl:with-param>
         <xsl:with-param name="condition"
                         select="exists(preceding-sibling::architecture | preceding-sibling::speed | preceding-sibling::prop | preceding-sibling::remarks)"/>
         <xsl:with-param name="msg">Element <mx:gi>cost</mx:gi> is unexpected following <mx:gi>architecture</mx:gi>, <mx:gi>speed</mx:gi>, <mx:gi>prop</mx:gi>, or <mx:gi>remarks</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-cost-field"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template match="motherboard/ata-socket/product-name/text()" mode="test"/>
   <xsl:template priority="5"
                 match="motherboard/ata-socket/product-name"
                 mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::product-name) gt 1</xsl:with-param>
         <xsl:with-param name="condition"
                         select="count(. | preceding-sibling::product-name) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>product-name</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::cost | preceding-sibling::type | preceding-sibling::prop | preceding-sibling::remarks)</xsl:with-param>
         <xsl:with-param name="condition"
                         select="exists(preceding-sibling::cost | preceding-sibling::type | preceding-sibling::prop | preceding-sibling::remarks)"/>
         <xsl:with-param name="msg">Element <mx:gi>product-name</mx:gi> is unexpected following <mx:gi>cost</mx:gi>, <mx:gi>type</mx:gi>, <mx:gi>prop</mx:gi>, or <mx:gi>remarks</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-product-name-field"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template match="motherboard/ata-socket/cost/text()" mode="test"/>
   <xsl:template priority="5" match="motherboard/ata-socket/cost" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::cost) gt 1</xsl:with-param>
         <xsl:with-param name="condition" select="count(. | preceding-sibling::cost) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>cost</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::type | preceding-sibling::prop | preceding-sibling::remarks)</xsl:with-param>
         <xsl:with-param name="condition"
                         select="exists(preceding-sibling::type | preceding-sibling::prop | preceding-sibling::remarks)"/>
         <xsl:with-param name="msg">Element <mx:gi>cost</mx:gi> is unexpected following <mx:gi>type</mx:gi>, <mx:gi>prop</mx:gi>, or <mx:gi>remarks</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-cost-field"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template match="motherboard/memory/product-name/text()" mode="test"/>
   <xsl:template priority="5" match="motherboard/memory/product-name" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::product-name) gt 1</xsl:with-param>
         <xsl:with-param name="condition"
                         select="count(. | preceding-sibling::product-name) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>product-name</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::cost | preceding-sibling::byte-size | preceding-sibling::prop | preceding-sibling::remarks)</xsl:with-param>
         <xsl:with-param name="condition"
                         select="exists(preceding-sibling::cost | preceding-sibling::byte-size | preceding-sibling::prop | preceding-sibling::remarks)"/>
         <xsl:with-param name="msg">Element <mx:gi>product-name</mx:gi> is unexpected following <mx:gi>cost</mx:gi>, <mx:gi>byte-size</mx:gi>, <mx:gi>prop</mx:gi>, or <mx:gi>remarks</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-product-name-field"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template match="motherboard/memory/cost/text()" mode="test"/>
   <xsl:template priority="5" match="motherboard/memory/cost" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::cost) gt 1</xsl:with-param>
         <xsl:with-param name="condition" select="count(. | preceding-sibling::cost) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>cost</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::byte-size | preceding-sibling::prop | preceding-sibling::remarks)</xsl:with-param>
         <xsl:with-param name="condition"
                         select="exists(preceding-sibling::byte-size | preceding-sibling::prop | preceding-sibling::remarks)"/>
         <xsl:with-param name="msg">Element <mx:gi>cost</mx:gi> is unexpected following <mx:gi>byte-size</mx:gi>, <mx:gi>prop</mx:gi>, or <mx:gi>remarks</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-cost-field"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template match="motherboard/expansion-card/product-name/text()" mode="test"/>
   <xsl:template priority="5"
                 match="motherboard/expansion-card/product-name"
                 mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::product-name) gt 1</xsl:with-param>
         <xsl:with-param name="condition"
                         select="count(. | preceding-sibling::product-name) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>product-name</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::cost | preceding-sibling::type | preceding-sibling::prop | preceding-sibling::remarks)</xsl:with-param>
         <xsl:with-param name="condition"
                         select="exists(preceding-sibling::cost | preceding-sibling::type | preceding-sibling::prop | preceding-sibling::remarks)"/>
         <xsl:with-param name="msg">Element <mx:gi>product-name</mx:gi> is unexpected following <mx:gi>cost</mx:gi>, <mx:gi>type</mx:gi>, <mx:gi>prop</mx:gi>, or <mx:gi>remarks</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-product-name-field"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template match="motherboard/expansion-card/cost/text()" mode="test"/>
   <xsl:template priority="5" match="motherboard/expansion-card/cost" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::cost) gt 1</xsl:with-param>
         <xsl:with-param name="condition" select="count(. | preceding-sibling::cost) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>cost</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::type | preceding-sibling::prop | preceding-sibling::remarks)</xsl:with-param>
         <xsl:with-param name="condition"
                         select="exists(preceding-sibling::type | preceding-sibling::prop | preceding-sibling::remarks)"/>
         <xsl:with-param name="msg">Element <mx:gi>cost</mx:gi> is unexpected following <mx:gi>type</mx:gi>, <mx:gi>prop</mx:gi>, or <mx:gi>remarks</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-cost-field"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template match="computer/usb-device/product-name/text()" mode="test"/>
   <xsl:template priority="5" match="computer/usb-device/product-name" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::product-name) gt 1</xsl:with-param>
         <xsl:with-param name="condition"
                         select="count(. | preceding-sibling::product-name) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>product-name</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::cost | preceding-sibling::prop | preceding-sibling::remarks)</xsl:with-param>
         <xsl:with-param name="condition"
                         select="exists(preceding-sibling::cost | preceding-sibling::prop | preceding-sibling::remarks)"/>
         <xsl:with-param name="msg">Element <mx:gi>product-name</mx:gi> is unexpected following <mx:gi>cost</mx:gi>, <mx:gi>prop</mx:gi>, or <mx:gi>remarks</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-product-name-field"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template match="computer/usb-device/cost/text()" mode="test"/>
   <xsl:template priority="5" match="computer/usb-device/cost" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::cost) gt 1</xsl:with-param>
         <xsl:with-param name="condition" select="count(. | preceding-sibling::cost) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>cost</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::prop | preceding-sibling::remarks)</xsl:with-param>
         <xsl:with-param name="condition"
                         select="exists(preceding-sibling::prop | preceding-sibling::remarks)"/>
         <xsl:with-param name="msg">Element <mx:gi>cost</mx:gi> is unexpected following <mx:gi>prop</mx:gi> or <mx:gi>remarks</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-cost-field"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template match="cpu/prop/remarks/text() | ata-socket/prop/remarks/text() | memory/prop/remarks/text() | expansion-card/prop/remarks/text() | usb-device/prop/remarks/text() | computer/prop/remarks/text()"
                 mode="test"/>
   <xsl:template priority="5"
                 match="cpu/prop/remarks | ata-socket/prop/remarks | memory/prop/remarks | expansion-card/prop/remarks | usb-device/prop/remarks | computer/prop/remarks"
                 mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::remarks) gt 1</xsl:with-param>
         <xsl:with-param name="condition" select="count(. | preceding-sibling::remarks) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>remarks</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-remarks-field"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template match="motherboard/vendor/name/text() | cpu/vendor/name/text() | ata-socket/vendor/name/text() | memory/vendor/name/text() | expansion-card/vendor/name/text() | usb-device/vendor/name/text()"
                 mode="test"/>
   <xsl:template priority="5"
                 match="motherboard/vendor/name | cpu/vendor/name | ata-socket/vendor/name | memory/vendor/name | expansion-card/vendor/name | usb-device/vendor/name"
                 mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::name) gt 1</xsl:with-param>
         <xsl:with-param name="condition" select="count(. | preceding-sibling::name) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>name</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::address | preceding-sibling::website)</xsl:with-param>
         <xsl:with-param name="condition"
                         select="exists(preceding-sibling::address | preceding-sibling::website)"/>
         <xsl:with-param name="msg">Element <mx:gi>name</mx:gi> is unexpected following <mx:gi>address</mx:gi> or <mx:gi>website</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-vendor_..._name-field"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template match="motherboard/vendor/address/text() | cpu/vendor/address/text() | ata-socket/vendor/address/text() | memory/vendor/address/text() | expansion-card/vendor/address/text() | usb-device/vendor/address/text()"
                 mode="test"/>
   <xsl:template priority="5"
                 match="motherboard/vendor/address | cpu/vendor/address | ata-socket/vendor/address | memory/vendor/address | expansion-card/vendor/address | usb-device/vendor/address"
                 mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::address) gt 1</xsl:with-param>
         <xsl:with-param name="condition" select="count(. | preceding-sibling::address) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>address</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::website)</xsl:with-param>
         <xsl:with-param name="condition" select="exists(preceding-sibling::website)"/>
         <xsl:with-param name="msg">Element <mx:gi>address</mx:gi> is unexpected following <mx:gi>website</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-vendor_..._address-field"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template match="motherboard/vendor/website/text() | cpu/vendor/website/text() | ata-socket/vendor/website/text() | memory/vendor/website/text() | expansion-card/vendor/website/text() | usb-device/vendor/website/text()"
                 mode="test"/>
   <xsl:template priority="5"
                 match="motherboard/vendor/website | cpu/vendor/website | ata-socket/vendor/website | memory/vendor/website | expansion-card/vendor/website | usb-device/vendor/website"
                 mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::website) gt 1</xsl:with-param>
         <xsl:with-param name="condition" select="count(. | preceding-sibling::website) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>website</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-vendor_..._website-field"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template match="/computer/build-date/text()" mode="test"/>
   <xsl:template priority="5" match="/computer/build-date" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::build-date) gt 1</xsl:with-param>
         <xsl:with-param name="condition" select="count(. | preceding-sibling::build-date) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>build-date</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::motherboard | preceding-sibling::usb-device | preceding-sibling::prop | preceding-sibling::remarks)</xsl:with-param>
         <xsl:with-param name="condition"
                         select="exists(preceding-sibling::motherboard | preceding-sibling::usb-device | preceding-sibling::prop | preceding-sibling::remarks)"/>
         <xsl:with-param name="msg">Element <mx:gi>build-date</mx:gi> is unexpected following <mx:gi>motherboard</mx:gi>, <mx:gi>usb-device</mx:gi>, <mx:gi>prop</mx:gi>, or <mx:gi>remarks</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-computer_..._build-date-field"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template match="computer/motherboard/type/text()" mode="test"/>
   <xsl:template priority="5" match="computer/motherboard/type" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::type) gt 1</xsl:with-param>
         <xsl:with-param name="condition" select="count(. | preceding-sibling::type) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>type</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::cpu | preceding-sibling::ata-socket | preceding-sibling::memory | preceding-sibling::cooling | preceding-sibling::expansion-card)</xsl:with-param>
         <xsl:with-param name="condition"
                         select="exists(preceding-sibling::cpu | preceding-sibling::ata-socket | preceding-sibling::memory | preceding-sibling::cooling | preceding-sibling::expansion-card)"/>
         <xsl:with-param name="msg">Element <mx:gi>type</mx:gi> is unexpected following <mx:gi>cpu</mx:gi>, <mx:gi>ata-socket</mx:gi>, <mx:gi>memory</mx:gi>, <mx:gi>cooling</mx:gi>, or <mx:gi>expansion-card</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-computer_..._motherboard_..._type-field"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template priority="117"
                 mode="constraint-cascade"
                 match="computer/motherboard/type">
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.526</xsl:with-param>
         <xsl:with-param name="rule-id"/>
         <xsl:with-param name="matching" as="xs:string">computer/motherboard/type</xsl:with-param>
         <xsl:with-param name="class">AVCV value-not-allowed</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">not(.=('at','atx','mini-itx'))</xsl:with-param>
         <xsl:with-param name="condition" select="not(.=('at','atx','mini-itx'))"/>
         <xsl:with-param name="msg" expand-text="true">Value <mx:code>{ string(.) }</mx:code>{ .[not(string(.))] ! ' (empty)' } does not appear among permissible (enumerated) values for this <mx:gi>{ name() }</mx:gi>: <mx:code>at|atx|mini-itx</mx:code>.</xsl:with-param>
         <xsl:with-param name="level" select="'WARNING'"/>
      </xsl:call-template>
      <xsl:next-match/>
   </xsl:template>
   <xsl:template match="motherboard/cpu/architecture/text()" mode="test"/>
   <xsl:template priority="5" match="motherboard/cpu/architecture" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::architecture) gt 1</xsl:with-param>
         <xsl:with-param name="condition"
                         select="count(. | preceding-sibling::architecture) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>architecture</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::speed | preceding-sibling::prop | preceding-sibling::remarks)</xsl:with-param>
         <xsl:with-param name="condition"
                         select="exists(preceding-sibling::speed | preceding-sibling::prop | preceding-sibling::remarks)"/>
         <xsl:with-param name="msg">Element <mx:gi>architecture</mx:gi> is unexpected following <mx:gi>speed</mx:gi>, <mx:gi>prop</mx:gi>, or <mx:gi>remarks</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-computer_..._motherboard_..._cpu_..._architecture-field"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template priority="116"
                 mode="constraint-cascade"
                 match="motherboard/cpu/architecture">
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.526</xsl:with-param>
         <xsl:with-param name="rule-id"/>
         <xsl:with-param name="matching" as="xs:string">motherboard/cpu/architecture</xsl:with-param>
         <xsl:with-param name="class">AVCV value-not-allowed</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">not(.=('x86','x86-64','arm'))</xsl:with-param>
         <xsl:with-param name="condition" select="not(.=('x86','x86-64','arm'))"/>
         <xsl:with-param name="msg" expand-text="true">Value <mx:code>{ string(.) }</mx:code>{ .[not(string(.))] ! ' (empty)' } does not appear among permissible (enumerated) values for this <mx:gi>{ name() }</mx:gi>: <mx:code>x86|x86-64|arm</mx:code>.</xsl:with-param>
         <xsl:with-param name="level" select="'WARNING'"/>
      </xsl:call-template>
      <xsl:next-match/>
   </xsl:template>
   <xsl:template match="motherboard/cpu/speed/text()" mode="test"/>
   <xsl:template priority="5" match="motherboard/cpu/speed" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::speed) gt 1</xsl:with-param>
         <xsl:with-param name="condition" select="count(. | preceding-sibling::speed) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>speed</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::prop | preceding-sibling::remarks)</xsl:with-param>
         <xsl:with-param name="condition"
                         select="exists(preceding-sibling::prop | preceding-sibling::remarks)"/>
         <xsl:with-param name="msg">Element <mx:gi>speed</mx:gi> is unexpected following <mx:gi>prop</mx:gi> or <mx:gi>remarks</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-computer_..._motherboard_..._cpu_..._speed-field"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template priority="115"
                 mode="constraint-cascade"
                 match="motherboard/cpu/speed">
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.561</xsl:with-param>
         <xsl:with-param name="rule-id"/>
         <xsl:with-param name="matching" as="xs:string">motherboard/cpu/speed</xsl:with-param>
         <xsl:with-param name="class">MRCV regex-match-fail</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">not(matches(., '^\d+(?:\.\d+)?(?:MHz|GHz)$'))</xsl:with-param>
         <xsl:with-param name="condition" select="not(matches(., '^\d+(?:\.\d+)?(?:MHz|GHz)$'))"/>
         <xsl:with-param name="msg" expand-text="true">
            <mx:code>{ string(.) }</mx:code>{ string(.)[not(.)] ! ' (empty)' } does not match the regular expression defined for this <mx:gi>{ name() }</mx:gi>: <mx:code>\d+(?:\.\d+)?(?:MHz|GHz)</mx:code>.</xsl:with-param>
      </xsl:call-template>
      <xsl:next-match/>
   </xsl:template>
   <xsl:template match="motherboard/ata-socket/type/text()" mode="test"/>
   <xsl:template priority="5" match="motherboard/ata-socket/type" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::type) gt 1</xsl:with-param>
         <xsl:with-param name="condition" select="count(. | preceding-sibling::type) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>type</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::prop | preceding-sibling::remarks)</xsl:with-param>
         <xsl:with-param name="condition"
                         select="exists(preceding-sibling::prop | preceding-sibling::remarks)"/>
         <xsl:with-param name="msg">Element <mx:gi>type</mx:gi> is unexpected following <mx:gi>prop</mx:gi> or <mx:gi>remarks</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-computer_..._motherboard_..._ata-socket_..._type-field"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template priority="114"
                 mode="constraint-cascade"
                 match="motherboard/ata-socket/type">
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.526</xsl:with-param>
         <xsl:with-param name="rule-id"/>
         <xsl:with-param name="matching" as="xs:string">motherboard/ata-socket/type</xsl:with-param>
         <xsl:with-param name="class">AVCV value-not-allowed</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">not(.=('pata','sata'))</xsl:with-param>
         <xsl:with-param name="condition" select="not(.=('pata','sata'))"/>
         <xsl:with-param name="msg" expand-text="true">Value <mx:code>{ string(.) }</mx:code>{ .[not(string(.))] ! ' (empty)' } does not appear among permissible (enumerated) values for this <mx:gi>{ name() }</mx:gi>: <mx:code>pata|sata</mx:code>.</xsl:with-param>
         <xsl:with-param name="level" select="'WARNING'"/>
      </xsl:call-template>
      <xsl:next-match/>
   </xsl:template>
   <xsl:template match="motherboard/memory/byte-size/text()" mode="test"/>
   <xsl:template priority="5" match="motherboard/memory/byte-size" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::byte-size) gt 1</xsl:with-param>
         <xsl:with-param name="condition" select="count(. | preceding-sibling::byte-size) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>byte-size</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::prop | preceding-sibling::remarks)</xsl:with-param>
         <xsl:with-param name="condition"
                         select="exists(preceding-sibling::prop | preceding-sibling::remarks)"/>
         <xsl:with-param name="msg">Element <mx:gi>byte-size</mx:gi> is unexpected following <mx:gi>prop</mx:gi> or <mx:gi>remarks</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-computer_..._motherboard_..._memory_..._byte-size-field"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template match="motherboard/expansion-card/type/text()" mode="test"/>
   <xsl:template priority="5" match="motherboard/expansion-card/type" mode="test">
      <xsl:apply-templates select="@*" mode="test"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.309</xsl:with-param>
         <xsl:with-param name="class">EATO element-appears-too-often</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">count(. | preceding-sibling::type) gt 1</xsl:with-param>
         <xsl:with-param name="condition" select="count(. | preceding-sibling::type) gt 1"/>
         <xsl:with-param name="msg">Element <mx:gi>type</mx:gi> appears too many times: 1 maximum is permitted.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.352</xsl:with-param>
         <xsl:with-param name="class">EOOO element-out-of-order</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">exists(preceding-sibling::prop | preceding-sibling::remarks)</xsl:with-param>
         <xsl:with-param name="condition"
                         select="exists(preceding-sibling::prop | preceding-sibling::remarks)"/>
         <xsl:with-param name="msg">Element <mx:gi>type</mx:gi> is unexpected following <mx:gi>prop</mx:gi> or <mx:gi>remarks</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="require-for-computer_..._motherboard_..._expansion-card_..._type-field"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template priority="113"
                 mode="constraint-cascade"
                 match="motherboard/expansion-card/type">
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.526</xsl:with-param>
         <xsl:with-param name="rule-id"/>
         <xsl:with-param name="matching" as="xs:string">motherboard/expansion-card/type</xsl:with-param>
         <xsl:with-param name="class">AVCV value-not-allowed</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">not(.=('pci','pcie'))</xsl:with-param>
         <xsl:with-param name="condition" select="not(.=('pci','pcie'))"/>
         <xsl:with-param name="msg" expand-text="true">Value <mx:code>{ string(.) }</mx:code>{ .[not(string(.))] ! ' (empty)' } does not appear among permissible (enumerated) values for this <mx:gi>{ name() }</mx:gi>: <mx:code>pci|pcie</mx:code>.</xsl:with-param>
         <xsl:with-param name="level" select="'ERROR'"/>
      </xsl:call-template>
      <xsl:next-match/>
   </xsl:template>
   <xsl:template match="/computer/@serial-number" mode="test">
      <xsl:call-template name="require-for-serial-number-flag"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template priority="101"
                 mode="constraint-cascade"
                 match="/computer/@serial-number">
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.561</xsl:with-param>
         <xsl:with-param name="rule-id"/>
         <xsl:with-param name="matching" as="xs:string">/computer/@serial-number</xsl:with-param>
         <xsl:with-param name="class">MRCV regex-match-fail</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">not(matches(., '^^\S+$$'))</xsl:with-param>
         <xsl:with-param name="condition" select="not(matches(., '^^\S+$$'))"/>
         <xsl:with-param name="msg" expand-text="true">
            <mx:code>{ string(.) }</mx:code>{ string(.)[not(.)] ! ' (empty)' } does not match the regular expression defined for this <mx:gi>{ name() }</mx:gi>: <mx:code>^\S+$</mx:code>.</xsl:with-param>
      </xsl:call-template>
      <xsl:next-match/>
   </xsl:template>
   <xsl:template match="computer/motherboard/@serial-number" mode="test">
      <xsl:call-template name="require-for-serial-number-flag"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template priority="101"
                 mode="constraint-cascade"
                 match="computer/motherboard/@serial-number">
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.561</xsl:with-param>
         <xsl:with-param name="rule-id"/>
         <xsl:with-param name="matching" as="xs:string">computer/motherboard/@serial-number</xsl:with-param>
         <xsl:with-param name="class">MRCV regex-match-fail</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">not(matches(., '^^\S+$$'))</xsl:with-param>
         <xsl:with-param name="condition" select="not(matches(., '^^\S+$$'))"/>
         <xsl:with-param name="msg" expand-text="true">
            <mx:code>{ string(.) }</mx:code>{ string(.)[not(.)] ! ' (empty)' } does not match the regular expression defined for this <mx:gi>{ name() }</mx:gi>: <mx:code>^\S+$</mx:code>.</xsl:with-param>
      </xsl:call-template>
      <xsl:next-match/>
   </xsl:template>
   <xsl:template match="motherboard/ata-socket/@serial-number" mode="test">
      <xsl:call-template name="require-for-serial-number-flag"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template priority="101"
                 mode="constraint-cascade"
                 match="motherboard/ata-socket/@serial-number">
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.561</xsl:with-param>
         <xsl:with-param name="rule-id"/>
         <xsl:with-param name="matching" as="xs:string">motherboard/ata-socket/@serial-number</xsl:with-param>
         <xsl:with-param name="class">MRCV regex-match-fail</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">not(matches(., '^^\S+$$'))</xsl:with-param>
         <xsl:with-param name="condition" select="not(matches(., '^^\S+$$'))"/>
         <xsl:with-param name="msg" expand-text="true">
            <mx:code>{ string(.) }</mx:code>{ string(.)[not(.)] ! ' (empty)' } does not match the regular expression defined for this <mx:gi>{ name() }</mx:gi>: <mx:code>^\S+$</mx:code>.</xsl:with-param>
      </xsl:call-template>
      <xsl:next-match/>
   </xsl:template>
   <xsl:template match="motherboard/memory/@serial-number" mode="test">
      <xsl:call-template name="require-for-serial-number-flag"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template priority="101"
                 mode="constraint-cascade"
                 match="motherboard/memory/@serial-number">
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.561</xsl:with-param>
         <xsl:with-param name="rule-id"/>
         <xsl:with-param name="matching" as="xs:string">motherboard/memory/@serial-number</xsl:with-param>
         <xsl:with-param name="class">MRCV regex-match-fail</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">not(matches(., '^^\S+$$'))</xsl:with-param>
         <xsl:with-param name="condition" select="not(matches(., '^^\S+$$'))"/>
         <xsl:with-param name="msg" expand-text="true">
            <mx:code>{ string(.) }</mx:code>{ string(.)[not(.)] ! ' (empty)' } does not match the regular expression defined for this <mx:gi>{ name() }</mx:gi>: <mx:code>^\S+$</mx:code>.</xsl:with-param>
      </xsl:call-template>
      <xsl:next-match/>
   </xsl:template>
   <xsl:template match="motherboard/expansion-card/@serial-number" mode="test">
      <xsl:call-template name="require-for-serial-number-flag"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template priority="101"
                 mode="constraint-cascade"
                 match="motherboard/expansion-card/@serial-number">
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.561</xsl:with-param>
         <xsl:with-param name="rule-id"/>
         <xsl:with-param name="matching" as="xs:string">motherboard/expansion-card/@serial-number</xsl:with-param>
         <xsl:with-param name="class">MRCV regex-match-fail</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">not(matches(., '^^\S+$$'))</xsl:with-param>
         <xsl:with-param name="condition" select="not(matches(., '^^\S+$$'))"/>
         <xsl:with-param name="msg" expand-text="true">
            <mx:code>{ string(.) }</mx:code>{ string(.)[not(.)] ! ' (empty)' } does not match the regular expression defined for this <mx:gi>{ name() }</mx:gi>: <mx:code>^\S+$</mx:code>.</xsl:with-param>
      </xsl:call-template>
      <xsl:next-match/>
   </xsl:template>
   <xsl:template match="motherboard/cooling/@serial-number" mode="test">
      <xsl:call-template name="require-for-serial-number-flag"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template priority="101"
                 mode="constraint-cascade"
                 match="motherboard/cooling/@serial-number">
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.561</xsl:with-param>
         <xsl:with-param name="rule-id"/>
         <xsl:with-param name="matching" as="xs:string">motherboard/cooling/@serial-number</xsl:with-param>
         <xsl:with-param name="class">MRCV regex-match-fail</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">not(matches(., '^^\S+$$'))</xsl:with-param>
         <xsl:with-param name="condition" select="not(matches(., '^^\S+$$'))"/>
         <xsl:with-param name="msg" expand-text="true">
            <mx:code>{ string(.) }</mx:code>{ string(.)[not(.)] ! ' (empty)' } does not match the regular expression defined for this <mx:gi>{ name() }</mx:gi>: <mx:code>^\S+$</mx:code>.</xsl:with-param>
      </xsl:call-template>
      <xsl:next-match/>
   </xsl:template>
   <xsl:template match="motherboard/vendor/@id | cpu/vendor/@id | ata-socket/vendor/@id | memory/vendor/@id | expansion-card/vendor/@id | usb-device/vendor/@id"
                 mode="test">
      <xsl:call-template name="require-for-vendor_..._id-flag"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template match="/computer/@id" mode="test">
      <xsl:call-template name="require-for-computer_..._id-flag"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template match="motherboard/ata-socket/@slot-no" mode="test">
      <xsl:call-template name="require-for-computer_..._motherboard_..._ata-socket_..._slot-no-flag"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template match="motherboard/expansion-card/@socket-no" mode="test">
      <xsl:call-template name="require-for-computer_..._motherboard_..._expansion-card_..._socket-no-flag"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template match="computer/usb-device/@uuid" mode="test">
      <xsl:call-template name="require-for-computer_..._usb-device_..._uuid-flag"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template match="cpu/cost/@currency | ata-socket/cost/@currency | memory/cost/@currency | expansion-card/cost/@currency | usb-device/cost/@currency"
                 mode="test">
      <xsl:call-template name="require-for-cost_..._currency-flag"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template match="cpu/prop/@name | ata-socket/prop/@name | memory/prop/@name | expansion-card/prop/@name | usb-device/prop/@name | computer/prop/@name"
                 mode="test">
      <xsl:call-template name="require-for-property_..._name-flag"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template match="cpu/prop/@uuid | ata-socket/prop/@uuid | memory/prop/@uuid | expansion-card/prop/@uuid | usb-device/prop/@uuid | computer/prop/@uuid"
                 mode="test">
      <xsl:call-template name="require-for-property_..._uuid-flag"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template match="cpu/prop/@ns | ata-socket/prop/@ns | memory/prop/@ns | expansion-card/prop/@ns | usb-device/prop/@ns | computer/prop/@ns"
                 mode="test">
      <xsl:call-template name="require-for-property_..._ns-flag"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template match="cpu/prop/@value | ata-socket/prop/@value | memory/prop/@value | expansion-card/prop/@value | usb-device/prop/@value | computer/prop/@value"
                 mode="test">
      <xsl:call-template name="require-for-property_..._value-flag"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template match="cpu/prop/@class | ata-socket/prop/@class | memory/prop/@class | expansion-card/prop/@class | usb-device/prop/@class | computer/prop/@class"
                 mode="test">
      <xsl:call-template name="require-for-property_..._class-flag"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template match="cpu/prop/@group | ata-socket/prop/@group | memory/prop/@group | expansion-card/prop/@group | usb-device/prop/@group | computer/prop/@group"
                 mode="test">
      <xsl:call-template name="require-for-property_..._group-flag"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <xsl:template match="cooling/water/@illuminated" mode="test">
      <xsl:call-template name="require-for-cooling_..._water_..._illuminated-flag"/>
      <xsl:apply-templates mode="constraint-cascade" select="."/>
   </xsl:template>
   <!-- .     .     .     .     .     .     .     .     .     .     .     .     .     .     .     .     . -->
   <!--     Fallbacks for occurrences of known elements and attributes, except out of
               context     -->
   <!-- .     .     .     .     .     .     .     .     .     .     .     .     .     .     .     .     . -->
   <xsl:template mode="test"
                 match="name | address | website | computer | build-date | motherboard | vendor | type | cpu | product-name | cost | architecture | speed | prop | ata-socket | memory | byte-size | cooling | expansion-card | usb-device | remarks | fan | water">
      <xsl:call-template name="notice">
         <xsl:with-param name="cf" as="xs:string">gix.81</xsl:with-param>
         <xsl:with-param name="class">EOOP element-out-of-place</xsl:with-param>
         <xsl:with-param name="msg" expand-text="true">Element <mx:gi>{ name() }</mx:gi> is not permitted here.</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <xsl:template mode="test"
                 match="@id | @serial-number | @slot-no | @socket-no | @uuid | @currency | @name | @ns | @value | @class | @group | @illuminated">
      <xsl:call-template name="notice">
         <xsl:with-param name="cf" as="xs:string">gix.90</xsl:with-param>
         <xsl:with-param name="class">AOOP attribute-out-of-place</xsl:with-param>
         <xsl:with-param name="msg" expand-text="true">Attribute <mx:gi>@{ name() }</mx:gi> is not permitted here.</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <!-- .     .     .     .     .     .     .     .     .     .     .     .     .     .     .     .     . -->
   <!--     Definitions - a named template for each     -->
   <!-- .     .     .     .     .     .     .     .     .     .     .     .     .     .     .     .     . -->
   <xsl:template name="require-for-vendor-assembly">
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.646</xsl:with-param>
         <xsl:with-param name="class">MRQA missing-required-attribute</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">empty(@id)</xsl:with-param>
         <xsl:with-param name="condition" select="empty(@id)"/>
         <xsl:with-param name="msg" expand-text="true">Element <mx:gi>{ name() }</mx:gi> requires attribute <mx:gi>@id</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.419</xsl:with-param>
         <xsl:with-param name="class">MRQC missing-required-contents</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">empty(name)</xsl:with-param>
         <xsl:with-param name="condition" select="empty(name)"/>
         <xsl:with-param name="msg" expand-text="true">Element <mx:gi>{ name() }</mx:gi> requires element <mx:gi>name</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.419</xsl:with-param>
         <xsl:with-param name="class">MRQC missing-required-contents</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">empty(address)</xsl:with-param>
         <xsl:with-param name="condition" select="empty(address)"/>
         <xsl:with-param name="msg" expand-text="true">Element <mx:gi>{ name() }</mx:gi> requires element <mx:gi>address</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.419</xsl:with-param>
         <xsl:with-param name="class">MRQC missing-required-contents</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">empty(website)</xsl:with-param>
         <xsl:with-param name="condition" select="empty(website)"/>
         <xsl:with-param name="msg" expand-text="true">Element <mx:gi>{ name() }</mx:gi> requires element <mx:gi>website</mx:gi>.</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <xsl:template name="require-for-vendor_..._id-flag"/>
   <xsl:template name="require-for-vendor_..._name-field"/>
   <xsl:template name="require-for-vendor_..._address-field"/>
   <xsl:template name="require-for-vendor_..._website-field">
      <xsl:call-template name="check-uri-datatype"/>
   </xsl:template>
   <xsl:template name="require-for-product-name-field"/>
   <xsl:template name="require-for-computer-assembly">
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.646</xsl:with-param>
         <xsl:with-param name="class">MRQA missing-required-attribute</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">empty(@id)</xsl:with-param>
         <xsl:with-param name="condition" select="empty(@id)"/>
         <xsl:with-param name="msg" expand-text="true">Element <mx:gi>{ name() }</mx:gi> requires attribute <mx:gi>@id</mx:gi>.</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <xsl:template name="require-for-computer_..._id-flag"/>
   <xsl:template name="require-for-computer_..._build-date-field">
      <xsl:call-template name="check-date-time-with-timezone-datatype"/>
   </xsl:template>
   <xsl:template name="require-for-computer_..._motherboard-assembly">
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.419</xsl:with-param>
         <xsl:with-param name="class">MRQC missing-required-contents</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">empty(type)</xsl:with-param>
         <xsl:with-param name="condition" select="empty(type)"/>
         <xsl:with-param name="msg" expand-text="true">Element <mx:gi>{ name() }</mx:gi> requires element <mx:gi>type</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.419</xsl:with-param>
         <xsl:with-param name="class">MRQC missing-required-contents</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">empty(memory)</xsl:with-param>
         <xsl:with-param name="condition" select="empty(memory)"/>
         <xsl:with-param name="msg" expand-text="true">Element <mx:gi>{ name() }</mx:gi> requires element <mx:gi>memory</mx:gi>.</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <xsl:template name="require-for-computer_..._motherboard_..._type-field"/>
   <xsl:template name="require-for-computer_..._motherboard_..._cpu-assembly">
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.419</xsl:with-param>
         <xsl:with-param name="class">MRQC missing-required-contents</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">empty(product-name)</xsl:with-param>
         <xsl:with-param name="condition" select="empty(product-name)"/>
         <xsl:with-param name="msg" expand-text="true">Element <mx:gi>{ name() }</mx:gi> requires element <mx:gi>product-name</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.419</xsl:with-param>
         <xsl:with-param name="class">MRQC missing-required-contents</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">empty(architecture)</xsl:with-param>
         <xsl:with-param name="condition" select="empty(architecture)"/>
         <xsl:with-param name="msg" expand-text="true">Element <mx:gi>{ name() }</mx:gi> requires element <mx:gi>architecture</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.419</xsl:with-param>
         <xsl:with-param name="class">MRQC missing-required-contents</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">empty(speed)</xsl:with-param>
         <xsl:with-param name="condition" select="empty(speed)"/>
         <xsl:with-param name="msg" expand-text="true">Element <mx:gi>{ name() }</mx:gi> requires element <mx:gi>speed</mx:gi>.</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <xsl:template name="require-for-computer_..._motherboard_..._cpu_..._architecture-field"/>
   <xsl:template name="require-for-computer_..._motherboard_..._cpu_..._speed-field"/>
   <xsl:template name="require-for-computer_..._motherboard_..._ata-socket-assembly">
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.646</xsl:with-param>
         <xsl:with-param name="class">MRQA missing-required-attribute</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">empty(@slot-no)</xsl:with-param>
         <xsl:with-param name="condition" select="empty(@slot-no)"/>
         <xsl:with-param name="msg" expand-text="true">Element <mx:gi>{ name() }</mx:gi> requires attribute <mx:gi>@slot-no</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.419</xsl:with-param>
         <xsl:with-param name="class">MRQC missing-required-contents</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">empty(product-name)</xsl:with-param>
         <xsl:with-param name="condition" select="empty(product-name)"/>
         <xsl:with-param name="msg" expand-text="true">Element <mx:gi>{ name() }</mx:gi> requires element <mx:gi>product-name</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.419</xsl:with-param>
         <xsl:with-param name="class">MRQC missing-required-contents</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">empty(type)</xsl:with-param>
         <xsl:with-param name="condition" select="empty(type)"/>
         <xsl:with-param name="msg" expand-text="true">Element <mx:gi>{ name() }</mx:gi> requires element <mx:gi>type</mx:gi>.</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <xsl:template name="require-for-computer_..._motherboard_..._ata-socket_..._slot-no-flag">
      <xsl:call-template name="check-non-negative-integer-datatype"/>
   </xsl:template>
   <xsl:template name="require-for-computer_..._motherboard_..._ata-socket_..._type-field"/>
   <xsl:template name="require-for-computer_..._motherboard_..._memory-assembly">
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.419</xsl:with-param>
         <xsl:with-param name="class">MRQC missing-required-contents</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">empty(product-name)</xsl:with-param>
         <xsl:with-param name="condition" select="empty(product-name)"/>
         <xsl:with-param name="msg" expand-text="true">Element <mx:gi>{ name() }</mx:gi> requires element <mx:gi>product-name</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.419</xsl:with-param>
         <xsl:with-param name="class">MRQC missing-required-contents</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">empty(byte-size)</xsl:with-param>
         <xsl:with-param name="condition" select="empty(byte-size)"/>
         <xsl:with-param name="msg" expand-text="true">Element <mx:gi>{ name() }</mx:gi> requires element <mx:gi>byte-size</mx:gi>.</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <xsl:template name="require-for-computer_..._motherboard_..._memory_..._byte-size-field">
      <xsl:call-template name="check-positive-integer-datatype"/>
   </xsl:template>
   <xsl:template name="require-for-computer_..._motherboard_..._expansion-card-assembly">
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.646</xsl:with-param>
         <xsl:with-param name="class">MRQA missing-required-attribute</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">empty(@socket-no)</xsl:with-param>
         <xsl:with-param name="condition" select="empty(@socket-no)"/>
         <xsl:with-param name="msg" expand-text="true">Element <mx:gi>{ name() }</mx:gi> requires attribute <mx:gi>@socket-no</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.419</xsl:with-param>
         <xsl:with-param name="class">MRQC missing-required-contents</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">empty(product-name)</xsl:with-param>
         <xsl:with-param name="condition" select="empty(product-name)"/>
         <xsl:with-param name="msg" expand-text="true">Element <mx:gi>{ name() }</mx:gi> requires element <mx:gi>product-name</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.419</xsl:with-param>
         <xsl:with-param name="class">MRQC missing-required-contents</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">empty(type)</xsl:with-param>
         <xsl:with-param name="condition" select="empty(type)"/>
         <xsl:with-param name="msg" expand-text="true">Element <mx:gi>{ name() }</mx:gi> requires element <mx:gi>type</mx:gi>.</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <xsl:template name="require-for-computer_..._motherboard_..._expansion-card_..._socket-no-flag"/>
   <xsl:template name="require-for-computer_..._motherboard_..._expansion-card_..._type-field"/>
   <xsl:template name="require-for-computer_..._usb-device-assembly">
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.419</xsl:with-param>
         <xsl:with-param name="class">MRQC missing-required-contents</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">empty(product-name)</xsl:with-param>
         <xsl:with-param name="condition" select="empty(product-name)"/>
         <xsl:with-param name="msg" expand-text="true">Element <mx:gi>{ name() }</mx:gi> requires element <mx:gi>product-name</mx:gi>.</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <xsl:template name="require-for-computer_..._usb-device_..._uuid-flag">
      <xsl:call-template name="check-uuid-datatype"/>
   </xsl:template>
   <xsl:template name="require-for-cost-field">
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.646</xsl:with-param>
         <xsl:with-param name="class">MRQA missing-required-attribute</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">empty(@currency)</xsl:with-param>
         <xsl:with-param name="condition" select="empty(@currency)"/>
         <xsl:with-param name="msg" expand-text="true">Element <mx:gi>{ name() }</mx:gi> requires attribute <mx:gi>@currency</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="check-decimal-datatype"/>
   </xsl:template>
   <xsl:template name="require-for-cost_..._currency-flag"/>
   <xsl:template match="cpu/remarks/node() | ata-socket/remarks/node() | memory/remarks/node() | expansion-card/remarks/node() | usb-device/remarks/node() | computer/remarks/node() | prop/remarks/node()"
                 priority="5"
                 mode="validate"/>
   <xsl:template name="require-for-remarks-field">
      <xsl:call-template name="check-markup-multiline-datatype"/>
   </xsl:template>
   <xsl:template name="require-for-property-assembly">
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.646</xsl:with-param>
         <xsl:with-param name="class">MRQA missing-required-attribute</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">empty(@name)</xsl:with-param>
         <xsl:with-param name="condition" select="empty(@name)"/>
         <xsl:with-param name="msg" expand-text="true">Element <mx:gi>{ name() }</mx:gi> requires attribute <mx:gi>@name</mx:gi>.</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.646</xsl:with-param>
         <xsl:with-param name="class">MRQA missing-required-attribute</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">empty(@value)</xsl:with-param>
         <xsl:with-param name="condition" select="empty(@value)"/>
         <xsl:with-param name="msg" expand-text="true">Element <mx:gi>{ name() }</mx:gi> requires attribute <mx:gi>@value</mx:gi>.</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <xsl:template name="require-for-property_..._name-flag">
      <xsl:call-template name="check-token-datatype"/>
   </xsl:template>
   <xsl:template name="require-for-property_..._uuid-flag">
      <xsl:call-template name="check-uuid-datatype"/>
   </xsl:template>
   <xsl:template name="require-for-property_..._ns-flag">
      <xsl:call-template name="check-uri-datatype"/>
   </xsl:template>
   <xsl:template name="require-for-property_..._value-flag"/>
   <xsl:template name="require-for-property_..._class-flag">
      <xsl:call-template name="check-token-datatype"/>
   </xsl:template>
   <xsl:template name="require-for-property_..._group-flag">
      <xsl:call-template name="check-token-datatype"/>
   </xsl:template>
   <xsl:template name="require-for-serial-number-flag"/>
   <xsl:template name="require-for-cooling-assembly">
      <xsl:call-template name="notice">
         <xsl:with-param name="cf">gix.419</xsl:with-param>
         <xsl:with-param name="class">MRQC missing-required-contents</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">empty(fan|water)</xsl:with-param>
         <xsl:with-param name="condition" select="empty(fan|water)"/>
         <xsl:with-param name="msg" expand-text="true">Element <mx:gi>{ name() }</mx:gi> requires element <mx:gi>fan|water</mx:gi>.</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <xsl:template name="require-for-cooling_..._fan-assembly"/>
   <xsl:template name="require-for-cooling_..._water-assembly"/>
   <xsl:template name="require-for-cooling_..._water_..._illuminated-flag">
      <xsl:call-template name="check-boolean-datatype"/>
   </xsl:template>
   <!-- .     .     .     .     .     .     .     .     .     .     .     .     .     .     .     .     . -->
   <!--     Datatypes - a named template for each occurring     -->
   <!-- .     .     .     .     .     .     .     .     .     .     .     .     .     .     .     .     . -->
   <xsl:template name="check-string-datatype">
      <xsl:param name="rule-id" as="xs:string*" select="()"/>
      <xsl:param name="class" as="xs:string">VDSX violates-datatype-syntax</xsl:param>
      <xsl:param name="matching" as="xs:string?" select="()"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf" as="xs:string">gix.121</xsl:with-param>
         <xsl:with-param name="rule-id" as="xs:string*" select="$rule-id"/>
         <xsl:with-param name="matching"
                         as="xs:string"
                         select="($matching[matches(.,'\S')],'*')[1]"/>
         <xsl:with-param name="class" as="xs:string" expand-text="true">{ $class }</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">not(string(.) castable as xs:string and matches(.,'^\S(.*\S)?$'))</xsl:with-param>
         <xsl:with-param name="condition"
                         select="not(string(.) castable as xs:string and matches(.,'^\S(.*\S)?$'))"/>
         <xsl:with-param name="msg" expand-text="true">Value <mx:code>{ string(.) }</mx:code> of { if (self::element()) then 'element' else 'attribute' } <mx:gi>{ self::attribute()/'@' }{ name(.) }</mx:gi> does not conform to <mx:code>string</mx:code> datatype.</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <xsl:template name="check-uri-datatype">
      <xsl:param name="rule-id" as="xs:string*" select="()"/>
      <xsl:param name="class" as="xs:string">VDSX violates-datatype-syntax</xsl:param>
      <xsl:param name="matching" as="xs:string?" select="()"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf" as="xs:string">gix.121</xsl:with-param>
         <xsl:with-param name="rule-id" as="xs:string*" select="$rule-id"/>
         <xsl:with-param name="matching"
                         as="xs:string"
                         select="($matching[matches(.,'\S')],'*')[1]"/>
         <xsl:with-param name="class" as="xs:string" expand-text="true">{ $class }</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">not(string(.) castable as xs:anyURI and matches(.,'^[a-zA-Z][a-zA-Z0-9+\-.]+:.*\S$'))</xsl:with-param>
         <xsl:with-param name="condition"
                         select="not(string(.) castable as xs:anyURI and matches(.,'^[a-zA-Z][a-zA-Z0-9+\-.]+:.*\S$'))"/>
         <xsl:with-param name="msg" expand-text="true">Value <mx:code>{ string(.) }</mx:code> of { if (self::element()) then 'element' else 'attribute' } <mx:gi>{ self::attribute()/'@' }{ name(.) }</mx:gi> does not conform to <mx:code>uri</mx:code> datatype.</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <xsl:template name="check-date-time-with-timezone-datatype">
      <xsl:param name="rule-id" as="xs:string*" select="()"/>
      <xsl:param name="class" as="xs:string">VDSX violates-datatype-syntax</xsl:param>
      <xsl:param name="matching" as="xs:string?" select="()"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf" as="xs:string">gix.121</xsl:with-param>
         <xsl:with-param name="rule-id" as="xs:string*" select="$rule-id"/>
         <xsl:with-param name="matching"
                         as="xs:string"
                         select="($matching[matches(.,'\S')],'*')[1]"/>
         <xsl:with-param name="class" as="xs:string" expand-text="true">{ $class }</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">not(string(.) castable as xs:dateTime and matches(.,'^(((2000|2400|2800|(19|2[0-9](0[48]|[2468][048]|[13579][26])))-02-29)|(((19|2[0-9])[0-9]{2})-02-(0[1-9]|1[0-9]|2[0-8]))|(((19|2[0-9])[0-9]{2})-(0[13578]|10|12)-(0[1-9]|[12][0-9]|3[01]))|(((19|2[0-9])[0-9]{2})-(0[469]|11)-(0[1-9]|[12][0-9]|30)))T(2[0-3]|[01][0-9]):([0-5][0-9]):([0-5][0-9])(\.[0-9]+)?(Z|(-((0[0-9]|1[0-2]):00|0[39]:30)|\+((0[0-9]|1[0-4]):00|(0[34569]|10):30|(0[58]|12):45)))$') and matches(.,'^(((2000|2400|2800|(19|2[0-9](0[48]|[2468][048]|[13579][26])))-02-29)|(((19|2[0-9])[0-9]{2})-02-(0[1-9]|1[0-9]|2[0-8]))|(((19|2[0-9])[0-9]{2})-(0[13578]|10|12)-(0[1-9]|[12][0-9]|3[01]))|(((19|2[0-9])[0-9]{2})-(0[469]|11)-(0[1-9]|[12][0-9]|30)))T(2[0-3]|[01][0-9]):([0-5][0-9]):([0-5][0-9])(\.[0-9]+)?(Z|(-((0[0-9]|1[0-2]):00|0[39]:30)|\+((0[0-9]|1[0-4]):00|(0[34569]|10):30|(0[58]|12):45)))?$'))</xsl:with-param>
         <xsl:with-param name="condition"
                         select="not(string(.) castable as xs:dateTime and matches(.,'^(((2000|2400|2800|(19|2[0-9](0[48]|[2468][048]|[13579][26])))-02-29)|(((19|2[0-9])[0-9]{2})-02-(0[1-9]|1[0-9]|2[0-8]))|(((19|2[0-9])[0-9]{2})-(0[13578]|10|12)-(0[1-9]|[12][0-9]|3[01]))|(((19|2[0-9])[0-9]{2})-(0[469]|11)-(0[1-9]|[12][0-9]|30)))T(2[0-3]|[01][0-9]):([0-5][0-9]):([0-5][0-9])(\.[0-9]+)?(Z|(-((0[0-9]|1[0-2]):00|0[39]:30)|\+((0[0-9]|1[0-4]):00|(0[34569]|10):30|(0[58]|12):45)))$') and matches(.,'^(((2000|2400|2800|(19|2[0-9](0[48]|[2468][048]|[13579][26])))-02-29)|(((19|2[0-9])[0-9]{2})-02-(0[1-9]|1[0-9]|2[0-8]))|(((19|2[0-9])[0-9]{2})-(0[13578]|10|12)-(0[1-9]|[12][0-9]|3[01]))|(((19|2[0-9])[0-9]{2})-(0[469]|11)-(0[1-9]|[12][0-9]|30)))T(2[0-3]|[01][0-9]):([0-5][0-9]):([0-5][0-9])(\.[0-9]+)?(Z|(-((0[0-9]|1[0-2]):00|0[39]:30)|\+((0[0-9]|1[0-4]):00|(0[34569]|10):30|(0[58]|12):45)))?$'))"/>
         <xsl:with-param name="msg" expand-text="true">Value <mx:code>{ string(.) }</mx:code> of { if (self::element()) then 'element' else 'attribute' } <mx:gi>{ self::attribute()/'@' }{ name(.) }</mx:gi> does not conform to <mx:code>date-time-with-timezone</mx:code> datatype.</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <xsl:template name="check-non-negative-integer-datatype">
      <xsl:param name="rule-id" as="xs:string*" select="()"/>
      <xsl:param name="class" as="xs:string">VDSX violates-datatype-syntax</xsl:param>
      <xsl:param name="matching" as="xs:string?" select="()"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf" as="xs:string">gix.121</xsl:with-param>
         <xsl:with-param name="rule-id" as="xs:string*" select="$rule-id"/>
         <xsl:with-param name="matching"
                         as="xs:string"
                         select="($matching[matches(.,'\S')],'*')[1]"/>
         <xsl:with-param name="class" as="xs:string" expand-text="true">{ $class }</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">not(string(.) castable as xs:nonNegativeInteger and matches(.,'^\S(.*\S)?$'))</xsl:with-param>
         <xsl:with-param name="condition"
                         select="not(string(.) castable as xs:nonNegativeInteger and matches(.,'^\S(.*\S)?$'))"/>
         <xsl:with-param name="msg" expand-text="true">Value <mx:code>{ string(.) }</mx:code> of { if (self::element()) then 'element' else 'attribute' } <mx:gi>{ self::attribute()/'@' }{ name(.) }</mx:gi> does not conform to <mx:code>non-negative-integer</mx:code> datatype.</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <xsl:template name="check-positive-integer-datatype">
      <xsl:param name="rule-id" as="xs:string*" select="()"/>
      <xsl:param name="class" as="xs:string">VDSX violates-datatype-syntax</xsl:param>
      <xsl:param name="matching" as="xs:string?" select="()"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf" as="xs:string">gix.121</xsl:with-param>
         <xsl:with-param name="rule-id" as="xs:string*" select="$rule-id"/>
         <xsl:with-param name="matching"
                         as="xs:string"
                         select="($matching[matches(.,'\S')],'*')[1]"/>
         <xsl:with-param name="class" as="xs:string" expand-text="true">{ $class }</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">not(string(.) castable as xs:positiveInteger and matches(.,'^\S(.*\S)?$'))</xsl:with-param>
         <xsl:with-param name="condition"
                         select="not(string(.) castable as xs:positiveInteger and matches(.,'^\S(.*\S)?$'))"/>
         <xsl:with-param name="msg" expand-text="true">Value <mx:code>{ string(.) }</mx:code> of { if (self::element()) then 'element' else 'attribute' } <mx:gi>{ self::attribute()/'@' }{ name(.) }</mx:gi> does not conform to <mx:code>positive-integer</mx:code> datatype.</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <xsl:template name="check-uuid-datatype">
      <xsl:param name="rule-id" as="xs:string*" select="()"/>
      <xsl:param name="class" as="xs:string">VDSX violates-datatype-syntax</xsl:param>
      <xsl:param name="matching" as="xs:string?" select="()"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf" as="xs:string">gix.121</xsl:with-param>
         <xsl:with-param name="rule-id" as="xs:string*" select="$rule-id"/>
         <xsl:with-param name="matching"
                         as="xs:string"
                         select="($matching[matches(.,'\S')],'*')[1]"/>
         <xsl:with-param name="class" as="xs:string" expand-text="true">{ $class }</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">not(string(.) castable as xs:string and matches(.,'^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[45][0-9A-Fa-f]{3}-[89ABab][0-9A-Fa-f]{3}-[0-9A-Fa-f]{12}$') and matches(.,'^\S(.*\S)?$'))</xsl:with-param>
         <xsl:with-param name="condition"
                         select="not(string(.) castable as xs:string and matches(.,'^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[45][0-9A-Fa-f]{3}-[89ABab][0-9A-Fa-f]{3}-[0-9A-Fa-f]{12}$') and matches(.,'^\S(.*\S)?$'))"/>
         <xsl:with-param name="msg" expand-text="true">Value <mx:code>{ string(.) }</mx:code> of { if (self::element()) then 'element' else 'attribute' } <mx:gi>{ self::attribute()/'@' }{ name(.) }</mx:gi> does not conform to <mx:code>uuid</mx:code> datatype.</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <xsl:template name="check-decimal-datatype">
      <xsl:param name="rule-id" as="xs:string*" select="()"/>
      <xsl:param name="class" as="xs:string">VDSX violates-datatype-syntax</xsl:param>
      <xsl:param name="matching" as="xs:string?" select="()"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf" as="xs:string">gix.121</xsl:with-param>
         <xsl:with-param name="rule-id" as="xs:string*" select="$rule-id"/>
         <xsl:with-param name="matching"
                         as="xs:string"
                         select="($matching[matches(.,'\S')],'*')[1]"/>
         <xsl:with-param name="class" as="xs:string" expand-text="true">{ $class }</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">not(string(.) castable as xs:decimal and matches(.,'^\S(.*\S)?$'))</xsl:with-param>
         <xsl:with-param name="condition"
                         select="not(string(.) castable as xs:decimal and matches(.,'^\S(.*\S)?$'))"/>
         <xsl:with-param name="msg" expand-text="true">Value <mx:code>{ string(.) }</mx:code> of { if (self::element()) then 'element' else 'attribute' } <mx:gi>{ self::attribute()/'@' }{ name(.) }</mx:gi> does not conform to <mx:code>decimal</mx:code> datatype.</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <xsl:template name="check-token-datatype">
      <xsl:param name="rule-id" as="xs:string*" select="()"/>
      <xsl:param name="class" as="xs:string">VDSX violates-datatype-syntax</xsl:param>
      <xsl:param name="matching" as="xs:string?" select="()"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf" as="xs:string">gix.121</xsl:with-param>
         <xsl:with-param name="rule-id" as="xs:string*" select="$rule-id"/>
         <xsl:with-param name="matching"
                         as="xs:string"
                         select="($matching[matches(.,'\S')],'*')[1]"/>
         <xsl:with-param name="class" as="xs:string" expand-text="true">{ $class }</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">not(string(.) castable as xs:string and matches(.,'^(\p{L}|_)(\p{L}|\p{N}|[.\-_])*$') and matches(.,'^\S(.*\S)?$'))</xsl:with-param>
         <xsl:with-param name="condition"
                         select="not(string(.) castable as xs:string and matches(.,'^(\p{L}|_)(\p{L}|\p{N}|[.\-_])*$') and matches(.,'^\S(.*\S)?$'))"/>
         <xsl:with-param name="msg" expand-text="true">Value <mx:code>{ string(.) }</mx:code> of { if (self::element()) then 'element' else 'attribute' } <mx:gi>{ self::attribute()/'@' }{ name(.) }</mx:gi> does not conform to <mx:code>token</mx:code> datatype.</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <xsl:template name="check-boolean-datatype">
      <xsl:param name="rule-id" as="xs:string*" select="()"/>
      <xsl:param name="class" as="xs:string">VDSX violates-datatype-syntax</xsl:param>
      <xsl:param name="matching" as="xs:string?" select="()"/>
      <xsl:call-template name="notice">
         <xsl:with-param name="cf" as="xs:string">gix.121</xsl:with-param>
         <xsl:with-param name="rule-id" as="xs:string*" select="$rule-id"/>
         <xsl:with-param name="matching"
                         as="xs:string"
                         select="($matching[matches(.,'\S')],'*')[1]"/>
         <xsl:with-param name="class" as="xs:string" expand-text="true">{ $class }</xsl:with-param>
         <xsl:with-param name="testing" as="xs:string">not(string(.) castable as xs:boolean and matches(.,'^true|1|false|0$'))</xsl:with-param>
         <xsl:with-param name="condition"
                         select="not(string(.) castable as xs:boolean and matches(.,'^true|1|false|0$'))"/>
         <xsl:with-param name="msg" expand-text="true">Value <mx:code>{ string(.) }</mx:code> of { if (self::element()) then 'element' else 'attribute' } <mx:gi>{ self::attribute()/'@' }{ name(.) }</mx:gi> does not conform to <mx:code>boolean</mx:code> datatype.</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="ul | ol" mode="validate-markup-multiline">
      <xsl:apply-templates select="li" mode="validate-markup-multiline"/>
      <xsl:for-each select="* except li">
         <xsl:call-template name="notice-multiline"/>
      </xsl:for-each>
   </xsl:template>
   <xsl:template match="table" mode="validate-markup-multiline">
      <xsl:apply-templates select="tr" mode="validate-markup-multiline"/>
      <xsl:for-each select="* except tr">
         <xsl:call-template name="notice-multiline"/>
      </xsl:for-each>
   </xsl:template>
   <xsl:template match="tr" mode="validate-markup-multiline">
      <xsl:apply-templates select="td" mode="validate-markup-multiline"/>
      <xsl:for-each select="* except td">
         <xsl:call-template name="notice-multiline"/>
      </xsl:for-each>
   </xsl:template>
   <xsl:template match="p | li | h1 | h2 | h3 | h4 | h5 | h6"
                 mode="validate-markup-multiline">
      <xsl:apply-templates mode="validate-markup-multiline" select="@*"/>
      <xsl:apply-templates mode="validate-markup-line"/>
   </xsl:template>
   <xsl:template match="a | em | i | strong | b | u | q | code | img | insert"
                 mode="validate-markup-line">
      <xsl:apply-templates mode="validate-markup-line" select="@*"/>
      <xsl:apply-templates mode="validate-markup-line"/>
   </xsl:template>
   <xsl:template match="a/@href | img/@src | img/@title | insert/@type | insert/@id-ref"
                 mode="validate-markup-line"/>
   <xsl:template mode="test"
                 match="p/text() | li/text() | h1/text() | h2/text() | h3/text() | h4/text() | h5/text() | h6/text()"/>
   <xsl:template mode="test"
                 match="em/text() | i/text() | strong/text() | b/text() | u/text() | q/text() | code/text() | a/text()"/>
</xsl:transform>
