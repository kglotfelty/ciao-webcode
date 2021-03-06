<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE xsl:stylesheet>

<!--*
    * Convert navbar.xml into the SSI pages
    * 
    * To do:
    *
    *-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:extfuncs="http://hea-www.harvard.edu/~dburke/xsl/extfuncs"
  extension-element-prefixes="extfuncs">

  <!--* Change this if the filename changes *-->
  <xsl:variable name="hack-import-navbar_main" select="extfuncs:register-import-dependency('navbar_main.xsl')"/>

  <!--*
      * Write the navbar. Context node should be the section/dirs/dir node,
      * which appears only to be important in the setting of the matchid parameter
      * for the call to the section[mode=create] template.
      *
      * We include a logo image IF the logomimage and logotext parameters
      * are set. We have just text if logoimage is unset but logotext is set.
      *
      * The navbar is surrounded by a pair of htdig_noindex /htdig_noindex
      * comments to hide the contents from the search engine used by the
      * CXC. This *includes* the news section (since it would appear on
      * every page + the news should be listed in the news page anyway)
      *
      * Parameters:
      *   filename - string, required
      *     name of file (including directory)
      *
      *-->
  <xsl:template name="write-navbar">
    <xsl:param name="filename" select="''"/>
    
    <xsl:if test="$filename = ''">
      <xsl:message terminate="yes">
  Error: write-navbar called with an empty filename parameter
      </xsl:message>
    </xsl:if>

    <xsl:if test="$logoimage != '' and $logotext = ''">
      <xsl:message terminate="yes">
  Error: logotext is unset but logoimage is set to '<xsl:value-of select="$logoimage"/>'
      </xsl:message>
    </xsl:if>

    <!--* process the page *-->
    <xsl:document href="{$filename}" method="html">
      <xsl:call-template name="navbar-contents"/>
    </xsl:document> <!--* end of a navbar *-->

  </xsl:template> <!--* name=write-navbar *-->

  <!--*
      * Create the contents of a navbar. This
      * has been separated out of write-navbar to
      * make it easier to test.
      *-->
  <xsl:template name="navbar-contents">

    <xsl:variable name="matchid" select="../../@id"/>

    <!--* add disclaimer about editing this HTML file *-->
    <xsl:call-template name="add-disclaimer"/>
    <xsl:comment>htdig_noindex</xsl:comment><xsl:text>
</xsl:text>

    <div>
	
      <!--* add the logo/link if required *-->
      <xsl:call-template name="add-logo-section"/>

      <xsl:if test="boolean(//links) and $site='csc'">
        <xsl:apply-templates select="//links" mode="create-csc-top"/>
      </xsl:if>

      <!--*
          * create the various sections
	  * Note: use an id rather than a class mainly to support
	  *       overriding CSS rules from the dt approach.
	  *-->
      <ul id="navlist">
	<xsl:apply-templates select="//section" mode="create">
	  <xsl:with-param name="matchid" select="$matchid"/>
	</xsl:apply-templates>
      </ul>

      <!--*
	  * anything else? (site-specific)
	  * Perhaps we should just go by what is in the navbar rather
	  * than having site-specific code?
	  *
	  * - if links section exists (any site), create it
	  *	BEFORE creating the news items
	  * - if CIAO and there are news items, write out the 
	  *   news bar (for all pages)
	  * - if Sherpa, as CIAO
	  * - if CALDB, as CIAO
	  *-->

      <xsl:if test="boolean(//links)">

        <xsl:if test="$site!='chart' and $site!='csc' and $site!='icxc'">
	  <div class="newsbar">
	    <h2>Analysis Notes</h2>
	  </div>
	</xsl:if>

        <xsl:if test="$site='chart'">
	  <hr/>
	</xsl:if>

	<xsl:choose>
	  <xsl:when test="$site='csc'">
            <xsl:apply-templates select="//links" mode="create-csc-bottom"/>
	  </xsl:when>
	  <xsl:otherwise>
            <xsl:apply-templates select="//links" mode="create"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:if>

      <xsl:if test="($site='ciao' or $site='sherpa' or $site='caldb' or $site='csc') and count(//news/item)!=0">
	<xsl:apply-templates select="//news" mode="create"/>
      </xsl:if>
	
    </div>

    <!--* re-start the indexing *-->
    <xsl:text>
</xsl:text>
    <xsl:comment>/htdig_noindex</xsl:comment><xsl:text>
