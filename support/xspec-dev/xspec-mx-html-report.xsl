<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:mx="http://csrc.nist.gov/ns/csd/metaschema-xslt"
   exclude-result-prefixes="#all"
   xpath-default-namespace="http://www.jenitennison.com/xslt/xspec"
   expand-text="true"
   version="3.0">

<!-- nb: xspec-mx-html-report-nns.xsl is included at the end of this XSLT
containing templates we would otherwise have to reset wrt xpath-default-namespace
-->

   <!-- Not used by XProc -->
   <xsl:output method="html" html-version="5"/>

   <!-- 'clean' is a b/w theme with good contrast
        other available themes are 'uswds', 'classic', and 'toybox'
        or add your own templates in mode 'theme-css' (see below) -->
   <xsl:param name="theme" as="xs:string">clean</xsl:param>
   
   <!-- implementing strip-space by hand since we don't want to lose ws when copying content through -->
   <xsl:template match="report/text() | scenario/text() | test/text() | call/text() | result/text() | expect/text() | context/text()"/>
   
   
   <!-- Some interesting things about this XSLT:
   
   About half of it is literal CSS and Javascript to be pasted out
   There are templates matching strings, and functions calling templates
   Since attributes emit elements (not attributes, as more usually) they often don't come first inside their parents
   
   -->
   <xsl:template match="/">
      <html>
         <head>
            <title>XSpec - { count(descendant::test) } { if (count(descendant::test) eq 1) then 'test' else 'tests'} in { count(descendant::report) } { if (count(descendant::report) eq 1) then 'report' else 'reports'} </title>
            <xsl:call-template name="page-css"/>
            <xsl:call-template name="page-js"/>
         </head>
         <xsl:apply-templates/>
      </html>
   </xsl:template>
   
   <xsl:template match="/*" priority="101">
      <body class="{ $theme }">
         <xsl:for-each-group select="report" group-by="true()">
            <ul>
               <xsl:for-each select="current-group()">
                  <li><a href="#report_{ count(.|preceding-sibling::report) }">XSpec Report - <code>{ @xspec }</code></a></li>
               </xsl:for-each>
            </ul>
         </xsl:for-each-group>
         <xsl:next-match/>
      </body>
   </xsl:template>
   
   <xsl:template match="report">
      <section class="xspec-report" id="report_{ count(.|preceding-sibling::report) }">
         <div class="iconogram floater">
            <xsl:apply-templates mode="iconogram"/>
         </div>
         <h1>XSpec Report - <code>{ @xspec/replace(.,'.*/','') }</code></h1>
         <button onclick="javascript:expandSectionDetails(closest('section'))">Expand report</button>
         <button onclick="javascript:collapseSectionDetails(closest('section'))">Collapse</button>
         <xsl:apply-templates select="@*"/>
         <div class="summary">
            <xsl:apply-templates select="." mode="in-summary"/>
         </div>
         <hr class="hr"/>
         <xsl:apply-templates/>
      </section>
   </xsl:template>
   
   <xsl:template match="text()" mode="iconogram"/>
   
   <xsl:template match="scenario" mode="iconogram">
      <xsl:variable name="in" select="ancestor-or-self::scenario"/>
      <xsl:variable name="oddness" select="('odd'[count($in) mod 2],'even')[1]"/>
      <div class="fence { $oddness }{ child::test[@successful != 'true']/' failing'}">
         <xsl:apply-templates mode="#current"/>
      </div>
   </xsl:template>
   
   <xsl:template priority="5" match="test" mode="iconogram">
      <a class="jump" onclick="javascript:viewSection('{@id}')" title="{ ancestor-or-self::*/label => string-join(' ') }">
         <xsl:apply-templates select="." mode="icon"/>
      </a><!-- crossed fingers -->
   </xsl:template>
   
   <!-- icons indicating test results can also be overridden or themed -->
   <!-- crossed fingers -->
   <xsl:template priority="5" match="test[matches(@pending,'\S')]" mode="icon">&#129310;</xsl:template>
   
   <!-- thumbs up -->
   <xsl:template match="test[@successful='true']" mode="icon">&#128077;</xsl:template>
   
   <!-- thumbs down -->
   <xsl:template match="test" mode="icon">&#128078;</xsl:template>
   
   
   <!-- Generic handling for any attribute not otherwise handled -->
   <xsl:template match="@*">
      <p class="{local-name(.)}"><b class="pg">{ local-name(..) }/{ local-name(.) }</b>: <span class="pg">{ . }</span></p>
   </xsl:template>
   
   <xsl:template match="@id" priority="101"/>
   
   <xsl:template priority="20" match="report/@xspec | report/@stylesheet">
      <p class="{local-name(.)}"><b class="pg">{ local-name(..) }/{ local-name(.) }</b>: <a class="pg" href="{ . }">{ . }</a></p>
   </xsl:template>
   
   <xsl:template priority="20" match="report/@date">
      <p class="{local-name(.)}"><b class="pg">{ local-name(..) }/{ local-name(.) }</b>: { format-dateTime(xs:dateTime(.),'[MNn] [D1], [Y0001] [H01]:[m01]:[s01]') } (<code>{.}</code>)</p>
   </xsl:template>
   
   <xsl:template priority="20" match="test/@successful"/>
   
   
   <xsl:template match="scenario">
      <details class="{ (@pending/'pending',.[descendant::test/@successful = 'false']/'failing','passing')[1]}{ child::test[1]/' tested' }">
         <xsl:copy-of select="@id"/>
         <xsl:if test="descendant::test/@successful = 'false'">
            <xsl:attribute name="open">open</xsl:attribute>
         </xsl:if>
         <summary>
            <xsl:apply-templates select="." mode="in-summary"/>
         </summary>
         <div class="{ (child::scenario[1]/'scenario-results','test-results')[1] }">
           <xsl:apply-templates/>
         </div>
      </details>
   </xsl:template>
   
   <xsl:template match="scenario/label"/>
   
   <xsl:template match="report | scenario" mode="in-summary">
      <xsl:variable name="here" select="."/>
      <xsl:variable name="subtotal" select="exists(ancestor-or-self::report//test except descendant::test)"/>
      <xsl:variable name="all-passing" select="empty(descendant::test[not(@successful='true')])"/>
      <span class="label">{ self::report/'Total tests '}{ child::label }</span>
      <xsl:text>&#xA0;</xsl:text><!-- nbsp -->
      <xsl:apply-templates select="self::scenario/descendant::test" mode="icon"/>
      <span class="result">
      <xsl:iterate select="'passing', 'pending', 'failing','total'[not($subtotal)],'subtotal'[$subtotal]">
         
         <xsl:variable name="this-count">
            <xsl:apply-templates select="." mode="count-tests">
               <xsl:with-param name="where" select="$here"/>
            </xsl:apply-templates>
         </xsl:variable>
         <xsl:text> </xsl:text>
         <span class="{ . }{ ' zero'[$this-count='0']}{ .[.=('total','subtotal')] ! ' passing'[$all-passing]}">
            <b class="pg">{ . }</b>
            <xsl:text>: </xsl:text>
            <xsl:sequence select="$this-count"/>
         </span>
      </xsl:iterate>
      </span>
   </xsl:template>
   
   <xsl:template priority="20" match="scenario[exists(child::test)]" mode="in-summary">
      <xsl:variable name="here" select="."/>
      <span class="label">{ child::label }</span>
      <xsl:text>&#xA0;</xsl:text><!-- nbsp -->
      <xsl:apply-templates select="child::test" mode="icon"/>
      <xsl:apply-templates select="child::test" mode="#current"/>
      <span class="result { child::test/(@pending/'pending', @successful)[1] }">{ (child::test/@pending/('Pending ' || .),child::test[@successful='true']/'Passes','Fails')[1] }</span>
   </xsl:template>
   
   <xsl:template mode="in-summary" match="test">
      <xsl:text> </xsl:text>
      <span class="testing"> Expecting <span class="expecting">{ child::label }</span></span>
   </xsl:template>
   
   <xsl:template match="result">
      <div class="reported panel">
         <xsl:apply-templates select="." mode="header"/>
         <xsl:apply-templates select="@select"/>
         <xsl:apply-templates/>
      </div>
   </xsl:template>
   
   <xsl:template match="test">
      <div class="tested panel { if (@successful='true') then 'succeeds' else 'fails' }">
         <xsl:copy-of select="@id"/>
         
         <xsl:apply-templates select="." mode="header"/>
         <xsl:apply-templates select="@*"/>
         <xsl:apply-templates/>
      </div>
   </xsl:template>
   
   <xsl:template match="test" mode="header">
      <h3>Expecting (testing against)</h3>
   </xsl:template>
   
   <xsl:template match="result" mode="header">
      <h3>Producing (actual result)</h3>
   </xsl:template>
   
   <xsl:template match="*" mode="header"/>
   
   <xsl:template match="call | expect | context" priority="3">
         <xsl:apply-templates select="@*"/>
         <xsl:next-match/>
   </xsl:template>
   
   <xsl:template match="context[exists(*)]">
      <div class="codeblock { local-name() }" onclick="javascript:clipboardCopy(this);">
         <xsl:call-template name="write-xml"/>
      </div>
   </xsl:template>
   
   <xsl:template match="test/label" priority="5">
      <h5 class="label">
         <xsl:apply-templates/>
      </h5>
   </xsl:template>
   
      
   <xsl:template name="write-xml" xmlns:map="http://www.w3.org/2005/xpath-functions/map">
      <xsl:sequence select="serialize(child::*, map {'indent': true()}) => replace('^\s+','')"/>
   </xsl:template>
   
  <!-- <xsl:template match="processing-instruction()">
      <xsl:text>&lt;?{ name() }{ string(.) }?></xsl:text>
   </xsl:template>-->
   
   <xsl:template name="page-css">
      <style type="text/css">
