<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE xsl:stylesheet>

<!--* 
    * Convert an XML web page into an HTML one
    *
    *-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:extfuncs="http://hea-www.harvard.edu/~dburke/xsl/extfuncs"
  extension-element-prefixes="exsl extfuncs">

  <!--* Change this if the filename changes *-->
  <xsl:variable name="hack-import-page" select="extfuncs:register-import-dependency('page.xsl')"/>

  <xsl:output method="text"/>

  <!--* we place this here to see if it works (was in header.xsl and wasn't working
      * - and it seems to
      *-->
  <!--* a template to output a new line (useful after a comment)  *-->
  <xsl:template name="newline">
<xsl:text> 
</xsl:text>
  </xsl:template>

  <!--* load in the set of "global" parameters *-->
  <xsl:include href="globalparams.xsl"/>

  <!--* include the stylesheets AFTER defining the variables *-->
  <xsl:include href="helper.xsl"/>
  <xsl:include href="links.xsl"/>
  <xsl:include href="myhtml.xsl"/>

  <!--*
      * top level: create
      *   index.html
      *
      *-->
  <xsl:template match="/">

    <!--* check the params are okay *-->
    <xsl:call-template name="is-site-valid"/>
    <xsl:call-template name="check-param-ends-in-a-slash">
      <xsl:with-param name="pname"  select="'install'"/>
      <xsl:with-param name="pvalue" select="$install"/>
    </xsl:call-template>
    <xsl:call-template name="check-param-ends-in-a-slash">
      <xsl:with-param name="pname"  select="'canonicalbase'"/>
      <xsl:with-param name="pvalue" select="$canonicalbase"/>
    </xsl:call-template>

    <!--* what do we create *-->
    <xsl:apply-templates select="page"/>

  </xsl:template> <!--* match=/ *-->

  <!--* 
      * create: <page>.html
      *-->

  <xsl:template match="page">

    <xsl:variable name="filename"><xsl:value-of select="$install"/><xsl:value-of select="$pagename"/>.html</xsl:variable>

    <!--* output filename to stdout *-->
    <xsl:value-of select="$filename"/><xsl:call-template name="newline"/>

    <!--*
        * create HTML5 document, see
        * http://w3c.github.io/html/syntax.html#doctype-legacy-string
        * http://www.microhowto.info/howto/generate_an_html5_doctype_using_xslt.html
        * https://stackoverflow.com/a/19379446
        *
        * Not sure that version="5.0" is actually working properly
        * (or maybe my libxslt is too old)
	*-->
    <xsl:document href="{$filename}" method="html" media-type="text/html"
                  doctype-system="about:legacy-compat"
		  version="5.0">

      <!--* we start processing the XML file here *-->
      <html lang="en-US">

	<!--* make the HTML head node *-->
	<xsl:call-template name="add-htmlhead-standard"/>

	<!-- * create the page contents *-->
	<xsl:apply-templates select="text"/>

      </html>

    </xsl:document>
  </xsl:template> <!--* match=page *-->

  <xsl:template match="text[boolean(//page/info/navbar)]">

    <xsl:call-template name="add-body-withnavbar">
      <xsl:with-param name="contents">
	<xsl:apply-templates/>
      </xsl:with-param>
      <xsl:with-param name="navbar">
	<xsl:call-template name="add-navbar">
	  <xsl:with-param name="name" select="//page/info/navbar"/>
	</xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>

  </xsl:template> <!-- text with navbar -->

  <!-- no navbar -->
  <xsl:template match="text">

    <xsl:call-template name="add-body-nonavbar">
      <xsl:with-param name="contents">
	<xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>

  </xsl:template> <!--* text without navbar *-->

</xsl:stylesheet>
