<?xml version="1.0" encoding="utf-8" ?>
<!DOCTYPE xsl:stylesheet>

<!--* 
    * Create the HTML version of the ChIPS thread
    *-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!--* for general comments see ciao_thread.xsl *-->
  <xsl:output method="text"/>

  <xsl:include href="globalparams_thread.xsl"/>

  <xsl:param name="imglinkicon" select='""'/>
  <xsl:param name="imglinkiconwidth" select='0'/>
  <xsl:param name="imglinkiconheight" select='0'/>

  <xsl:include href="thread_common.xsl"/>
  <xsl:include href="helper.xsl"/>
  <xsl:include href="links.xsl"/>
  <xsl:include href="myhtml.xsl"/>

  <xsl:template name="newline">
<xsl:text> 
</xsl:text>
  </xsl:template>

  <xsl:template match="/">

    <xsl:call-template name="is-site-valid"/>
    <xsl:call-template name="check-param-ends-in-a-slash">
      <xsl:with-param name="pname"  select="'install'"/>
      <xsl:with-param name="pvalue" select="$install"/>
    </xsl:call-template>
    <xsl:call-template name="is-proglang-valid"/>

    <xsl:apply-templates select="thread" mode="html-viewable-standard"/>
    <xsl:apply-templates select="thread/images/image" mode="list"/>

  </xsl:template> <!-- match="/" *-->

</xsl:stylesheet>