<xsl:text  xml:space="preserve" expand-text="false">

body { font-family: 'Calibri', 'Arial', 'Helvetica' }

section { border-top: medium solid black; padding-top: 0.6em; margin-top: 0.6em}

.floater { float: right; clear: both }

div.iconogram, div.fence { display: flex; border: thin solid grey; margin: 0.1em; padding: 0.1em; flex-wrap: wrap; height: fit-content }

div.iconogram { background-color: white }

div.fence { border: thin dotted grey }

div.fence.failing { border-style: solid }

div.summary { margin-top: 0.6em }

details { outline: thin solid black; padding: 0.4em }
details.tested { outline: thin dotted black }

.failing { background-color: gainsboro }
.failing.zero { background-color: inherit } 

.summary-line { margin: 0.6em 0em; font-size: 110% }

.scenario-results { margin-top: 0.2em }
.scenario-results * { margin: 0em }
.scenario-results divx { outline: thin dotted black; padding: 0.2em }
.scenario-results div:first-child { margin-top: 0em }


.test-results { margin-top: 0.6em; display: grid;
    overflow: hidden;
  grid-template-columns: 1fr 1fr;
  grid-auto-rows: 1fr;
  grid-column-gap: 1vw; grid-row-gap: 1vw }

.panel {  display: flex;
  flex-direction: column  }

