<?xml version="1.0" encoding="UTF-8"?>
<!--
	Post-processes solr records coming from the SUB Harvesting Solr server.

	2012 Sven-S. Porst, SUB Göttingen <porst@sub.uni-goettingen.de>
-->

<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:pz="http://www.indexdata.com/pazpar2/1.0">

	<xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

        <xsl:variable name="isbn13">
           <!-- list of ISBN-13 -->
           <xsl:for-each select="pz:metadata[@type='isbn']">
               <xsl:if test="string-length(translate(.,'-',''))=13">
                   <xsl:value-of select="concat(translate(.,'-',''),';')"/>
               </xsl:if>
           </xsl:for-each>
        </xsl:variable>

	<xsl:template match="pz:metadata[@type='author-letter']">
		<pz:metadata type="author">
			<xsl:choose>
				<xsl:when test="contains(., ';')">
					<xsl:value-of select="normalize-space(substring-before(., ';'))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</pz:metadata>
                <xsl:if test="contains(../pz:metadata[@type='format'],'Book') or 
contains(../pz:metadata[@type='format'],'eBook')">
	        <!-- Boosting for book and ebook -->
                <pz:metadata type="author-boost">
			<xsl:choose>
				<xsl:when test="contains(., ';')">
					<xsl:value-of select="normalize-space(substring-before(., ';'))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		   </pz:metadata>
                </xsl:if>
	</xsl:template>

        <xsl:template match="pz:metadata[@type='physical']">
            <pz:metadata type="physical-extent">
	        <xsl:value-of select="."/>
            </pz:metadata>
            <xsl:if test="../pz:metadata[@type='media']='druck'">
                <pz:metadata type="pages-number">
                        <!-- only numerical content!   -->
                        <xsl:value-of select="number(substring-before(concat(normalize-space(translate(.,
'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.-;:_!§%()=?[]',
'                                                                   ')),' '),' '))"/>          
                </pz:metadata>
            </xsl:if>
        </xsl:template>

	<xsl:template match="pz:metadata[@type='author2Str']">
		<pz:metadata type="other-person">
			<xsl:choose>
				<xsl:when test="contains(., ';')">
					<xsl:value-of select="normalize-space(substring-before(., ';'))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</pz:metadata>
	</xsl:template>

	<xsl:template match="pz:metadata[@type='title_short']">
		<pz:metadata type="title">
			<xsl:value-of select="."/>
		</pz:metadata>

                <xsl:if test="contains(../pz:metadata[@type='format'],'Book') or 
contains(../pz:metadata[@type='format'],'eBook')">
	           <!-- Boosting for book and ebook -->
		   <pz:metadata type="book-title">
			<xsl:value-of select="."/>
		   </pz:metadata>
                </xsl:if>
	</xsl:template>

	<xsl:template match="pz:metadata[@type='title_sub']">
		<pz:metadata type="title-remainder">
			<xsl:value-of select="."/>
		</pz:metadata>
	</xsl:template>

	<xsl:template match="pz:metadata[@type='title_fullStr']">
		<pz:metadata type="title-responsibility">
			<xsl:value-of select="substring-after(.,' / ')"/>
		</pz:metadata>
	</xsl:template>

	<xsl:template match="pz:metadata[@type='title']">
        </xsl:template>

	<xsl:template match="pz:metadata[@type='topic']">
            <xsl:if test="string-length() &gt; 1">
		<pz:metadata type="subject">
			<xsl:value-of select="."/>
		</pz:metadata>

                <xsl:if test="contains(../pz:metadata[@type='format'],'Book') or 
