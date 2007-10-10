<?xml version="1.0" encoding="us-ascii" ?>
<!DOCTYPE xsl:stylesheet>

<!-- $Id: threadindex_common.xsl,v 1.37 2007/08/23 19:09:08 egalle Exp $ -->

<!--* 
    * Recent changes:
    *  v1.35 - only create "Download Data" link in thread datatable if
    *	       datasets tag exists
    *  v1.34 - only create thread datatable if the tag exists
    *  v1.33 - ??
    *  v1.32 - hyphen added to (head/text)titlepostfix instances
    *  v1.31 - allow "text" tag in "sublist" for more description in  
    *	       thread index; needed for ispec section reorganization
    *  v1.30 - related to v1.28 edit: added "xsl:when" construct so
    *	       that link is correct in CIAO and Sherpa sites
    *  v1.29 - removed "xsl:if" that is no longer necessary b.c of
    *	       v1.28 edit
    *  v1.28 - removed code that created links to Provisional Data
    *	       Retrieval Interface in datasets table.  Replaced
    *	       "Archive search form" link with link to "How to
    *	       Download Chandra Data from the Archive" thread. 
    *  v1.27 - <html> changed to <html lang="en"> following
    *          http://www.w3.org/TR/2005/WD-i18n-html-tech-lang-20050224/
    *  v1.26 - adds a br to the end of a sublist if followed by an item
    *  v1.25 - sublists can now nest (not a 100% brilliant design)
    *  v1.24 - thread links now have the threadlink class
    *  v1.23 - improve new/updated text in headers of index.html
    *          (removed actual numbers of threads)
    *          Added id="threaddatatable" to the data table
    *  v1.22 - changed layout of text; remove dl and use h3/div's instead
    *          and some changes to the list-handling code
    *  v1.21 - added class=qlinkbar to the 'quick links' div's
    *  v1.20 - scripts: 'See also:' -> 'Uses:', no longer link to scripts
    *  v1.19 - oops, missed a few cases for the 1.18 fix
    *  v1.18 - added an anchor for the 'skip nav. bar' link
    *  v1.17 - updated to handle head/texttitlepostfix
    *  v1.16 - minor fix to not use p../p when text block contains one
    *  v1.15 - removed use of tables where easy
    *          "all" page now uses a dl rather than ul to list sections
    *  v1.14 - re-organisation of layout for CIAO 3.0
    *  v1.13 - stopped adding 2000 to year from threads if > 1999 (year 3999 problem)
    *  v1.12 - no need for separate css style as a.tablehead:link now in main ciao.css
    *  v1.11 - added " - " between section title and # of new/updated threads
    *  v1.10 - oops: forgot to add "Updated" to the text for updated threads
    *   v1.9 - The initial index page no-longer lists the actual new/updated
    *          threads, just that there are some.
    *   v1.8 - changing titles of pages to include a WHATS NEW link
    *   v1.7 - added support for synopsis block in sections
    *          more code cleanups/consolidation
    *   v1.6 - more consolidation - moved page-creation code from *_threadindex.xsl
    *          tidied up quick link (added ||)
    *          removed separate ciao/sherpa_threadindex.xsl stylesheets but this
    *          doesn't affect this stylesheet (at the moment)
    *   v1.5 - consolidation of "quicklink" code from ciao/sherpa pages
    *          it can now include links to "external" thread pages
    *   v1.3/4 - typo fixes
    *   v1.2 - made links to script be aware of the site
    *   v1.1 - was v1.4 of ciao_threadindex_common.xsl
    *
    * process the sections of the thread index for the CIAO & Sherpa pages
    *
    * Parameters set in threadindex.xsl
    *  . threadDir - location of input thread XML files
    *              defaults to /data/da/Docs/<site>web/published/<type>/threads/
    *
    *  . site=one of: ciao sherpa
    *    tells the stylesheet what site we are working with
    *    [no support for chart thread index at the moment]
    *
    * Notes:
    *  - FOR CIAO 3.1 we need to sort out the way that new/updated threads
    *    are reported on the index pages (the move to using h3/4 tags has
    *    probably messed-up the current system)
    *
    *  - confusion over whether $depth is a stylesheet parameter
    *    (ie set by calling process, as it is for thread indexex) or is 
    *    template parameter (as it is in the general case)
    *    UNFORTUNATELY, UNTIL WE FIX EVERYTHING UP TO BE SENSIBLE
    *    [needs re-designing the navbar code] WE HAVE TO MESS AROUND WITH
    *    IT
    *
    *  - some templates may collide with those in other stylesheets
    *    (primarily myhtml.xsl) - needs looking at
    *
    *  - one improvement would be for the thread-processing code to
    *    create a slimmed-down XML version of the thread which contains
    *    the information needed to create the index. This would then
    *    be read in rather than the thread itself, reducing time/memory
    *    requirements.
    *-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!--*
      * handle the sublist element
      *
      * We add a "br" to the end of the list IF the following item is
      * an item tag (ie we don't if it is followed by nothing or a sublist)
      *
      *-->
  <xsl:template match="sublist" mode="threadindex">
    <xsl:param name="depth" select="$depth"/>

    <li>
      <div class="threadsublist">
	<h4><xsl:apply-templates select="title" mode="show"/></h4>

	<xsl:if test="boolean(text)">
	  <xsl:apply-templates select="text">
	    <xsl:with-param name="depth" select="$depth"/>
	  </xsl:apply-templates>
	</xsl:if>

	<ul>
	  <!--* we do not want to process the title element here *-->
	  <xsl:apply-templates select="*[name() != 'title' and name() != 'text']" mode="threadindex">
	    <xsl:with-param name="depth" select="$depth"/>
	  </xsl:apply-templates>
	</ul>
	<!--* do we need a spacer? *-->
	<xsl:if test="name(following-sibling::*[1]) = 'item'">
	  <br/>
	</xsl:if>
      </div>
    </li>
  </xsl:template> <!--* match=sublist mode=threadindex *-->

  <!--* 
      * this is an important empty tag 
      * - poor design of DTD ?
      *-->
  <xsl:template match="title"/>

  <xsl:template match="title" mode="show">
    <xsl:param name="depth" select="$depth"/>
    <xsl:apply-templates>
      <xsl:with-param name="depth" select="$depth"/>
    </xsl:apply-templates>
    <xsl:call-template name="newline"/>
  </xsl:template>

  <!--*
      * process lists slightly differently to the
      * way they are handled in myhtml.xsl
      * - this means we can simpligy the list-handling
      *   in myhtml
      *-->
  <xsl:template match="list" mode="threadindex">
    <div class="threadlist">
      <ul>
	<xsl:apply-templates mode="threadindex"/>
      </ul>
    </div>
  </xsl:template> <!--* match=list mode=threadindex *-->

  <!--* 
      * handle a single thread 
      * we delegate most of the processing to templates that match
      * tags in thread.xml, as this is the easiest way I can think
      * of of importing the document into the system, without
      * having to read any actual documentation on XSLT myself...
      *
      * Actually, have a couple of different modes
      *   <item name="foo"/>
      *   <item><text>...</text></item>
      *
      *-->
  <xsl:template match="item" mode="threadindex">
    <xsl:param name="depth" select="$depth"/>

    <li>
      <!--* what goes here? *-->
      <xsl:choose>
	<xsl:when test="boolean(text)">
	  <xsl:apply-templates select="text">
	    <xsl:with-param name="depth" select="$depth"/>
	  </xsl:apply-templates>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:call-template name="list-thread">
	    <xsl:with-param name="depth" select="$depth"/>
	  </xsl:call-template>
	</xsl:otherwise>
      </xsl:choose>

      <!--*
          * if the next item is a sublist then we want a br here as well 
          * - as long as we're not in a sublist ourselves
          *
          * NOTE: this is not quite right, as a sublist in a sublist
          *       will not get the br tags when it should, but I can't
          *       be bothered to sort that out just now
          *-->
      <xsl:if test='name(following::*[position()=1])="sublist" and name(..)!="sublist"'>
	<br/>
      </xsl:if>

    </li>

  </xsl:template> <!--* match=item mode=threadindex *-->

  <!--* 
      * text 
      * 
      * this may conflict with other templates
      * BUT currently the only one is in page.xsl which won't be loaded
      * with this file
      * 
      *-->
  <xsl:template match="text">
    <xsl:param name="depth" select="$depth"/>
    <xsl:apply-templates>
      <xsl:with-param name="depth" select="$depth"/>
    </xsl:apply-templates>
  </xsl:template> <!--* match=text *-->

  <!--*
      * list a thread
      *
      * List the title and any associated scripts
      * (as of CIAO 3.1 we only provide a single script package, so
      *  can not link to the individual scripts/packages; hence we no
      *  longer link to the script but just list it.)
      *
      *-->
  <xsl:template name="list-thread">
    <xsl:param name="depth" select="$depth"/>

    <!--* read the thread into a variable to avoid multiple parses of the file *-->
    <xsl:variable name="thisThread" select="document(concat($threadDir,@name,'/thread.xml'))"/>
    <xsl:variable name="thisThreadInfo" select="$thisThread/thread/info"/>

    <!--*
        * create a link to the thread
        * - QUESTION: should we use the same system as the threadlink
        *   tag - ie use the handle-thread-site-link template - to get
        *   depth-handling/etc consistent???
        *   OR, do we assume that as we are in the thread index everything
        *   is in the sub-directory of this page so we needn't bother?
        *-->
    <a class="threadlink" href="{$thisThreadInfo/name}/"><xsl:value-of select="$thisThreadInfo/title/long"/></a>

    <!--*
        * handle any script items
        *-->
    <xsl:if test="count($thisThreadInfo/files/script) > 0">
      <br/>Uses:
      <xsl:for-each select="$thisThreadInfo/files/script">
	<xsl:apply-templates select="." mode="threadindex">
	  <xsl:with-param name="depth" select="$depth"/>
	</xsl:apply-templates>
      </xsl:for-each>
    </xsl:if>

    <!--* Is this thread new or recently updated ? *-->
    <xsl:if test="boolean($thisThreadInfo/history/@new)">
      <br/>
      <xsl:call-template name="add-new-image">
	<xsl:with-param name="depth" select="$depth"/>
      </xsl:call-template>
      <xsl:apply-templates select="$thisThreadInfo/history" mode="date"/>
    </xsl:if>
    <xsl:if test="boolean($thisThreadInfo/history/@updated)">
      <br/>
      <xsl:call-template name="add-updated-image">
	<xsl:with-param name="depth" select="$depth"/>
      </xsl:call-template>
      <xsl:apply-templates select="$thisThreadInfo/history" mode="date"/>
    </xsl:if>
	
  </xsl:template> <!--* name=list-thread *-->

  <!--* print out the last date from the history block *-->
  <xsl:template match="history" mode="date">
    <xsl:variable name="entry" select="entry[last()]"/>
    <xsl:variable name="year"><xsl:choose>
	<xsl:when test="$entry/@year > 1999"><xsl:value-of select="$entry/@year"/></xsl:when>
	<xsl:otherwise><xsl:value-of select="2000+$entry/@year"/></xsl:otherwise>
      </xsl:choose></xsl:variable>
    (<strong><xsl:value-of select="concat($entry/@day,' ',substring($entry/@month,1,3),
	' ',$year)"/></strong>)
  </xsl:template> <!--* /thread mode=date *-->

  <!--* 
      * Note:
      *   There is the possibility for conflict since we
      *   use the script tag in more than one place with different
      *   syntax and semantics. However they shouldn't collide
      *   since in different places (eg info vs text blocks)
      *   [have a hopefully-unique mode in here just in case]
      *
      * Assumes that the stylesheet "global" parameter site is set
      *
      * was originally in helper.xsl
      *
      * AS OF CIAO 3.1 we:
      * - no longer create a link
      * - print a warning if we come across a "package" element
      *   [the following-sibling::script check below should be
      *   enhanced to ignore such elements but I can not be bothered just now]
      *-->
  <xsl:template match="script" mode="threadindex">
    <!--* TEMPORARY HACK *-->
    <xsl:if test="boolean(@package)">
      <xsl:message>

 WARNING: script element with @package attribute
 script=<xsl:value-of select="."/>
 thread=<xsl:value-of select="$thisThreadInfo/name"/>

      </xsl:message>
    </xsl:if>
    the <tt><xsl:value-of select="."/></tt>
    <xsl:if test="boolean(@slang)"> S-Lang</xsl:if>
    script<xsl:if test="count(following-sibling::script)!=0">; </xsl:if>
  </xsl:template> <!--* match=script mode=threadindex *-->

  <!--* 
      * make the data table: 
      *   called with threadindex as the context node
      *   (ie *NOT* datatable)
      *
      * Parameters:
      *  depth
      *
      * In CIAO 3.1 added the "threaddatatable" id to the table
      * (so that can hide the link using CSS for the print option)
      *-->
  <xsl:template name="make-datatable">
    <xsl:param name="depth" select="1"/>

<!--//BOB//-->
    <xsl:if test="boolean(//threadindex/datatable)">

    <table id="threaddatatable" align="center" width="90%" cellspacing="0" cellpadding="2"> 
      <tr>    
        <td id="threaddatatableheader" colspan="4">
	    <h3>Data Used in Threads</h3>

	<xsl:if test="boolean(//threadindex/datatable/datasets)">
	    <br/>
	    <a class="tablehead">
	      <xsl:attribute name="href">
	        <xsl:choose>
		  <xsl:when test="$site='ciao'">archivedownload/</xsl:when>
		  <xsl:when test="$site='sherpa'">/ciao/threads/archivedownload/</xsl:when>
		  </xsl:choose>
	       </xsl:attribute>How to Download Chandra Data from the Archive</a>
	</xsl:if>
	</td>
      </tr>

	    <!--* datasets *-->
	    <xsl:apply-templates select="datatable/datasets"/>

	    <!--* packages *--> 
	    <xsl:apply-templates select="datatable/packages"/>
    </table>
  </xsl:if>
  </xsl:template> <!--* name=make-datatable *-->

  <!--* 
      * create entry for the datasets
      * - set up table structure and then process each dataset
      *-->
  <xsl:template match="datasets">

    <!--* set up the header for this section *-->
    <tr>
      <th colspan="4" align="center">Sorted by OBSID</th>
    </tr>
    <tr>
      <th align="center">OBSID</th>
      <th align="center">Object</th>
      <th align="center">Instrument</th> 
      <th align="center">Threads</th>
    </tr>  
    
    <!--* process the individual datasets *-->
    <xsl:apply-templates select="dataset"/>

  </xsl:template> <!--* match=datasets *-->

  <!--* 
      * create entry for a single dataset 
      *-->
  <xsl:template match="dataset">
    <tr>
      <td align="center">
	  <xsl:value-of select="@obsid"/>
      </td>
      <td align="center">
	<xsl:apply-templates select="object"/>
      </td>
      <td align="center">
	<xsl:apply-templates select="instrument"/>
      </td>
      <td align="center">
	<!--* loop over the threads *-->
	<xsl:for-each select="thread">
	  <xsl:if test="position()>1">, </xsl:if>
	  <xsl:apply-templates select="."/>
	</xsl:for-each>
      </td>
    </tr> 

    <!--* add a separator *-->
    <tr>
      <th colspan="4"><hr/></th>
    </tr>

  </xsl:template> <!--* match=dataset *-->

  <!--*
      * since we now copy over unknown nodes, we need explicit
      * rules for the items in a dataset node.
      * We just pass through the text (after processing it)
      *-->
  <xsl:template match="object|instrument|thread">
<xsl:apply-templates/>
  </xsl:template> <!--* name=object|instrument|thread *-->

  <!--* 
      * create entry for the packages
      * - set up table structure and then process each package
      *-->
  <xsl:template match="packages">

    <!--* set up the header for this section *-->
    <tr>
      <th colspan="4" align="center">Sorted by Thread</th>
    </tr>
    <tr>
      <th colspan="3" align="center">File</th>
      <th align="center">Thread</th>
    </tr>  

    <!--* process the individual packages *--> 
    <xsl:apply-templates select="package">
      <xsl:with-param name="depth" select="$depth"/>
    </xsl:apply-templates>
    
      
  </xsl:template> <!--* match=packages *-->

  <!--* 
      * create entry for a single package 
      *
      * note:
      * - assumes we are within the threads/ dir [for location of the data]
      *
      *-->
  <xsl:template match="package">
    <xsl:param name="depth" select="1"/>

    <tr>
      <td colspan="3" align="center">
	<tt>
	  <a href="data/{file}"><xsl:value-of select="file"/></a>
	</tt>
      </td>
      <td align="center">
	<xsl:choose>
	  <xsl:when test="count(descendant::p)=0">
	    <p>
	      <xsl:apply-templates select="text">
		<xsl:with-param name="depth" select="$depth"/>
	      </xsl:apply-templates>
	    </p>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:apply-templates select="text">
	      <xsl:with-param name="depth" select="$depth"/>
	    </xsl:apply-templates>
	  </xsl:otherwise>
	</xsl:choose>
      </td>
    </tr>

  </xsl:template> <!--* match=package *-->

  <!--*
      * create the "quick link" list of links
      * - somewhat of a mess since shoe-horning CIAO and Sherpa
      *   pages into the same template
      *
      *-->
  <xsl:template name="add-threadindex-quicklink">
    <div class="qlinkbar" align="center"><font size="-1">
	| <a href="index.html">Top</a> |
	<a href="all.html">All</a> |
	<!--* 
	    * note: use absolute xpath location here since not always
            * called with threadindex as its context node (eg datatable)
            * and assuming no depth-dependent text in the markup
            * - maybe shouldn't assume any markup in the text?
            *-->
	<xsl:for-each select="//threadindex/section/id">
	  <a href="{name}.html"><xsl:apply-templates select="text"/></a> | 
	</xsl:for-each>
	<!--* do we have a data table ? *-->
	<xsl:if test="boolean(//threadindex/datatable)">
	  <a href="table.html">Datasets</a>
	</xsl:if>
	<!--* sort out the separator: | if no external links, || if there are *-->
	<xsl:choose>
	  <xsl:when test="count(//threadindex/qlinks/qlink)!=0">
	    <xsl:text> || </xsl:text>
	    <!--* and now the "external" links *-->
	    <xsl:for-each select="//threadindex/qlinks/qlink">

	    <xsl:choose>
	      <xsl:when test="position() = last()">
	        <a href="{@href}"><xsl:value-of select="normalize-space(.)"/></a> 
	      </xsl:when>
	      <xsl:otherwise>
	        <a href="{@href}"><xsl:value-of select="normalize-space(.)"/></a> | 
	      </xsl:otherwise>
	    </xsl:choose>
	    </xsl:for-each>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:text> |</xsl:text>
	  </xsl:otherwise>
	</xsl:choose>
      </font></div>
    <hr/>
  </xsl:template> <!--* name=add-threadindex-quicklink *-->

  <!--* 
      * create the individual section pages
      *
      * requires:
      *   $install variable/parameter
      *-->
  <xsl:template match="section" mode="make-section">
    <xsl:param name="depth" select="1"/>

    <xsl:variable name="filename"><xsl:value-of select="$install"/><xsl:value-of select='id/name'/>.html</xsl:variable>
    <xsl:variable name="version" select="/threadindex/version"/>
    
    <!--* output filename to stdout *-->
    <xsl:value-of select="$filename"/><xsl:call-template name="newline"/>
    
    <!--* create document *-->
    <xsl:document href="{$filename}" method="html" media-type="text/html" 
      version="4.0" encoding="us-ascii">

      <!--* get the start of the document over with *-->
      <html lang="en">

	<xsl:call-template name="add-threadindex-start">
	  <xsl:with-param name="title"><xsl:value-of select="id/title"/> Threads<xsl:value-of select="concat(' - ',$headtitlepostfix)"/></xsl:with-param>
	  <xsl:with-param name="name" select="id/name"/>
	</xsl:call-template>

	<!--* use a table to provide the page layout *-->
	<table class="maintable" width="100%" border="0" cellspacing="2" cellpadding="2">
      
	  <tr>
	    <!--* add the navbar *-->
	    <xsl:call-template name="add-navbar">
	      <xsl:with-param name="name" select="//threadindex/navbar"/>
	    </xsl:call-template>
	  
	    <!--* the main text *-->
	    <td class="mainbar" valign="top">
	      
	      <!--* let the 'skip nav bar' have somewhere to skip to *-->
	      <a name="maintext"/>

	      <!--* set up the title block of the page *-->
	      <xsl:call-template name="add-threadindex-title">
		<xsl:with-param name="title" select="id/title"/>
	      </xsl:call-template>

	      <!--* do we have a synopsis? *-->
	      <xsl:apply-templates select="synopsis" mode="section-page">
		<xsl:with-param name="depth" select="$depth"/>
	      </xsl:apply-templates>

	      <!--* process the section *-->
	      <xsl:apply-templates select="." mode="section-page">
		<xsl:with-param name="depth" select="$depth"/>
	      </xsl:apply-templates>

	    </td>
	  </tr>
	</table>

	<!--* add the footer text *-->
	<xsl:call-template name="add-footer">
	  <xsl:with-param name="depth" select="$depth"/>
	  <xsl:with-param name="name"  select="id/name"/>
	</xsl:call-template>
      
	<!--* add end body/html tags *-->
	<xsl:call-template name="add-end-body"/>
      </html>

    </xsl:document>
  </xsl:template> <!--* match=section mode=make-section *-->

  <!--* create the hardcopy versions of the individual section pages *-->
  <xsl:template match="section" mode="make-section-hard">
    <xsl:param name="depth" select="1"/>

    <xsl:variable name="filename"><xsl:value-of select="$install"/><xsl:value-of select='id/name'/>.hard.html</xsl:variable>
    <xsl:variable name="version" select="/threadindex/version"/>

    <xsl:variable name="url"><xsl:value-of select="$urlhead"/><xsl:value-of select='id/name'/>.html</xsl:variable>
    
    <!--* output filename to stdout *-->
    <xsl:value-of select="$filename"/><xsl:call-template name="newline"/>
    
    <!--* create document *-->
    <xsl:document href="{$filename}" method="html" media-type="text/html" 
      version="4.0" encoding="us-ascii">

      <!--* we start processing the XML file here *-->
      <html lang="en">

	<!--* make the HTML head node *-->
	<xsl:call-template name="add-htmlhead">
	  <xsl:with-param name="title"><xsl:value-of select="id/title"/> Threads<xsl:value-of select="concat(' - ',$headtitlepostfix)"/></xsl:with-param>
	</xsl:call-template>

	<!--* and now the main part of the text *-->
	<body>

	  <xsl:call-template name="add-hardcopy-banner-top">
	    <xsl:with-param name="url" select="$url"/>
	  </xsl:call-template>

	  <!--* set up the title block of the page *-->
	  <xsl:call-template name="add-threadindex-title">
	    <xsl:with-param name="title" select="id/title"/>
	    <xsl:with-param name="hardcopy" select="1"/>
	  </xsl:call-template>

	  <!--* do we have a synopsis? *-->
	  <xsl:apply-templates select="synopsis" mode="section-page">
	    <xsl:with-param name="depth" select="$depth"/>
	  </xsl:apply-templates>

	  <!--* process the section *-->
	  <xsl:apply-templates select="." mode="section-page">
	    <xsl:with-param name="depth" select="$depth"/>
	  </xsl:apply-templates>

	  <br/><br/>

	  <xsl:call-template name="add-hardcopy-banner-bottom">
	    <xsl:with-param name="url" select="$url"/>
	  </xsl:call-template>

	</body>
      </html>

    </xsl:document>
  </xsl:template> <!--* match=section mode=make-section-hard *-->

  <!--*
      * create: table.html (the data table page)
      **-->
  <xsl:template match="threadindex" mode="make-table">
    <xsl:param name="depth" select="1"/>

    <xsl:variable name="filename"><xsl:value-of select="$install"/>table.html</xsl:variable>
    <xsl:variable name="version" select="/threadindex/version"/>
    
    <!--* output filename to stdout *-->
    <xsl:value-of select="$filename"/><xsl:call-template name="newline"/>
    
    <!--* create document *-->
    <xsl:document href="{$filename}" method="html" media-type="text/html" 
      version="4.0" encoding="us-ascii">

      <!--* get the start of the document over with *-->
      <html lang="en">

	<xsl:call-template name="add-threadindex-start">
	  <xsl:with-param name="title">Data for Threads<xsl:value-of select="concat(' - ',$headtitlepostfix)"/></xsl:with-param>
	  <xsl:with-param name="name">table</xsl:with-param>
	</xsl:call-template>

	<table class="maintable" width="100%" border="0" cellspacing="2" cellpadding="2">

	  <tr>
	    <!--* add the navbar *-->
	    <xsl:call-template name="add-navbar">
	      <xsl:with-param name="name" select="//threadindex/navbar"/>
	    </xsl:call-template>
	  
	    <!--* the main text *-->
	    <td class="mainbar" valign="top">
        
	      <!--* let the 'skip nav bar' have somewhere to skip to *-->
	      <a name="maintext"/>

	      <!-- set up the title block of the page -->
	      <xsl:call-template name="add-threadindex-title">
		<xsl:with-param name="title"><xsl:choose>
		    <xsl:when test="$site='ciao'">Data for CIAO <xsl:value-of select="$siteversion"/> Threads</xsl:when>
		    <xsl:when test="$site='sherpa'">Data for Sherpa Threads (CIAO <xsl:value-of select="$siteversion"/>)</xsl:when>
		    <xsl:otherwise>Data for Threads</xsl:otherwise>
		  </xsl:choose></xsl:with-param>
	      </xsl:call-template>

	      <!--* add the data table *-->
	      <xsl:call-template name="make-datatable">
		<xsl:with-param name="depth" select="$depth"/>
	      </xsl:call-template>

	    </td>
	  </tr>
	</table>

	<!--* add the footer text *-->
	<xsl:call-template name="add-footer">
	  <xsl:with-param name="depth" select="$depth"/>
	  <xsl:with-param name="name"  select="'table'"/>
	</xsl:call-template>
      
	<!--* add end body/html tags *-->
	<xsl:call-template name="add-end-body"/>
      </html>

    </xsl:document>
  </xsl:template> <!--* match=threadindex mode=make-table *-->

  <!--*
      * create: table.hard.html
      **-->
  <xsl:template match="threadindex" mode="make-table-hard">
    <xsl:param name="depth" select="1"/>

    <xsl:variable name="filename"><xsl:value-of select="$install"/>table.hard.html</xsl:variable>
    <xsl:variable name="version" select="/threadindex/version"/>

    <xsl:variable name="url"><xsl:value-of select="$urlhead"/>table.html</xsl:variable>
    
    <!--* output filename to stdout *-->
    <xsl:value-of select="$filename"/><xsl:call-template name="newline"/>
    
    <!--* create document *-->
    <xsl:document href="{$filename}" method="html" media-type="text/html" 
      version="4.0" encoding="us-ascii">

      <!--* we start processing the XML file here *-->
      <html lang="en">

	<!--* make the HTML head node *-->
	<xsl:call-template name="add-htmlhead">
	  <xsl:with-param name="title">Data for Threads<xsl:value-of select="concat(' - ',$headtitlepostfix)"/></xsl:with-param>
	</xsl:call-template>

	<!--* and now the main part of the text *-->
	<body>

	  <xsl:call-template name="add-hardcopy-banner-top">
	    <xsl:with-param name="url" select="$url"/>
	  </xsl:call-template>

	  <!-- set up the title block of the page -->
	  <h1 align="center">Data for CIAO <xsl:value-of select="$siteversion"/> Science Threads</h1>

	  <!--* add the data table *-->
	  <xsl:call-template name="make-datatable">
	    <xsl:with-param name="depth" select="$depth"/>
	  </xsl:call-template>

	  <xsl:call-template name="add-hardcopy-banner-bottom">
	    <xsl:with-param name="url" select="$url"/>
	  </xsl:call-template>

	</body>
      </html>

    </xsl:document>
  </xsl:template> <!--* match=threadindex mode=make-table-hard *-->

  <!--* 
      * create: index.html 
      *-->
  <xsl:template match="threadindex" mode="make-index">
    <xsl:param name="depth" select="1"/>

    <xsl:variable name="filename"><xsl:value-of select="$install"/>index.html</xsl:variable>

    <!--* output filename to stdout *-->
    <xsl:value-of select="$filename"/><xsl:call-template name="newline"/>
    
    <!--* create document *-->
    <xsl:document href="{$filename}" method="html" media-type="text/html" 
      version="4.0" encoding="us-ascii">

      <!--* get the start of the document over with *-->
      <html lang="en">

	<xsl:call-template name="add-threadindex-start">
	  <xsl:with-param name="title"><xsl:if test="$site='sherpa'">Sherpa </xsl:if>Threads<xsl:value-of select="concat(' - ',$headtitlepostfix)"/></xsl:with-param>
	  <xsl:with-param name="name">index</xsl:with-param>
	</xsl:call-template>

	<!--* use a table to provide the page layout *-->
	<table class="maintable" width="100%" border="0" cellspacing="2" cellpadding="2">

	  <tr>
	    <!--* add the navbar *-->
	    <xsl:call-template name="add-navbar">
	      <xsl:with-param name="name" select="//threadindex/navbar"/>
	    </xsl:call-template>

	    <!--* the main text *-->
	    <td class="mainbar" valign="top">

	      <!--* let the 'skip nav bar' have somewhere to skip to *-->
	      <a name="maintext"/>

	      <!-- set up the title block of the page -->
	      <xsl:call-template name="add-threadindex-title"/>

	      <!--* include the header text *-->
	      <xsl:apply-templates select="header">
		<xsl:with-param name="depth" select="$depth"/>
	      </xsl:apply-templates>

	      <!--*
	          * prior to CIAO 3.1 (v1.21 of this stylesheet) we used to
	          * use a dl to split up the sections.
	          *-->
	      <div class="threadindex">

		<div class="threadsection">
		  <h3><a href="all.html"><em>All</em> threads</a></h3>
		  <div class="threadsnopsis">
		    <p>A list of all the threads on one page.</p>
		  </div>
		</div>
		
		<!--* process the sections in the index *-->
		<xsl:apply-templates select="section" mode="index-page">
		  <xsl:with-param name="depth" select="$depth"/>
		</xsl:apply-templates>
          
		<!--* do we have a data table? *-->
		<xsl:if test="boolean(//threadindex/datatable)">
		  <div class="threadsection">
		    <h3><a href="table.html">Datasets</a></h3>
		    <div class="threadsynopsis">
		      <p>Links to the datasets used in the threads.</p>
		    </div>
		  </div>
		</xsl:if>

	      </div>
	      <br/>

	    </td>
	  </tr>
	</table>

	<!--* add the footer text *-->
	<xsl:call-template name="add-footer">
	  <xsl:with-param name="depth" select="$depth"/>
	  <xsl:with-param name="name"  select="'index'"/>
	</xsl:call-template>

	<!--* add end body/html tags *-->
	<xsl:call-template name="add-end-body"/>
      </html>

    </xsl:document>
  </xsl:template> <!--* match=threadindex mode=make-index *-->

  <!--* 
      * create: index.hard.html 
      *-->
  <xsl:template match="threadindex" mode="make-index-hard">
    <xsl:param name="depth" select="1"/>

    <xsl:variable name="filename"><xsl:value-of select="$install"/>index.hard.html</xsl:variable>
    <xsl:variable name="version" select="/threadindex/version"/>

    <xsl:variable name="url"><xsl:value-of select="$urlhead"/>index.html</xsl:variable>
    
    <!--* output filename to stdout *-->
    <xsl:value-of select="$filename"/><xsl:call-template name="newline"/>
    
    <!--* create document *-->
    <xsl:document href="{$filename}" method="html" media-type="text/html" 
      version="4.0" encoding="us-ascii">

      <!--* we start processing the XML file here *-->
      <html lang="en">

	<!--* make the HTML head node *-->
	<xsl:call-template name="add-htmlhead">
	  <xsl:with-param name="title"><xsl:if test="$site='sherpa'">Sherpa </xsl:if>Threads<xsl:value-of select="concat(' - ',$headtitlepostfix)"/></xsl:with-param>
	</xsl:call-template>

	<!--* and now the main part of the text *-->
	<body>

	  <xsl:call-template name="add-hardcopy-banner-top">
	    <xsl:with-param name="url" select="$url"/>
	  </xsl:call-template>

	  <!-- set up the title block of the page -->
	  <xsl:call-template name="add-threadindex-title">
	    <xsl:with-param name="hardcopy" select="1"/>
	  </xsl:call-template>

	  <!--* include the header text *-->
	  <xsl:apply-templates select="header">
	    <xsl:with-param name="depth" select="$depth"/>
	  </xsl:apply-templates>

	  <div class="threadindex">
	    <div class="threadsection">
	      <h3><a href="all.html"><em>All</em> threads</a></h3>
	      <div class="threadsynopsis">
		<p>
		  A list of all the threads on one page.
		</p>
	      </div>
	    </div>
		
	    <!--* process the sections in the index *-->
	    <xsl:apply-templates select="section" mode="index-page">
	      <xsl:with-param name="depth" select="$depth"/>
	    </xsl:apply-templates>
	    
	    <!--* do we have a data table? *-->
	    <xsl:if test="boolean(//threadindex/datatable)">
	      <div class="threadsection">
		<h3><a href="table.html">Datasets</a></h3>
		<div class="threadsynopsis">
		  <p>
		    Links to the datasets used in the threads.
		  </p>
		</div>
	      </div>
	    </xsl:if>
	    
	  </div>
	  <br/>

	  <xsl:call-template name="add-hardcopy-banner-bottom">
	    <xsl:with-param name="url" select="$url"/>
	  </xsl:call-template>

	</body>
      </html>

    </xsl:document>
  </xsl:template> <!--* match=threadindex mode=make-index-hard *-->

  <!--* 
      * create: all.html 
      *-->
  <xsl:template match="threadindex" mode="make-all">
    <xsl:param name="depth" select="1"/>

    <xsl:variable name="filename"><xsl:value-of select="$install"/>all.html</xsl:variable>
    <xsl:variable name="version" select="/threadindex/version"/>
    
    <!--* output filename to stdout *-->
    <xsl:value-of select="$filename"/><xsl:call-template name="newline"/>
    
    <!--* create document *-->
    <xsl:document href="{$filename}" method="html" media-type="text/html" 
      version="4.0" encoding="us-ascii">

      <!--* get the start of the document over with *-->
      <html lang="en">

	<xsl:call-template name="add-threadindex-start">
	  <xsl:with-param name="title">All Threads<xsl:value-of select="concat(' - ',$headtitlepostfix)"/></xsl:with-param>
	  <xsl:with-param name="name">all</xsl:with-param>
	</xsl:call-template>

	<!--* use a table to provide the page layout *-->
	<table class="maintable" width="100%" border="0" cellspacing="2" cellpadding="2">
	  
	  <tr>
	    <!--* add the navbar *-->
	    <xsl:call-template name="add-navbar">
	      <xsl:with-param name="name" select="//threadindex/navbar"/>
	    </xsl:call-template>
      
	    <!--* the main text *-->
	    <td class="mainbar" valign="top">
	      
	      <!--* let the 'skip nav bar' have somewhere to skip to *-->
	      <a name="maintext"/>

	      <!-- set up the title block of the page -->
	      <xsl:call-template name="add-threadindex-title"/>

	      <!--* process the sections in the index *-->
	      <div class="threadindex">
		<xsl:apply-templates select="section" mode="all-page">
		  <xsl:with-param name="depth" select="$depth"/>
		</xsl:apply-templates>
	      </div>

	      <br/><br/>

	      <!--* add the data table *-->
	      <xsl:call-template name="make-datatable">
		<xsl:with-param name="depth" select="$depth"/>
	      </xsl:call-template>
	  
	    </td>
	  </tr>
	</table>

	<!--* add the footer text *-->
	<xsl:call-template name="add-footer">
	  <xsl:with-param name="depth" select="$depth"/>
	  <xsl:with-param name="name"  select="'all'"/>
	</xsl:call-template>
      
	<!--* add end body/html tags *-->
	<xsl:call-template name="add-end-body"/>
      </html>
      
    </xsl:document>
  </xsl:template> <!--* match=threadindex mode=make-all *-->

  <!--* 
      * create: all.hard.html 
      *-->
  <xsl:template match="threadindex" mode="make-all-hard">
    <xsl:param name="depth" select="1"/>

    <xsl:variable name="filename"><xsl:value-of select="$install"/>all.hard.html</xsl:variable>
    <xsl:variable name="version" select="/threadindex/version"/>

    <xsl:variable name="url"><xsl:value-of select="$urlhead"/>all.html</xsl:variable>
    
    <!--* output filename to stdout *-->
    <xsl:value-of select="$filename"/><xsl:call-template name="newline"/>
    
    <!--* create document *-->
    <xsl:document href="{$filename}" method="html" media-type="text/html" 
      version="4.0" encoding="us-ascii">

      <!--* we start processing the XML file here *-->
      <html lang="en">

	<!--* make the HTML head node *-->
	<xsl:call-template name="add-htmlhead">
	  <xsl:with-param name="title">All Threads<xsl:value-of select="concat(' - ',$headtitlepostfix)"/></xsl:with-param>
	</xsl:call-template>

	<!--* and now the main part of the text *-->
	<body>

	  <xsl:call-template name="add-hardcopy-banner-top">
	    <xsl:with-param name="url" select="$url"/>
	  </xsl:call-template>

	  <!-- set up the title block of the page -->
	  <xsl:call-template name="add-threadindex-title">
	    <xsl:with-param name="hardcopy" select="1"/>
	  </xsl:call-template>
	  
	  <!--* process the sections in the index *-->
	  <div class="threadindex">
	    <xsl:apply-templates select="section" mode="all-page">
	      <xsl:with-param name="depth" select="$depth"/>
	    </xsl:apply-templates>
	  </div>

	  <br/><br/>

	  <!--* add the data table *-->
	  <xsl:call-template name="make-datatable">
	    <xsl:with-param name="depth" select="$depth"/>
	  </xsl:call-template>

	  <xsl:call-template name="add-hardcopy-banner-bottom">
	    <xsl:with-param name="url" select="$url"/>
	  </xsl:call-template>

	</body>
      </html>

    </xsl:document>
  </xsl:template> <!--* match=threadindex mode=make-all-hard *-->

  <!--*
      * create the start of an index page
      *
      * Parameters:
      *   title - title of page (appears in head block so should be concise)
      *   name  - name of page (w/out .html); pdf files called $name.[a4|letter].pdf
      *
      * NOTE:
      *  we *NO LONGER* create a html tag but we do create a BODY tag; ugh!
      *-->
  <xsl:template name="add-threadindex-start">
    <xsl:param name="title" select="'Threads'"/>
    <xsl:param name="name"  select="''"/>

    <!--* safety check *-->
    <xsl:if test="$name=''">
      <xsl:message terminate="yes">
 Error: add-threadindex-start called with no name attribute
      </xsl:message>
    </xsl:if>

    <!--* make the HTML head node *-->
    <xsl:call-template name="add-htmlhead">
      <xsl:with-param name="title" select="$title"/>
    </xsl:call-template>

    <!--* add disclaimer about editing thie HTML file *-->
    <xsl:call-template name="add-disclaimer"/>

    <!--* make the header *-->
    <xsl:call-template name="add-header">
      <xsl:with-param name="name" select="$name"/>
    </xsl:call-template>

  </xsl:template> <!--* name=add-threadindex-start *-->

  <!--* 
      * handle a section - for the index page
      * - we output the contents of the synopsis section here
      * - up to CIAO 3.0 we used to explicitly list the new/changed threads
      *   but we now (due to all the extra text) just indicate that some threads
      *   have changed in the section
      *-->
  <xsl:template match="section" mode="index-page">
    <xsl:param name="depth" select="1"/>

    <div class="threadsection">
      <!--* for CIAO 3.1 we added the new/updated images into the header *-->
      <h3><a href="{id/name}.html"><xsl:apply-templates select="title" mode="show"/></a><xsl:call-template name="report-if-new-or-updated-threads-icons"/></h3>

      <!--*
          * for CIAO 3.1 have decided not to include the number of
          * threads as it is hard to get it to look right
          *
      <xsl:call-template name="report-if-new-or-updated-threads"/>
          *
          *-->

      <!--*
          * If there's a synopsis section then include it
          *-->
      <xsl:apply-templates select="synopsis" mode="index-page">
	<xsl:with-param name="depth" select="$depth"/>
      </xsl:apply-templates>

    </div> <!--* class=threadsection *-->

  </xsl:template> <!--* match=section mode=index-page *-->

  <!--*
      * report if any new or updated threads are in this section
      * 
      * Prior to CIAO 3.1 we included the number of threads and
      * icons to flag the sections. The new CIAO 3.1 layout makes
      * this a bit more cumbersome (due to the use of actual header
      * elements). We could probably come up with a scheme using CSS
      * but it is easier just to drop the reporting of the number of
      * threads (just leave the icons)
      * 
      * - all we say is "6 new, 4 updated"
      * - would like to include a date but that looks like it's
      *   going to be hard to do in this system
      *
      *-->
  <xsl:template name="report-if-new-or-updated-threads">
    <xsl:variable name="threads" select=".//item[boolean(@name)]"/>

    <!--* return a string of u and n's for updated and new threads *-->
    <xsl:variable name="state"><xsl:apply-templates select="$threads" mode="report-if-new-or-updated-threads"/></xsl:variable>
    <xsl:variable name="nnew"><xsl:value-of select="string-length(normalize-space(translate($state,'u','')))"/></xsl:variable>
    <xsl:variable name="nupd"><xsl:value-of select="string-length(normalize-space(translate($state,'n','')))"/></xsl:variable>

    <xsl:if test="$nnew != 0 or $nupd != 0">
      <!--* add a header with the info *-->
      <h4><xsl:choose>
	  <xsl:when test="$nnew != 0 and $nupd != 0">
	    <xsl:value-of select="concat($nnew,' New &amp; ',$nupd,' Updated threads ')"/>
	  </xsl:when>
	  <xsl:when test="$nnew &gt; 1">
	    <xsl:value-of select="concat($nnew,' New threads ')"/>
	  </xsl:when>
	  <xsl:when test="$nnew = 1">
	    <xsl:value-of select="concat($nnew,' New thread ')"/>
	  </xsl:when>
	  <xsl:when test="$nupd &gt; 1">
	    <xsl:value-of select="concat($nupd,' Updated threads')"/>
	  </xsl:when>
	  <xsl:when test="$nupd = 1">
	    <xsl:value-of select="concat($nupd,' Updated thread')"/>
	  </xsl:when>
	</xsl:choose></h4>
    </xsl:if>
  </xsl:template> <!--* name=report-if-new-or-updated-threads *-->

  <xsl:template name="report-if-new-or-updated-threads-icons">
    <xsl:variable name="threads" select=".//item[boolean(@name)]"/>

    <!--* return a string of u and n's for updated and new threads *-->
    <xsl:variable name="state"><xsl:apply-templates select="$threads" mode="report-if-new-or-updated-threads"/></xsl:variable>
    <xsl:variable name="nnew"><xsl:value-of select="string-length(normalize-space(translate($state,'u','')))"/></xsl:variable>
    <xsl:variable name="nupd"><xsl:value-of select="string-length(normalize-space(translate($state,'n','')))"/></xsl:variable>

    <!--* do we add the images? *-->
    <xsl:if test="$nnew != 0">
      <xsl:call-template name="add-new-image">
	<xsl:with-param name="depth" select="$depth"/>
      </xsl:call-template>
    </xsl:if>

    <xsl:if test="$nupd != 0">
      <xsl:call-template name="add-updated-image">
	<xsl:with-param name="depth" select="$depth"/>
      </xsl:call-template>
    </xsl:if>

  </xsl:template> <!--* name=report-if-new-or-updated-threads-icons *-->

  <!--*
      * "returns" a u if the thread is updated, n if it is new, nothing otherwise
      *
      *-->
  <xsl:template match="item" mode="report-if-new-or-updated-threads">
    <xsl:variable name="ThreadInfo" select="document(concat($threadDir,@name,'/thread.xml'))/thread/info"/>

    <xsl:choose>
      <xsl:when test="$ThreadInfo/history[@new=1]"><xsl:text>n</xsl:text></xsl:when>
      <xsl:when test="$ThreadInfo/history[@updated=1]"><xsl:text>u</xsl:text></xsl:when>
    </xsl:choose>
  </xsl:template> <!--* match=item mode=report-if-new-or-updated-threads *-->

  <!--* a new thread *-->
  <xsl:template match="item" mode="list-new">
    <xsl:param name="depth" select="1"/>

    <xsl:variable name="ThreadInfo" select="document(concat($threadDir,@name,'/thread.xml'))/thread/info"/>

    <xsl:if test="$ThreadInfo/history[@new=1]">
      <li>
	<a href="{$ThreadInfo/name}/"><xsl:value-of select="$ThreadInfo/title/long"/></a>
	<xsl:apply-templates select="$ThreadInfo/history" mode="date"/>
	<xsl:call-template name="add-new-image">
	  <xsl:with-param name="depth" select="$depth"/>
	</xsl:call-template>
      </li>
    </xsl:if>
  </xsl:template> <!--* item mode=list-new *-->

  <!--* an updated thread *-->
  <xsl:template match="item" mode="list-updated">
    <xsl:variable name="ThreadInfo" select="document(concat($threadDir,@name,'/thread.xml'))/thread/info"/>
    <xsl:if test="$ThreadInfo/history[@updated=1]">
      <li>
	<a href="{$ThreadInfo/name}/"><xsl:value-of select="$ThreadInfo/title/long"/></a>
	<xsl:apply-templates select="$ThreadInfo/history" mode="date"/>
	<xsl:call-template name="add-updated-image">
	  <xsl:with-param name="depth" select="$depth"/>
	</xsl:call-template>
      </li>
    </xsl:if>
  </xsl:template> <!--* item mode=list-updated *-->

  <!--*
      * handle a section: for all-in-one page
      * 
      *-->
  <xsl:template match="section" mode="all-page">

    <div class="threadsection">
      <h3><a name="{@name}"><xsl:apply-templates select="title" mode="show">
	    <xsl:with-param name="depth" select="$depth"/>
	  </xsl:apply-templates></a></h3>

      <!--* synopsis? *-->
      <xsl:apply-templates select="synopsis" mode="section-page">
	<xsl:with-param name="depth" select="$depth"/>
      </xsl:apply-templates>
	
      <!--* list the threads *-->
      <xsl:apply-templates select="list" mode="threadindex">
	<xsl:with-param name="depth" select="$depth"/>
      </xsl:apply-templates>
      <br/>
    </div> <!--* class=threadsection *-->

  </xsl:template> <!--* match=section mode=all-page *-->

  <!--*
      * handle a section: for individual section pages
      * 
      *-->
  <xsl:template match="section" mode="section-page">
    <xsl:param name="depth" select="1"/>

    <xsl:apply-templates select="list" mode="threadindex">
      <xsl:with-param name="depth" select="$depth"/>
    </xsl:apply-templates>

  </xsl:template> <!--* match=section mode=section-page *-->

  <!--*
      * process the header block
      *-->
  <xsl:template match="header">
    <xsl:apply-templates>
      <xsl:with-param name="depth" select="$depth"/>
    </xsl:apply-templates>
  </xsl:template> <!--* match=header *-->

  <!--*
      * adds a "title" which depends on the site
      * 
      * Params:
      *   title, string, optional
      *     title to use, otherwise guesses one bnased on the site
      * 
      *   hardcopy, 0 or 1, defaults to 0
      *     is this a hardcopy (PDF) or web page?
      * 
      *-->
  <xsl:template name="add-threadindex-title">
    <xsl:param name="title" select="''"/>
    <xsl:param name="hardcopy" select="0"/>

    <h1 align="center"><xsl:choose>
	<xsl:when test="$title = ''"><xsl:choose>
	    <xsl:when test="$site = 'ciao'">Science</xsl:when>
	    <xsl:when test="$site = 'sherpa'">Sherpa</xsl:when>
	    <xsl:when test="$site = 'chips'">ChIPS</xsl:when>
	  </xsl:choose><xsl:value-of select="concat(' ',$ciaothreadver)"/></xsl:when>
	<xsl:otherwise><xsl:value-of select="$title"/></xsl:otherwise>
      </xsl:choose></h1>

    <!--* create the list of section links *-->
    <xsl:if test="$hardcopy = 0">
      <xsl:call-template name="add-whatsnew-link"/>
      <xsl:call-template name="add-threadindex-quicklink"/>
    </xsl:if>
  </xsl:template> <!--* name=add-threadindex-title *-->

  <!--*
      * display the synopsis section from the thread index
      * we use modes to disambiguate from the other occurences
      * of a synopsis tag
      *-->
  <xsl:template match="synopsis" mode="index-page">
    <div class="threadsynopsis">
      <xsl:apply-templates>
	<xsl:with-param name="depth" select="$depth"/>
      </xsl:apply-templates>
    </div>
  </xsl:template> <!--* match=synopsis mode=index-page *-->
  
  <xsl:template match="synopsis" mode="section-page">
    <div class="threadsynopsis">
      <xsl:apply-templates>
	<xsl:with-param name="depth" select="$depth"/>
      </xsl:apply-templates>
    </div>
  </xsl:template> <!--* match=synopsis mode=section-page *-->
  
</xsl:stylesheet>