.panel.tested { grid-column: 2 }

div.panel .codeblock { align-self: flex-end }

.codeblock { width: 100%; box-sizing: border-box;
  outline: thin solid black; padding: 0.4em; background-color: white;
  overflow: auto; resize: both;
  font-family: 'Consolas', monospace;
  white-space: pre }

span.result { float: right; display: inline-block }
span.result span { padding: 0.2em; display: inline-block; outline: thin solid black }

.label { font-weight: bold; background-color: gainsboro; padding: 0.2em; max-width: fit-content; outline: thin solid black }
.pending .label { background-color: inherit; color: black; font-weight: normal; outline: thin solid black }

span.label { display: inline-block }

span.expecting { font-style: italic; font-weight: bold }

.iconogram a { text-decoration: none }

.total, .subtotal { background-color: white }

a.jump { cursor: pointer }

.codeblock:hover { cursor: copy }

</xsl:text>
         <xsl:apply-templates select="$theme" mode="theme-css"/>
      </style>
      
   </xsl:template>
   
   <xsl:template mode="theme-css" priority="1" match=".[.='uswds']">
      <xsl:text xml:space="preserve" expand-text="false"><!-- colors borrowed from USWDS -->
.uswds {
  .label {    background-color: #1a4480; color: white}
  .pending .label { background-color: inherit; color: black }
  .passing { background-color: #e1f3f8 }
  .pending { background-color: white }
  .failing { background-color: #f8dfe2 }
  .pending.zero, .failing.zero { background-color: inherit } 
}
</xsl:text>
   </xsl:template>

   <!-- Mode theme-css produces CSS per theme, matching on the theme name, a string -->
   <!-- An importing XSLT can provide templates for whatever additional themes are wanted -->
   
   <xsl:template mode="theme-css" priority="1" match=".[.=('clean','simple')]"/>
   
   <xsl:template mode="theme-css" priority="1" match=".[.='classic']"><!-- 'classic' theme emulates JT's purple-and-green -->
      <xsl:text xml:space="preserve" expand-text="false">
.classic {
  h1, .label {   background-color: #606; color: #6f6 }
  h1 { padding: 0.2em }
  .pending .label { background-color: inherit; color: black }
  .passing { background-color: #cfc }
  .pending { background-color: #eee }
  .failing { background-color: #fcc }
  .pending.zero, .failing.zero { background-color: inherit } 
}
</xsl:text>
   </xsl:template>
   
   <xsl:template mode="theme-css" priority="1" match=".[.='toybox']">
      <xsl:text xml:space="preserve" expand-text="false">
.toybox {
   .label {   background-color: black; color: white }
   .failing .label { background-color: darkred }
   .passing .label { background-color: darkgreen }
   .pending .label { background-color: inherit; color: black }
   .passing { background-color: honeydew }
   .pending { background-color: cornsilk }
   .failing { background-color: mistyrose }
   .pending.zero, .failing.zero { background-color: inherit } 
}
</xsl:text>
   </xsl:template>
      
   <xsl:template mode="theme-css" match=".">
      <xsl:message>No template for theme '{ $theme }' - using 'simple'</xsl:message>
   </xsl:template>
   
   <xsl:template name="page-js">
      <script type="text/javascript">
<xsl:text xml:space="preserve" expand-text="false">
const viewSection = eID => {
     let who = document.getElementById(eID); 
     let openers = getAncestorDetails(who);
     openers.forEach(o => { o.open = true; } );
     who.scrollIntoView( {behavior: 'smooth'} );
}

const getAncestorDetails = el => {
    let ancestors = [];
    while (el) {
      if (el.localName === 'details') { ancestors.unshift(el); }
      el = el.parentNode;
    }
    return ancestors;
}

const expandSectionDetails = inSection => {
    let sectionDetails = [... inSection.getElementsByTagName('details') ];
    sectionDetails.forEach(d => { d.open = true; } );
}
const collapseSectionDetails = inSection => {
    let sectionDetails = [... inSection.getElementsByTagName('details') ];
    sectionDetails.forEach(d => { d.open = false; } );
}

<!-- thanks to https://www.30secondsofcode.org/js/s/unescape-html/ -->
<![CDATA[ 
const unescapeHTML = str =>
  str.replace(
    /&amp;|&lt;|&gt;|&#39;|&quot;/g,
    tag =>
      ({
        '&amp;': '&',
        '&lt;': '<',
        '&gt;': '>',
        '&#39;': "'",
        '&quot;': '"'
      }[tag] || tag)
  );

]]>

const clipboardCopy = async (who) => {
      let cp = unescapeHTML(who.innerHTML);
      try { await navigator.clipboard.writeText(cp); }
      catch (err) { console.error('Failed to copy: ', err); }
    }

</xsl:text>
      </script>
   </xsl:template>
   
   

   <xsl:mode name="count-tests" on-no-match="fail"/>
   
   <!-- 'Visitor' pattern matches strings to dispatch processing -->
   <xsl:template mode="count-tests" match=".[.='passing']">
      <xsl:param name="where" as="element()"/>
      <xsl:sequence select="count($where/descendant::test[@successful='true'])"/>
   </xsl:template>
   
   <xsl:template mode="count-tests" match=".[.='pending']">
      <xsl:param name="where" as="element()"/>
      <xsl:sequence select="count($where/descendant::test[matches(@pending,'\S')])"/>
   </xsl:template>
   
   <xsl:template mode="count-tests" match=".[.='failing']">
      <xsl:param name="where" as="element()"/>
      <xsl:sequence select="count($where/descendant::test[@successful!='true'])"/>
   </xsl:template>
   
   <xsl:template mode="count-tests" match=".[.=('total','subtotal')]">
      <xsl:param name="where" as="element()"/>
      <xsl:sequence select="count($where/descendant::test)"/>
   </xsl:template>
   
   <xsl:include href="xspec-mx-html-report-nns.xsl"/>
   
</xsl:stylesheet>