contains(../pz:metadata[@type='format'],'eBook')">
	           <!-- Boosting for book and ebook -->
		   <pz:metadata type="subject-boost">
			<xsl:value-of select="."/>
		   </pz:metadata>
                </xsl:if>
            </xsl:if>
	</xsl:template>

	<xsl:template match="pz:metadata[@type='publisher']">
		<pz:metadata type="publication-name">
			<xsl:value-of select="."/>
		</pz:metadata>
	</xsl:template>

	<xsl:template match="pz:metadata[@type='publishDate']">
		<pz:metadata type="date">
			<xsl:value-of select="."/>
		</pz:metadata>
	</xsl:template>

	<xsl:template match="pz:metadata[@type='publishPlace']">
		<pz:metadata type="publication-place">
			<xsl:value-of select="."/>
		</pz:metadata>
	</xsl:template>

	<!-- dodgy: this is formatted journal information, we’d prefer proper journal information -->
	<xsl:template match="pz:metadata[@type='source']">
		<pz:metadata type="journal-title">
			<xsl:value-of select="."/>
		</pz:metadata>
	</xsl:template>


	<xsl:template match="pz:metadata[@type='format']">

		<pz:metadata type="medium">
			<xsl:choose>
				<xsl:when test=".='Article'">article</xsl:when>

				<xsl:when test=".='Journal' or .='Newspaper'">journal</xsl:when>

				<xsl:when test=".='eJournal'">ejournal</xsl:when>

                                <xsl:when test=".='Dissertation'">diss</xsl:when> 
                                
                                <xsl:when test=".='Book'">book</xsl:when>

				<xsl:when test=".='eBook'">ebook</xsl:when>

				<xsl:when test=".='Musical Score' or .='Audio'
                                or .='Cassette'">audio</xsl:when>
				
                                <xsl:when test=".='Software' 
                                or .='Microfilm'">datamed</xsl:when>

				<xsl:when test=".='Video' or .='VHS'">video</xsl:when>

                                <xsl:when test=".='Map' or .='Slide'
                                or .='Photo'">map</xsl:when>

                                <xsl:when test=".='Kit' or .='Braille'
                                or .='Physical Object' or .='Electronic'
                                or .='Manuscript'
                                or .='Serial'">other</xsl:when>

                                <xsl:when test=".='CD' or .='DVD'">
                                  <xsl:choose>
                                  <xsl:when test="../pz:metadata[@type='content']='vide'">video</xsl:when>
                                  <xsl:when test="../pz:metadata[@type='content']='muto'">audio</xsl:when>
                                  <xsl:otherwise>datamed</xsl:otherwise>
                                  </xsl:choose>
                                </xsl:when>

                                <xsl:otherwise>
								  <xsl:choose>
                                  <xsl:when test="../pz:metadata[@type='content']='gkko'">proceeding</xsl:when>
								  <xsl:otherwise>other</xsl:otherwise>
                                  </xsl:choose>
                                </xsl:otherwise>
				<!-- unclean: keep original media type string -->
			</xsl:choose>
		</pz:metadata>
	</xsl:template>

	<xsl:template match="pz:metadata[@type='isbn']">
          <!-- if necessary: Generation of ISBN-13 -->
          <xsl:for-each select=".">
          <xsl:if test="string-length(translate(.,'-',''))=10">
            <xsl:variable name="isbnt">
               <xsl:value-of select="concat(normalize-space(translate(.,'-','')),';')"/>
            </xsl:variable>
            <xsl:if test="not(contains($isbn13,concat('978',substring($isbnt,1,9),(10-(38+number(substring($isbnt,1,1))*3+number(substring($isbnt,2,1))+
number(substring($isbnt,3,1))*3+number(substring($isbnt,4,1))+ number(substring($isbnt,5,1))*3+number(substring($isbnt,6,1))+
number(substring($isbnt,7,1))*3+number(substring($isbnt,8,1))+ number(substring($isbnt,9,1))*3)mod 10)mod 10)))">
             <pz:metadata type="isbn">
                <xsl:value-of select="concat('978',substring($isbnt,1,9),(10-(38+number(substring($isbnt,1,1))*3+number(substring($isbnt,2,1))+
