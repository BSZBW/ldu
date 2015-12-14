<?xml version="1.0"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:pz="http://www.indexdata.com/pazpar2/1.0"
        version="1.0">
    <!--
	Transforms Summon documents into pazpar2 records.
	
		
	2014 C. Elmlinger, BSZ Konstanz <clemens.elmlinger@bsz-bw.de>
-->
    <xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>
    <xsl:template name="record-hook" />
    <xsl:template match="@*|node()">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template	match="document">
        <xsl:variable name="linkres" select="@link"/>
        <pz:record>
            <xsl:if test="string-length($linkres) &gt; 0">
               <pz:metadata type="link-resolver">
                   <xsl:value-of select="$linkres"/>
               </pz:metadata>
            </xsl:if>
            <xsl:apply-templates/>
        </pz:record>
    </xsl:template>

    <xsl:variable name="isbn13">
        <xsl:for-each select="//field[@name='ISBN']/value">
            <xsl:if test="string-length()=13">
                <xsl:value-of select="concat(.,';')"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="article">
      <xsl:choose>
        <xsl:when test="//document/field[@name='ContentType']/value='Book' or 
//document/field[@name='ContentType']/value='eBook' ">
          <xsl:value-of select="'n'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'y'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:template match="field[@name='Title']">
       <pz:metadata type="title">
           <xsl:value-of select="./value"/>
        </pz:metadata>
        <xsl:if test = "$article = 'n'">
            <pz:metadata type="book-title">
              <xsl:value-of select="./value"/>
            </pz:metadata>
         </xsl:if>
    </xsl:template>
    <xsl:template match="field[@name='Subtitle']">
        <pz:metadata type="title-remainder">
            <xsl:value-of select="./value"/>
        </pz:metadata>
    </xsl:template>
    <xsl:template match="field[@name='PublicationSeriesTitle']">
        <pz:metadata type="series-title">
            <xsl:value-of select="./value"/>
        </pz:metadata>
    </xsl:template>
    <xsl:template match="field[@name='Author_xml']">
      <xsl:for-each select="./contributor/@fullname">
        <pz:metadata type="author">
            <xsl:value-of select="."/>
        </pz:metadata>
        <xsl:if test = "$article = 'n'">
            <pz:metadata type="author-boost">
              <xsl:value-of select="."/>
            </pz:metadata>
         </xsl:if>
      </xsl:for-each>
    </xsl:template>
    <xsl:template match="field[@name='ID']">
        <pz:metadata type="id">
            <xsl:value-of select="./value"/>
        </pz:metadata>
    </xsl:template>
    <xsl:template match="field[@name='Language']">
        <pz:metadata type="language">
            <xsl:value-of select="./value"/>
        </pz:metadata>
    </xsl:template>
    <xsl:template match="field[@name='Score']">
        <pz:metadata type="score">
            <xsl:value-of select="./value"/>
        </pz:metadata>
    </xsl:template>
    <xsl:template match="field[@name='PublicationDate']">
        <pz:metadata type="publication-date">
            <xsl:value-of select="./value"/>
        </pz:metadata>
        <pz:metadata type="date">
            <xsl:value-of select="substring(./value,1,4)"/>
        </pz:metadata>
    </xsl:template>
    <xsl:template match="field[@name='Publisher']">
        <pz:metadata type="publisher">
            <xsl:value-of select="./value"/>
        </pz:metadata>
    </xsl:template>
    <xsl:template match="field[@name='Abstract']">
        <pz:metadata type="description"> <!-- abstract -->
            <xsl:value-of select="./value"/>
        </pz:metadata>
    </xsl:template>
    <xsl:template match="field[@name='Notes']">
        <pz:metadata type="publicnote">
            <xsl:value-of select="./value"/>
        </pz:metadata>
    </xsl:template>
    <xsl:template match="field[@name='URI']">
        <pz:metadata type="electronic-url">
            <xsl:attribute name="name">
              <xsl:value-of select="'Link'"/>
            </xsl:attribute> 
            <xsl:value-of select="./value"/>
        </pz:metadata>
    </xsl:template>
    <xsl:template match="field[@name='DOI']">
        <pz:metadata type="doi">
            <xsl:value-of select="concat('http://dx.doi.org/',./value)"/>
        </pz:metadata>
    </xsl:template>
   <xsl:template match="field[@name='Discipline']">
        <xsl:for-each select="./value">
            <pz:metadata type="department">
            <xsl:variable name="tdep" select="."/>
            <xsl:choose>
                <xsl:when test="$tdep = 'Archaeology'">
                 <!-- Archaelogie -->
                 <xsl:value-of select="'10'"/>
                </xsl:when>
                <xsl:when test="$tdep = 'Biology' or 
                  $tdep = 'Botany' or $tdep = 'Zoology' or $tdep = 'Veterinary' or
                  $tdep = 'Medicine' or $tdep = 'Dentistry' or $tdep = 'Ecology' or
                  $tdep = 'Anatomy &amp; Physiology' or $tdep = 'Human Anatomy &amp;Physiology' ">
                 <!-- Biology -->
                 <xsl:value-of select="'20'"/>
                </xsl:when>
                <xsl:when test="$tdep = 'Library &amp; Information Science'">
                 <!-- Libr./Inf. Science-->
                 <xsl:value-of select="'30'"/>
                </xsl:when>
                <xsl:when test="$tdep = 'Chemistry' or $tdep = 'Pharmacy' or
                 $tdep = 'Therapeutics &amp; Pharmacology'">
                 <!-- Chemie -->
                 <xsl:value-of select="'40'"/>
                </xsl:when>
                <!-- 50 (Ethnologie gibt's in Summon nicht! -->
                <xsl:when test="$tdep = 'Geography' or $tdep = 'Oceanography' or
                 $tdep = 'Meteorology &amp; Climatology'">
                 <!-- Chemie -->
                 <xsl:value-of select="'60'"/>
                </xsl:when>
                <xsl:when test="$tdep = 'Geology'">
                 <!-- Geologie -->
                 <xsl:value-of select="'70'"/>
                </xsl:when>
                <xsl:when test="$tdep = 'History'">
                 <!-- Geschichte -->
                 <xsl:value-of select="'80'"/>
                </xsl:when>
                <xsl:when test="$tdep = 'Computer Science'">
                 <!-- Informatik -->
                 <xsl:value-of select="'90'"/>
                </xsl:when>
                <xsl:when test="$tdep = 'Visual Arts' or $tdep = 'Architecture'">
                 <!-- Kunst -->
                 <xsl:value-of select="'100'"/>
                </xsl:when>
                <xsl:when test="$tdep = 'Mathematics'">
                 <!-- Mathematik -->
                 <xsl:value-of select="'110'"/>
                </xsl:when>
                <xsl:when test="$tdep = 'Film' or $tdep = 'Dance' or
                 $tdep = 'Drama' or $tdep = 'Journalism &amp; Communications'">
                 <!-- Medien&Kommunikation -->
                 <xsl:value-of select="'120'"/>
                </xsl:when>
                <xsl:when test="$tdep = 'Medicine' or $tdep = 'Nursing' or
                 $tdep = 'Physical Therapy' or $tdep = 'Public Health' or $tdep = 'Veterinary Medicine' or
                 $tdep = 'Human Anatomy &amp; Physiology' or $tdep = 'Diet &amp; Clinical Nutrition' or 
                 $tdep = 'Occupational Therapy &amp; Rehabilitation'">
                 <!-- Medizin -->
                 <xsl:value-of select="'130'"/>
                </xsl:when>
                <xsl:when test="$tdep = 'Music'">
                 <!-- Musik -->
                 <xsl:value-of select="'140'"/>
                </xsl:when>
                <xsl:when test="$tdep = 'Education' or $tdep = 'Social Welfare &amp; Social Work'">
                 <!-- Paedagogik -->
                 <xsl:value-of select="'150'"/>
                </xsl:when>
                <xsl:when test="$tdep = 'Philosophy'">
                 <!-- Philosophie -->
                 <xsl:value-of select="'160'"/>
                </xsl:when>
                <xsl:when test="$tdep = 'Physics' or $tdep = 'Astronomy &amp; Astrophysics'">
                 <!-- Physik  -->
                 <xsl:value-of select="'170'"/>
                </xsl:when>
                <xsl:when test="$tdep = 'Political Science' or $tdep = 'Government' or
                 $tdep = 'Environment Sciences' or $tdep = 'International Relations'">
                 <!-- Politik -->
                 <xsl:value-of select="'180'"/>
                </xsl:when>
                <xsl:when test="$tdep = 'Psychology'">
                 <!-- Psychologie -->
                 <xsl:value-of select="'190'"/>
                </xsl:when>
                <xsl:when test="$tdep = 'Law'">
                 <!-- Recht -->
                 <xsl:value-of select="'200'"/>
                </xsl:when>
                <xsl:when test="$tdep = 'Religion' or $tdep = 'Anthropology' or
                $tdep = 'Parapsychology &amp; Occult Sciences'">
                 <!-- Religion -->
                 <xsl:value-of select="'210'"/>
                </xsl:when>
                <xsl:when test="$tdep = 'Social Sciences' or $tdep = 'Sociology &amp; Social History' or 
                 $tdep = 'Social Welfare &amp; Social Work' or $tdep = 'Women&quot;s Studies'">
                 <!-- Soziologie -->
                 <xsl:value-of select="'220'"/>
                </xsl:when>
                <xsl:when test="$tdep = 'Recreation &amp; Sports'">
                 <!-- Sport -->
                 <xsl:value-of select="'230'"/>
                </xsl:when>
                <xsl:when test="$tdep = 'Languages &amp; Literatures'">
                 <!-- Sprache & Literatur -->
                 <xsl:value-of select="'240'"/>
                </xsl:when>
                <xsl:when test="$tdep = 'Engineering' or $tdep = 'Architecture'">
                 <!-- Technik -->
                 <xsl:value-of select="'250'"/>
                </xsl:when>
                <xsl:when test="$tdep = 'Economics' or $tdep = 'Business' or 
                 $tdep = 'Social Welfare &amp; Social Work' or $tdep = 'Statistics'">
                 <!-- Wirtschaft -->
                 <xsl:value-of select="'260'"/>
                </xsl:when>
               </xsl:choose>
            </pz:metadata>
          </xsl:for-each>

    </xsl:template>
    <xsl:template match="field[@name='SubjectsTerms']">
        <pz:metadata type="subject">
            <xsl:value-of select="./value"/>
        </pz:metadata>
        <xsl:if test = "$article = 'n'">
            <pz:metadata type="subject-boost">
              <xsl:value-of select="./value"/>
            </pz:metadata>
         </xsl:if>
    </xsl:template>
    <xsl:template match="field[@name='Edition']">
        <pz:metadata type="edition">
            <xsl:value-of select="./value"/>
        </pz:metadata>
    </xsl:template>
    <xsl:template match="field[@name='PageCount']">
        <pz:metadata type="pages-number">
             <xsl:value-of select="number(substring-before(concat(normalize-space(translate(./value,
'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.-;:_!§%()=?[]',
'                                                                   ')),' '),' '
))"/>
        </pz:metadata>
    </xsl:template>
    <xsl:template match="field[@name='url']">
        <pz:metadata type="electronic-url">
            <xsl:value-of select="./value"/>
        </pz:metadata>
    </xsl:template>
    <xsl:template match="field[@name='openUrl']">
        <pz:metadata type="open-url">
            <xsl:value-of select="./value"/>
        </pz:metadata>
    </xsl:template>
    <xsl:template match="field[@name='OCLC']">
        <pz:metadata type="oclc-number">
            <xsl:value-of select="./value"/>
        </pz:metadata>
    </xsl:template>
    <xsl:template match="field[@name='LCCallNum']">
        <pz:metadata type="lccn">
            <xsl:value-of select="./value"/>
        </pz:metadata>
    </xsl:template>
    <xsl:template match="field[@name='ContentType']">
       <xsl:for-each select="./value">
            <xsl:variable name="tmedium" select="."/>
            <xsl:choose>
               <xsl:when test="contains($tmedium, 'Article')">
                  <pz:metadata type="medium">article</pz:metadata>
                  <pz:metadata type="available">0</pz:metadata>
                  <pz:metadata type="countAvail">1</pz:metadata>
                  <pz:metadata type="countEx">1</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Newsletter'">
                  <pz:metadata type="medium">article</pz:metadata>
                  <pz:metadata type="available">0</pz:metadata>
                  <pz:metadata type="countAvail">1</pz:metadata>
                  <pz:metadata type="countEx">1</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Reference'">
                  <pz:metadata type="medium">article</pz:metadata>
                  <pz:metadata type="available">0</pz:metadata>
                  <pz:metadata type="countAvail">1</pz:metadata>
                  <pz:metadata type="countEx">1</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Web Resource'">
                  <pz:metadata type="medium">article</pz:metadata>
                  <pz:metadata type="available">0</pz:metadata>
                  <pz:metadata type="countAvail">1</pz:metadata>
                  <pz:metadata type="countEx">1</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Data Set'">
                  <pz:metadata type="medium">article</pz:metadata>
                  <pz:metadata type="available">0</pz:metadata>
                  <pz:metadata type="countAvail">1</pz:metadata>
                  <pz:metadata type="countEx">1</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Transcript'">
                  <pz:metadata type="medium">article</pz:metadata>
                  <pz:metadata type="available">0</pz:metadata>
                  <pz:metadata type="countAvail">1</pz:metadata>
                  <pz:metadata type="countEx">1</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Paper'">
                  <pz:metadata type="medium">article</pz:metadata>
                  <pz:metadata type="available">0</pz:metadata>
                  <pz:metadata type="countAvail">1</pz:metadata>
                  <pz:metadata type="countEx">1</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Report'">
                  <pz:metadata type="medium">article</pz:metadata>
                  <pz:metadata type="available">0</pz:metadata>
                  <pz:metadata type="countAvail">1</pz:metadata>
                  <pz:metadata type="countEx">1</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Electronic Resource'">
                  <pz:metadata type="medium">article</pz:metadata>
                  <pz:metadata type="available">0</pz:metadata>
                  <pz:metadata type="countAvail">1</pz:metadata>
                  <pz:metadata type="countEx">1</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Technical Report'">
                  <pz:metadata type="medium">article</pz:metadata>
                  <pz:metadata type="available">0</pz:metadata>
                  <pz:metadata type="countAvail">1</pz:metadata>
                  <pz:metadata type="countEx">1</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Standard'">
                  <pz:metadata type="medium">article</pz:metadata>
                  <pz:metadata type="available">0</pz:metadata>
                  <pz:metadata type="countAvail">1</pz:metadata>
                  <pz:metadata type="countEx">1</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Book'">
                  <xsl:choose>
	             <xsl:when test="../../field[@name='ContentType']/value='eBook' or ../value='eBook'">
	       	     </xsl:when>
		     <xsl:otherwise>					   
                        <pz:metadata type="medium">book</pz:metadata>
	  	     </xsl:otherwise>
	          </xsl:choose>
               </xsl:when>
               <xsl:when test="$tmedium = 'Archival Material'">
                  <pz:metadata type="medium">ebook</pz:metadata>
				  <pz:metadata type="available">0</pz:metadata>
                  <pz:metadata type="countAvail">1</pz:metadata>
                  <pz:metadata type="countEx">1</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Publication'">
                  <pz:metadata type="medium">ebook</pz:metadata>
                  <pz:metadata type="available">0</pz:metadata>
                  <pz:metadata type="countAvail">1</pz:metadata>
                  <pz:metadata type="countEx">1</pz:metadata>
			  </xsl:when>
               <xsl:when test="$tmedium = 'eBook'">
                  <pz:metadata type="medium">ebook</pz:metadata>
                  <pz:metadata type="available">0</pz:metadata>
                  <pz:metadata type="countAvail">1</pz:metadata>
                  <pz:metadata type="countEx">1</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Book Review'">
                  <pz:metadata type="medium">bookreview</pz:metadata>
                  <pz:metadata type="available">0</pz:metadata>
                  <pz:metadata type="countAvail">1</pz:metadata>
                  <pz:metadata type="countEx">1</pz:metadata> 
			   </xsl:when>
               <xsl:when test="$tmedium = 'Book Chapter'">
                  <pz:metadata type="medium">bookchapter</pz:metadata>
                  <pz:metadata type="available">0</pz:metadata>
                  <pz:metadata type="countAvail">1</pz:metadata>
                  <pz:metadata type="countEx">1</pz:metadata>
			  </xsl:when>
               <xsl:when test="$tmedium = 'Conference Proceeding'">
                  <pz:metadata type="medium">proceeding</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Journal'">
                  <pz:metadata type="medium">journal</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Newspaper'">
                  <pz:metadata type="medium">journal</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'eJournal'">
                  <pz:metadata type="medium">ejournal</pz:metadata>
                  <pz:metadata type="available">0</pz:metadata>
                  <pz:metadata type="countAvail">1</pz:metadata>
                  <pz:metadata type="countEx">1</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Magazine'">
                  <pz:metadata type="medium">ejournal</pz:metadata>
                  <pz:metadata type="available">0</pz:metadata>
                  <pz:metadata type="countAvail">1</pz:metadata>
                  <pz:metadata type="countEx">1</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Dissertation'">
                  <pz:metadata type="medium">diss</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Map'">
                  <pz:metadata type="medium">map</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Image'">
                  <pz:metadata type="medium">map</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Poster'">
                  <pz:metadata type="medium">map</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Atlas'">
                  <pz:metadata type="medium">map</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Video Recording'">
                  <pz:metadata type="medium">video</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'DVD'">
                  <pz:metadata type="medium">video</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Audio Recording'">
                  <pz:metadata type="medium">audio</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Music Recording'">
                  <pz:metadata type="medium">audio</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Spoken Word Recording'">
                  <pz:metadata type="medium">audio</pz:metadata>
				  <pz:metadata type="available">0</pz:metadata>
                  <pz:metadata type="countAvail">1</pz:metadata>
                  <pz:metadata type="countEx">1</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'CD'">
                  <pz:metadata type="medium">audio</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Microfilm'">
                  <pz:metadata type="medium">datamed</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Computer File'">
                  <pz:metadata type="medium">datamed</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Microform'">
                  <pz:metadata type="medium">datamed</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Case'">
                  <pz:metadata type="medium">other</pz:metadata>
                  <pz:metadata type="available">0</pz:metadata>
                  <pz:metadata type="countAvail">1</pz:metadata>
                  <pz:metadata type="countEx">1</pz:metadata>
 			   </xsl:when>
               <xsl:when test="$tmedium = 'Government Document'">
                  <pz:metadata type="medium">other</pz:metadata>
                  <pz:metadata type="available">0</pz:metadata>
                  <pz:metadata type="countAvail">1</pz:metadata>
                  <pz:metadata type="countEx">1</pz:metadata>
			   </xsl:when>
               <xsl:when test="$tmedium = 'Music Score'">
                  <pz:metadata type="medium">other</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Kit'">
                  <pz:metadata type="medium">other</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Presentation'">
                  <pz:metadata type="medium">other</pz:metadata>
				  <pz:metadata type="available">0</pz:metadata>
                  <pz:metadata type="countAvail">1</pz:metadata>
                  <pz:metadata type="countEx">1</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Market Research'">
                  <pz:metadata type="medium">other</pz:metadata>
                  <pz:metadata type="available">0</pz:metadata>
                  <pz:metadata type="countAvail">1</pz:metadata>
                  <pz:metadata type="countEx">1</pz:metadata>
			   </xsl:when>
               <xsl:when test="$tmedium = 'Patent'">
                  <pz:metadata type="medium">other</pz:metadata>
                  <pz:metadata type="available">0</pz:metadata>
                  <pz:metadata type="countAvail">1</pz:metadata>
                  <pz:metadata type="countEx">1</pz:metadata>
			   </xsl:when>
               <xsl:when test="$tmedium = 'Manuscript'">
                  <pz:metadata type="medium">other</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Realia'">
                  <pz:metadata type="medium">other</pz:metadata>
               </xsl:when>
               <xsl:when test="$tmedium = 'Poem'">
                  <pz:metadata type="medium">other</pz:metadata>
                  <pz:metadata type="available">0</pz:metadata>
                  <pz:metadata type="countAvail">1</pz:metadata>
                  <pz:metadata type="countEx">1</pz:metadata>
			   </xsl:when>
            </xsl:choose>
       </xsl:for-each>
    </xsl:template>
    <xsl:template match="field[@name='PublicationPlace']">
        <pz:metadata type="publication-place">
            <xsl:value-of select="./value"/>
        </pz:metadata>
    </xsl:template>
    <xsl:template match="field[@name='PublicationTitle']">
        <pz:metadata type="journal-title">
            <xsl:value-of select="./value"/>
        </pz:metadata>
    </xsl:template>
    <xsl:template match="field[@name='Volume']">
        <pz:metadata type="volume-number">
            <xsl:value-of select="./value"/>
        </pz:metadata>
    </xsl:template>
    <xsl:template match="field[@name='Issue']">
        <pz:metadata type="issue-number">
            <xsl:value-of select="./value"/>
        </pz:metadata>
    </xsl:template>
    <xsl:template match="field[@name='ISSN']">
        <pz:metadata type="issn">
            <xsl:value-of select="./value"/>
        </pz:metadata>
    </xsl:template>
    <xsl:template match="field[@name='EISSN']">
        <pz:metadata type="eissn">
            <xsl:value-of select="./value"/>
        </pz:metadata>
    </xsl:template>
    <xsl:template match="field[@name='ISBN']">
      <xsl:for-each select="./value">
        <xsl:if test="string-length()=10">
            <xsl:if test="not(contains($isbn13,concat('978',substring(.,1,9),(10-(38+number(substring(.,1,1))*3+number(substring(.,2,1))+
number(substring(.,3,1))*3+number(substring(.,4,1))+ number(substring(.,5,1))*3+number(substring(.,6,1))+
number(substring(.,7,1))*3+number(substring(.,8,1))+ number(substring(.,9,1))*3)mod 10)mod 10)))">
            <pz:metadata type="isbn">
                <xsl:value-of select="concat('978',substring(.,1,9),(10-(38+number(substring(.,1,1))*3+number(substring(.,2,1))+
number(substring(.,3,1))*3+number(substring(.,4,1))+ number(substring(.,5,1))*3+number(substring(.,6,1))+
number(substring(.,7,1))*3+number(substring(.,8,1))+ number(substring(.,9,1))*3)mod 10)mod 10)"/>
            </pz:metadata>
            </xsl:if>
        </xsl:if>
        <xsl:if test="string-length()=13">
            <pz:metadata type="isbn">
                <xsl:value-of select="."/>
            </pz:metadata>
        </xsl:if>
        <pz:metadata type="histogram">xxxxx</pz:metadata>
      </xsl:for-each>
    </xsl:template>


</xsl:stylesheet>