</xsl:text>
  </xsl:template> <!--* name=navbar-contents *-->

  <!--*
      * create a section in the current navbar
      * IF we are in the section matching the current navbar's id then we
      * add a marker to the section 'title' link to indicate this is the
      * selected page
      *
      * NOTE: prior to CIAO 3.0 we only listed list contents if it was
      *       the selected section
      *
      *       we now allow sections with no link attribute (as a trial/test)
      *
      * NOTE:
      *   for now we ignore the highlight attribute
      *
      * NOTE:
      *   now 'year 2000' friendly - years can be specified as < 2000
      *   - in which case 2000 is added to them - or displayed as is
      *
      *-->
  <xsl:template match="section" mode="create">
    <xsl:param name="matchid" select='""'/>

    <xsl:variable name="classname"><xsl:choose>
	<xsl:when test="$matchid=@id">selectedheading</xsl:when>
	<xsl:otherwise>heading</xsl:otherwise>
      </xsl:choose></xsl:variable>

    <li>
      <!-- The onclick attribute is added so that IOS will pass through mouse events,
           in particular so that :hover will work. I am not sure what elements need
	   it
	-->
      <span class="navheader" onclick="void(0)">
      <xsl:choose>
	<xsl:when test="boolean(@link)">
	  <!--* section has a link attribute *-->
	  <a class="{$classname}"><xsl:choose>
	      <xsl:when test="starts-with(@link,'/')">
		<xsl:attribute name="href"><xsl:value-of select="@link"/></xsl:attribute>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:call-template name="add-attribute">
		  <xsl:with-param name="name"  select="'href'"/>
		  <xsl:with-param name="value" select="@link"/>
		</xsl:call-template>
	      </xsl:otherwise></xsl:choose><xsl:value-of select="title"/></a>
	</xsl:when>
	<xsl:otherwise>
	  <!--* no link, so just a title *-->
	  <span class="{$classname}"><xsl:value-of select="title"/></span>
	</xsl:otherwise>
      </xsl:choose>

      <!-- add in a new/updated logo if type=new/updated attribute exists -->
      <xsl:choose>
	  <xsl:when test="boolean(@type) = false()"/>
	  <xsl:when test="@type = 'new'">
	    <xsl:call-template name="add-image">
	      <xsl:with-param name="src"   select="'imgs/new.gif'"/>
	      <xsl:with-param name="alt"   select="'New'"/>
	    </xsl:call-template>
	  </xsl:when>
	  <xsl:when test="@type = 'updated'">
	    <xsl:call-template name="add-image">
	      <xsl:with-param name="src"   select="'imgs/updated.gif'"/>
	      <xsl:with-param name="alt"   select="'Updated'"/>
	    </xsl:call-template>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:message terminate="yes">
 ERROR: section tag found in navbar with unrecognised type attribute
   of type=<xsl:value-of select="@type"/>
	    </xsl:message>
	  </xsl:otherwise>
      </xsl:choose>
	
      <!--*
	  * any contents?
	  * The primary contents is expected to be a list, but there
          * is also the block element, added for CIAO 4.8, which is
          * a bit of a hack. Perhaps the contents should be processed
          * in the order they are specified, but for now use block then
          * list. 
	  *-->

      <xsl:if test="count(list) != 0">
	<span class="hassubmenu">➤</span>
      </xsl:if>
      </span>

      <xsl:apply-templates select="block" mode="navbar"/>
      <xsl:apply-templates select="list" mode="navbar"/>

    </li>

  </xsl:template> <!--* match=section mode="create" *-->

  <!--* 
      * create the news section
      * - having a mode of create may be important here in case there's a valid
      *   item attribute elsewhere
      *-->
  <xsl:template match="news" mode="create">

    <div>

      <div class="newsbar">
        <h2>News</h2>

	  <a href="{$newsfileurl}">Previous Items</a>
      </div>

      <!--* now do the individual items *-->
      <xsl:apply-templates select="item" mode="create"/>

    </div>
  </xsl:template> <!--* match=news mode=create *-->

  <!--*
      * create the news item
      *
      * CIAO 3.1 changes:
      * - added the type attribute, valid values are new or updated
      *   (so you do not use the new or updated tag any more)
      * - each item is placed within a div (no class)
      * - the text now has to be wrapped in <p> tags where
      *   necessary
      *
      *-->
  <xsl:template match="item" mode="create">

    <div>
      <p>
	<strong><xsl:call-template name="calculate-date-from-attributes"/></strong>
	<xsl:text> </xsl:text> <!--* only really necessary if we follow with an image *-->
	<xsl:choose>
	  <xsl:when test="boolean(@type) = false()"/>
	  <xsl:when test="@type = 'new'">
	    <xsl:call-template name="add-image">
	      <xsl:with-param name="src"   select="'imgs/new.gif'"/>
	      <xsl:with-param name="alt"   select="'New'"/>
	    </xsl:call-template>
	  </xsl:when>
	  <xsl:when test="@type = 'updated'">
	    <xsl:call-template name="add-image">
	      <xsl:with-param name="src"   select="'imgs/updated.gif'"/>
	      <xsl:with-param name="alt"   select="'Updated'"/>
	    </xsl:call-template>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:message terminate="yes">
 ERROR: item tag found in navbar with unrecognised type attribute
   of type=<xsl:value-of select="@type"/>
	    </xsl:message>
	  </xsl:otherwise>
	</xsl:choose>
      </p>
      <xsl:apply-templates/>

    </div>
  </xsl:template> <!--* match=item mode=create *-->



  <!--* 
      * create the links section 
      * - have a mode of create to replicate "news" template for CIAO pages
      *
      * see also the create-csc-top/bottom versions
      *-->
  <xsl:template match="links" mode="create">

    <xsl:apply-templates/>

    <xsl:if test="position() != last()">
      <hr/>
    </xsl:if>

  </xsl:template> <!--* match=links mode=create *-->


  <!--*
      * CSC adds these at top and bottom, but now DJB wants to
      * be "tricky" and add different style names to top and
      * bottom if the sticky attribute is set.
      *
      * This is rather hacky
      *-->
  <xsl:template match="links[@sticky]" mode="create-csc-top">
    <div class="navbar-sticky">
      <xsl:apply-templates/>
    </div>

    <xsl:if test="position() != last()">
      <hr/>
    </xsl:if>
  </xsl:template> <!--* match=links mode=create-csc-top *-->

  <xsl:template match="links" mode="create-csc-top">
    <xsl:apply-templates/>
    <xsl:if test="position() != last()">
      <hr/>
    </xsl:if>
  </xsl:template> <!--* match=links mode=create-csc-top *-->

  <xsl:template match="links[@sticky]" mode="create-csc-bottom">
    <div class="navbar-not-sticky">
      <xsl:apply-templates/>
    </div>

    <xsl:if test="position() != last()">
      <hr/>
    </xsl:if>
  </xsl:template> <!--* match=links mode=create-csc-bottom *-->

  <xsl:template match="links" mode="create-csc-bottom">
    <xsl:apply-templates/>
    <xsl:if test="position() != last()">
      <hr/>
    </xsl:if>
  </xsl:template> <!--* match=links mode=create-csc-bottom *-->

  <!--*
      * we use a mode to disambiguate ourselves from the
      * standard list-handling code in myhtml.xsl so that
      * lists as elements of this main list will be processed as
      * a list, and not as a section list in the navbar.
      * As of CIAO 4.8 this is not needed as much, but I
      * am not going to redesign things just yet.
      *
      * css code is made available via add-htmlhead (helper.xsl)
      *-->
  <xsl:template match="list" mode="navbar">
    <ul>
      <xsl:apply-templates mode="navbar"/>
    </ul>
  </xsl:template> <!--* match=list mode=navbar *-->

  <xsl:template match="li" mode="navbar">
    <li>
      <xsl:apply-templates/>
    </li>
  </xsl:template> <!--* match=li mode=navbar *-->

  <!--*
      * A hack to pass through "anything"; intended for the
      * CIAO social-media section
      *-->
  <xsl:template match="block" mode="navbar">
    <br/>
    <xsl:apply-templates/>
  </xsl:template> <!--* match=block mode=navbar *-->
  
  <!-- NOTE: may need to update ahelp_main.xsl with any changes here -->
  <xsl:template name="add-logo-section">
    <xsl:if test="$logotext != ''">
      <xsl:variable name="logo">
	<xsl:choose>
	  <xsl:when test="$logoimage != ''">
	    <xsl:call-template name="add-image">
	      <xsl:with-param name="alt" select="$logotext"/>
	      <xsl:with-param name="src" select="$logoimage"/>
	    </xsl:call-template>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="$logotext"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>
      <p class="navimage">
	<xsl:choose>
	  <xsl:when test="$logourl != ''">
	    <a href="{$logourl}">
	      <xsl:copy-of select="$logo"/>
	    </a>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:copy-of select="$logo"/>
	  </xsl:otherwise>
	</xsl:choose>
      </p>
    </xsl:if>
  </xsl:template> <!--* name=add-logo-section *-->

  <!--*
      * This is needed by helper.xsl for some reason
      * that I am too lazy to track down
      *-->
  <xsl:template name="newline"><xsl:text>
</xsl:text></xsl:template>

</xsl:stylesheet>