number(substring($isbnt,3,1))*3+number(substring($isbnt,4,1))+ number(substring($isbnt,5,1))*3+number(substring($isbnt,6,1))+
number(substring($isbnt,7,1))*3+number(substring($isbnt,8,1))+ number(substring($isbnt,9,1))*3)mod 10)mod 10)"/>
             </pz:metadata>
            </xsl:if>
          </xsl:if>
          <xsl:if test="string-length(translate(.,'-',''))=13">
            <pz:metadata type="isbn">
                <xsl:value-of select="translate(.,'-','')"/>
            </pz:metadata>
          </xsl:if>
         </xsl:for-each>
        </xsl:template>

	<xsl:template match="pz:metadata[@type='id']">
            <!-- id contains prefix 'BSZ' folowwed by PPN -->
            <pz:metadata type="id">
               <xsl:value-of select="."/>
            </pz:metadata>
            <pz:metadata type="available">
               <xsl:value-of select="concat('http://daia-ibs.bsz-bw.de/isil/DE-21?format=xml&amp;id=ppn:',substring(.,4))"/>
            </pz:metadata>
            <pz:metadata type="avdata">
               <xsl:value-of select="concat('https://daia.ibs-bw.de/isil/DE-21?format=xml&amp;id=ppn:',substring(.,4))"/>
            </pz:metadata>
        </xsl:template>

	<xsl:template match="pz:metadata[@type='multipart_link']">
                <!-- consists of "(<isil>)" followed by isil -->
		<pz:metadata type="parent-id">
			<xsl:value-of select="."/>
		</pz:metadata>
	</xsl:template>

	<xsl:template match="pz:metadata[@type='series2']">
		<pz:metadata type="series-title">
			<xsl:value-of select="."/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="substring-after(../pz:metadata[@type='multipart_part'],')')"/>
		</pz:metadata>
	</xsl:template>

	<xsl:template match="pz:metadata[@type='url']">
		<pz:metadata type="electronic-url">
			<xsl:value-of select="."/>
		</pz:metadata>
	</xsl:template>

	<xsl:template match="pz:metadata[@type='rvk-notation']">
            <pz:metadata type="department">
               <xsl:choose>
                <xsl:when test="starts-with(.,'LE') or
                 starts-with(.,'LF') or
                 starts-with(.,'LG')">
                 <!-- Archaelogie -->
                 <xsl:value-of select="'10'"/>
                </xsl:when>
                <!-- xsl:when test="starts-with(.,'W')">
                 <xsl:value-of select="'20'"/>
                 <Spaeter wg. Medizin: Biologie >
                </xsl:when-->
                <xsl:when test="starts-with(.,'AN')">
                 <xsl:value-of select="'30'"/>
                 <!-- Buch- und Informationswissenschaft -->
                </xsl:when>
                <xsl:when test="starts-with(.,'V')">
                 <xsl:value-of select="'40'"/>
                 <!-- Chemie -->
                </xsl:when>
                <xsl:when test="starts-with(.,'LA') or
                 starts-with(.,'LB') or
                 starts-with(.,'LC')">
                 <xsl:value-of select="'50'"/>
                 <!-- Ethnologie -->
                </xsl:when>
                <xsl:when test="starts-with(.,'R')">
                 <xsl:value-of select="'60'"/>
                 <!-- Geographie -->
                </xsl:when>
                <xsl:when test="starts-with(.,'TE') or
                 starts-with(.,'TF') or
                 starts-with(.,'TG') or
                 starts-with(.,'TH') or
                 starts-with(.,'TI') or
                 starts-with(.,'TJ') or
                 starts-with(.,'TK') or
                 starts-with(.,'TL') or
                 starts-with(.,'TM') or
                 starts-with(.,'TN') or
                 starts-with(.,'TO') or
                 starts-with(.,'TP') or
                 starts-with(.,'TQ') or
                 starts-with(.,'TR') or
                 starts-with(.,'TS') or
                 starts-with(.,'TT') or
                 starts-with(.,'TU') or
                 starts-with(.,'TV') or
                 starts-with(.,'TW') or
                 starts-with(.,'TX') or
                 starts-with(.,'TY') or
                 starts-with(.,'TZ')">
                 <xsl:value-of select="'70'"/>
                 <!-- Geologie -->
                </xsl:when>
                <xsl:when test="starts-with(.,'N')">
                 <xsl:value-of select="'80'"/>
                 <!-- Geschichte -->
                </xsl:when>
                <xsl:when test="starts-with(.,'SQ') or
                 starts-with(.,'SR') or
                 starts-with(.,'SS') or
                 starts-with(.,'ST') or
                 starts-with(.,'SU')">
                 <xsl:value-of select="'90'"/>
                 <!-- Informatik -->
                </xsl:when>
                <!-- xsl:when test="starts-with(.,'')">
                 <xsl:value-of select="'100'"/>
                 <xsl:text Kunst (fehlt bei SWB) />
                </xsl:when-->
                <xsl:when test="starts-with(.,'SA') or
                 starts-with(.,'SB') or
                 starts-with(.,'SC') or
                 starts-with(.,'SD') or
                 starts-with(.,'SE') or
                 starts-with(.,'SF') or
                 starts-with(.,'SG') or
                 starts-with(.,'SH') or
                 starts-with(.,'SI') or
                 starts-with(.,'SJ') or
                 starts-with(.,'SK') or
                 starts-with(.,'SL') or
                 starts-with(.,'SM') or
                 starts-with(.,'SN') or
                 starts-with(.,'SO') or
                 starts-with(.,'SP')">
                 <xsl:value-of select="'110'"/>
                 <!-- Mathematik -->
                </xsl:when>
                <xsl:when test="starts-with(.,'AP')">
                 <xsl:value-of select="'120'"/>
                 <!-- Medien und Kommunikation -->
                </xsl:when>
                <xsl:when test="starts-with(.,'WW') or
                 starts-with(.,'WX') or
                 starts-with(.,'WY') or
                 starts-with(.,'WZ') or
                 starts-with(.,'XA') or
                 starts-with(.,'XB') or
                 starts-with(.,'XC') or
                 starts-with(.,'XD') or
                 starts-with(.,'XE') or
                 starts-with(.,'XG') or
                 starts-with(.,'XH') or
                 starts-with(.,'XI') or
                 starts-with(.,'XJ') or
                 starts-with(.,'XK') or
                 starts-with(.,'XL') or
                 starts-with(.,'XM') or
                 starts-with(.,'XN') or
                 starts-with(.,'XO') or
                 starts-with(.,'XP') or
                 starts-with(.,'XQ') or
                 starts-with(.,'XR') or
                 starts-with(.,'XS') or
                 starts-with(.,'XT') or
                 starts-with(.,'XU') or
                 starts-with(.,'XV') or
                 starts-with(.,'XW') or
                 starts-with(.,'XX') or
                 starts-with(.,'XY') or
                 starts-with(.,'XZ') or
                 starts-with(.,'YA') or
                 starts-with(.,'YB') or
                 starts-with(.,'YC') or
                 starts-with(.,'YD') or
                 starts-with(.,'YE') or
                 starts-with(.,'YF') or
                 starts-with(.,'YG') or
                 starts-with(.,'YH') or
                 starts-with(.,'YI') or
                 starts-with(.,'YJ') or
                 starts-with(.,'YK') or
                 starts-with(.,'YL') or
                 starts-with(.,'YM') or
                 starts-with(.,'YN') or
                 starts-with(.,'YO') or
                 starts-with(.,'YP') or
                 starts-with(.,'YQ') or
                 starts-with(.,'YR') or
                 starts-with(.,'YS') or
                 starts-with(.,'YT') or
                 starts-with(.,'YU') or
                 starts-with(.,'YV')">
                 <xsl:value-of select="'130'"/>
                 <!-- Medizin -->
                </xsl:when>
                <xsl:when test="starts-with(.,'LP') or
                 starts-with(.,'LQ') or
                 starts-with(.,'LR') or
                 starts-with(.,'LS') or
                 starts-with(.,'LT') or
                 starts-with(.,'LU') or
                 starts-with(.,'LV') or
                 starts-with(.,'LW') or
                 starts-with(.,'LX') or
                 starts-with(.,'LY')">
                 <xsl:value-of select="'140'"/>
                 <!-- Musik -->
                </xsl:when>
                <xsl:when test="starts-with(.,'D')">
                 <xsl:value-of select="'150'"/>
                 <!-- Pädagogik -->
                </xsl:when>
                <xsl:when test="starts-with(.,'CA') or
                 starts-with(.,'CB') or
                 starts-with(.,'CC') or
                 starts-with(.,'CD') or
                 starts-with(.,'CE') or
                 starts-with(.,'CF') or
                 starts-with(.,'CG') or
                 starts-with(.,'CH') or
                 starts-with(.,'CI') or
                 starts-with(.,'CJ') or
                 starts-with(.,'CK')">
                 <xsl:value-of select="'160'"/>
                 <!-- Philosophie -->
                </xsl:when>
                <xsl:when test="starts-with(.,'U')">
                 <xsl:value-of select="'170'"/>
                 <!-- Physik -->
                </xsl:when>
                <xsl:when test="starts-with(.,'MA') or
                 starts-with(.,'MB') or
                 starts-with(.,'MC') or
                 starts-with(.,'MD') or
                 starts-with(.,'ME') or
                 starts-with(.,'MF') or
                 starts-with(.,'MG') or
                 starts-with(.,'MH') or
                 starts-with(.,'MI') or
                 starts-with(.,'MJ') or
                 starts-with(.,'MK') or
                 starts-with(.,'ML')">
                 <xsl:value-of select="'180'"/>
                 <!-- Politik -->
                </xsl:when>
                <xsl:when test="starts-with(.,'CL') or
                 starts-with(.,'CM') or
                 starts-with(.,'CN') or
                 starts-with(.,'CO') or
                 starts-with(.,'CP') or
                 starts-with(.,'CQ') or
                 starts-with(.,'CR') or
                 starts-with(.,'CS') or
                 starts-with(.,'CT') or
                 starts-with(.,'CU') or
                 starts-with(.,'CV') or
                 starts-with(.,'CW') or
                 starts-with(.,'CX') or
                 starts-with(.,'CY') or
                 starts-with(.,'CZ')">
                 <xsl:value-of select="'190'"/>
                 <!-- Psychologie -->
                </xsl:when>
                <xsl:when test="starts-with(.,'P')">
                 <xsl:value-of select="'200'"/>
                 <!-- Recht -->
                </xsl:when>
                <xsl:when test="starts-with(.,'R')">
                 <xsl:value-of select="'210'"/>
                 <!-- Religion -->
                </xsl:when>
                <xsl:when test="starts-with(.,'MN') or
                 starts-with(.,'MO') or
                 starts-with(.,'MP') or
                 starts-with(.,'MQ') or
                 starts-with(.,'MR') or
                 starts-with(.,'MS')">
                 <xsl:value-of select="'220'"/>
                 <!-- Soziologie -->
                </xsl:when>
                <xsl:when test="starts-with(.,'ZX') or
                 starts-with(.,'ZY')">
                 <xsl:value-of select="'230'"/>
                 <!-- Sport -->
                </xsl:when>
                <xsl:when test="starts-with(.,'E') or
                 starts-with(.,'F') or
                 starts-with(.,'G') or
                 starts-with(.,'H') or
                 starts-with(.,'I') or
                 starts-with(.,'K')">
                 <xsl:value-of select="'240'"/>
                 <!-- Sprache und Literatur -->
                </xsl:when>
                <xsl:when test="starts-with(.,'ZG') or
                 starts-with(.,'ZH') or
                 starts-with(.,'ZI') or
                 starts-with(.,'ZJ') or
                 starts-with(.,'ZK') or
                 starts-with(.,'ZL') or
                 starts-with(.,'ZM') or
                 starts-with(.,'ZN') or
                 starts-with(.,'ZO') or
                 starts-with(.,'ZP') or
                 starts-with(.,'ZQ') or
                 starts-with(.,'ZR') or
                 starts-with(.,'ZS')">
                 <xsl:value-of select="'250'"/>
                 <!-- Technik -->
                </xsl:when>
                <xsl:when test="starts-with(.,'Q')">
                 <xsl:value-of select="'260'"/>
                 <!-- Wirtschaft -->
                </xsl:when>
                <xsl:when test="starts-with(.,'W')">
                 <xsl:value-of select="'20'"/>
                 <!-- Biologie -->
                </xsl:when>
               </xsl:choose>
            </pz:metadata>
         </xsl:template>

</xsl:stylesheet>
