<?xml version='1.0' encoding='us-ascii' ?>
<!DOCTYPE xsl:stylesheet>
<xsl:stylesheet version='1.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'>
  <xsl:output method='html' media-type='text/html' version='4.0' encoding='us-ascii'/>
  <xsl:include href='../../../helper.xsl'/>
  <xsl:include href='../../../myhtml.xsl'/>
  <xsl:include href='../../../links.xsl'/>
  <xsl:template match='test'>
<xsl:text>
</xsl:text>
<xsl:call-template name='add-highlight-pre'>
  <xsl:with-param name='contents'>FOO <flobble>BaR</flobble></xsl:with-param>
</xsl:call-template>
  </xsl:template>
</xsl:stylesheet>
