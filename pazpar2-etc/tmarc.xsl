<?xml version="1.0" encoding="UTF-8"?>
<!--
	tmarc.xsl
	Stylesheet to extract Marc 21 fields from Indexdata’s streamlined
	turbomarc XML format to an internal metadat model for pazpar2.

	Mostly based on Indexdata’s original tmarc.xsl from
	http://git.indexdata.com/?p=pazpar2.git;a=blob_plain;f=etc/tmarc.xsl;hb=HEAD

	In parts modified, extended, streamlined by
	Sven-S. Porst, SUB Göttingen <porst@sub.uni-goettingen.de>

	This version can be found in the repository at github:
	https://github.com/ssp/pazpar2-etc/
-->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:pz="http://www.indexdata.com/pazpar2/1.0"
  xmlns:php="http://php.net/xsl"
  xmlns:tmarc="http://www.indexdata.com/turbomarc" version="1.0">

  <xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>

  <xsl:param name="medium"/>

  <xsl:template name="record-hook"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tmarc:collection">
    <collection>
      <xsl:apply-templates/>
    </collection>
  </xsl:template>

  <xsl:template match="tmarc:r">
    <xsl:variable name="title_medium" select="tmarc:d245/tmarc:sh"/>
    
    <xsl:variable name="dissnote" select="count(//tmarc:d502)"/>

    <!-- Assemble the parent’s title from 773 $a and $t. -->
    <xsl:variable name="parent-title">
      <xsl:value-of select="tmarc:d773/tmarc:sa"/>
      <xsl:if test="tmarc:d773/tmarc:sa and tmarc:d773/tmarc:st">
        <xsl:text>: </xsl:text>
	  </xsl:if>
      <xsl:value-of select="tmarc:d773/tmarc:st"/>
    </xsl:variable>

    <xsl:variable name="isbn13">
        <xsl:for-each select="//tmarc:d020/tmarc:sa">
            <xsl:if test="string-length()=13">
                <xsl:value-of select="concat(.,';')"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="fulltext_a" select="tmarc:d900/tmarc:sa"/>
    <xsl:variable name="fulltext_b" select="tmarc:d900/tmarc:sb"/>

    <xsl:variable name="typeofrec" select="substring(tmarc:l, 7, 1)"/>
    <xsl:variable name="typeofvm" select="substring(tmarc:c008, 34, 1)"/>
    <xsl:variable name="biblevel" select="substring(tmarc:l, 8, 1)"/>
    <xsl:variable name="multipart" select="substring(tmarc:l, 20, 1)"/>

    <xsl:variable name="form1" select="substring(tmarc:c008, 24, 1)"/>
    <xsl:variable name="form2" select="substring(tmarc:c008, 30, 1)"/>
    <xsl:variable name="language" select="substring(tmarc:c008, 36, 3)"/>
    <xsl:variable name="oclca" select="substring(tmarc:c007, 1, 1)"/>
    <xsl:variable name="oclcb" select="substring(tmarc:c007, 2, 1)"/>
    <xsl:variable name="oclcd" select="substring(tmarc:c007, 4, 1)"/>
    <xsl:variable name="oclce" select="substring(tmarc:c007, 5, 1)"/>
    <xsl:variable name="typeofserial" select="substring(tmarc:c008, 22, 1)"/>



    <xsl:variable name="electronic">
      <xsl:choose>
        <xsl:when test="$form1='s' or $form1='q' or $form1='o' or $form2='s' or $form2='q' or $form2='o'">
          <xsl:text>yes</xsl:text>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="vmedium">
      <xsl:choose>
        <xsl:when test="string-length($medium)"><xsl:value-of select="$medium"/></xsl:when>
        <xsl:when test="$dissnote &gt; 0">diss</xsl:when>
        <xsl:when test="$oclca='h' or $form1='a' or $form1='b' or $form1='c'">microform</xsl:when>
        <xsl:when test="$multipart='a'">multivolume</xsl:when>
        <xsl:when test="$typeofrec='j' or $typeofrec='i'">
          <xsl:text>recording</xsl:text>
          <xsl:choose>
            <xsl:when test="$oclcb='d' and $oclcd='f'">-cd</xsl:when>
            <xsl:when test="$oclcb='s'">-cassette</xsl:when>
            <xsl:when test="$oclcb='d' and $oclcd='a' or $oclcd='b' or $oclcd='c' or $oclcd='d' or $oclcd='e'">-vinyl</xsl:when>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$typeofrec='g'">
          <xsl:choose>
            <xsl:when test="$typeofvm='m' or $typeofvm='v'">
              <xsl:text>video</xsl:text>
              <xsl:choose>
                <xsl:when test="$oclca='v' and $oclcb='d' and $oclce='v'">-dvd</xsl:when>
                <xsl:when test="$oclca='v' and $oclcb='d' and $oclce='s'">-blu-ray</xsl:when>
                <xsl:when test="$oclca='v' and $oclcb='f' and $oclce='b'">-vhs</xsl:when>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>audio-visual</xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$typeofrec='a' and $biblevel='s'">
          <xsl:choose>
            <xsl:when test="$typeofserial='n'">newspaper</xsl:when>
            <xsl:otherwise>journal</xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$typeofrec='e' or $typeofrec='f'">map</xsl:when>
        <xsl:when test="$typeofrec='c' or $typeofrec='d'">music-score</xsl:when>
        <xsl:when test="$typeofrec='t'">manuscript</xsl:when>
        <xsl:when test="string-length($parent-title) &gt; 0">article</xsl:when>
        <xsl:when test="($typeofrec='a' or $typeofrec='t') and ($biblevel='m' or $biblevel='a')">book</xsl:when>
        <xsl:when test="($typeofrec='a' or $typeofrec='i') and ($typeofserial='d' or $typeofserial='w')">web</xsl:when>
        <xsl:when test="$typeofrec='a' and $biblevel='b'">article</xsl:when>
        <xsl:when test="$typeofrec='m'">electronic</xsl:when>
        <xsl:when test="$typeofrec='o'">multiple</xsl:when>
        <xsl:otherwise>
          <xsl:text>other</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="BSZPage">
      <xsl:choose>
        <xsl:when test="($typeofrec='a' or $typeofrec='t' or $typeofrec='c' or $typeofrec='d' or $typeofrec='e' or $typeofrec='f') and ($biblevel='m' or $biblevel='a') and ($oclca='t')">y</xsl:when>
        <xsl:otherwise>
          <xsl:text>n</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>


    <xsl:variable name="has_fulltext">
      <xsl:choose>
        <xsl:when test="tmarc:d856/tmarc:sq">
          <xsl:text>yes</xsl:text>
        </xsl:when>
        <xsl:when test="tmarc:d856/tmarc:si='TEXT*'">
          <xsl:text>yes</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>no</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="oclc_number">
      <xsl:choose>
        <xsl:when test='contains(tmarc:c001,"ocn") or
                        contains(tmarc:c001,"ocm") or
                        contains(tmarc:c001,"OCoLC")'>
          <xsl:value-of select="tmarc:c001"/>
        </xsl:when>
        <xsl:when test='contains(tmarc:d035/tmarc:sa,"ocn") or
                        contains(tmarc:d035/tmarc:sa,"ocm") or
                        contains(tmarc:d035/tmarc:sa,"OCoLC")'>
          <xsl:value-of select="tmarc:d035/tmarc:sa"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="date_008">
      <xsl:choose>
        <xsl:when test="contains('cestpudikmr', substring(tmarc:c008, 7, 1))">
          <xsl:value-of select="substring(tmarc:c008, 8, 4)"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="date_end_008">
      <xsl:choose>
        <xsl:when test="contains('dikmr', substring(tmarc:c008, 7, 1))">
          <xsl:value-of select="substring(tmarc:c008, 12, 4)"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <pz:record>
      <!-- extract language information from: 008[35-37] ($language variable) and 041 $a fields -->
      <xsl:if test="$language!='und' and
                    $language!='zxx' and
                    $language!='   ' and
                    $language!='mul' and
                    $language!='|||'">
        <pz:metadata type="language">
          <xsl:value-of select="$language"/>
        </pz:metadata>
      </xsl:if>
      <xsl:for-each select="tmarc:d041">
        <!-- $a main, $b summary, $d audio, $e libretto, $f toc, $g additions, $j subtitles -->
        <xsl:for-each select="tmarc:sa | tmarc:sb | tmarc:sd | tmarc:se | tmarc:sf | tmarc:sg | tmarc:sj">
          <xsl:if test=". != $language and not(../@i2 = '7' and not(../tmarc:s2))">
            <!-- only add language codes which do not duplicate the one in c008 and, if non-standard, which contain information about their type -->
            <pz:metadata type="language">
              <!-- for non-standard language codes transport their type in the language-code-scheme attribute -->
              <xsl:if test="../@i2 = '7' and ../tmarc:s2">
                <xsl:attribute name="language-code-scheme">
                  <xsl:value-of select="../tmarc:s2"/>
                </xsl:attribute>
              </xsl:if>
          	  <xsl:value-of select="."/>
            </pz:metadata>
          </xsl:if>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each select="tmarc:c001">
            <pz:metadata type="id">
            <xsl:value-of select="." />
            </pz:metadata>


      </xsl:for-each>

      <xsl:if test="string-length($oclc_number) &gt; 0">
        <pz:metadata type="oclc-number">
          <xsl:value-of select="$oclc_number"/>
        </pz:metadata>
      </xsl:if>

      <xsl:for-each select="tmarc:d010">
        <xsl:for-each select="tmarc:sa">
          <pz:metadata type="lccn">
            <xsl:value-of select="."/>
          </pz:metadata>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d016">
        <pz:metadata type="record-control-number">
          <xsl:if test="@i1 = '7' and tmarc:s2">
            <xsl:attribute name="source">
              <xsl:value-of select="tmarc:s2"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:value-of select="tmarc:sa"/>
        </pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d020">
        <xsl:for-each select="tmarc:sa">
		<!-- ISBN-10 will be coonverted to ISBN-13 -->

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
      </xsl:for-each>

      <!-- ISSN should have the form »XXXX-XXXX« but some records
           append a note »XXXX-XXXX (Note)« which does not conform to the standard.
           Strip everything beyond the 9th character and normalise space to also
           cope with records where the middle dash is missing.
      -->
      <xsl:for-each select="tmarc:d022">
        <xsl:for-each select="tmarc:sa">
          <pz:metadata type="issn">
            <xsl:value-of select="normalize-space(substring(., 1, 9))"/>
          </pz:metadata>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d024">
        <xsl:if test="(tmarc:sa) and (tmarc:s2='doi')">
          <pz:metadata type="doi">
            <xsl:value-of select="concat('http://dx.doi.org/',tmarc:sa)"/>
          </pz:metadata>
        </xsl:if>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d027">
        <xsl:for-each select="tmarc:sa">
          <pz:metadata type="tech-rep-nr">
            <xsl:value-of select="."/>
          </pz:metadata>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d035">
        <pz:metadata type="system-control-nr">
          <xsl:choose>
            <xsl:when test="tmarc:sa">
              <xsl:value-of select="tmarc:sa"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="tmarc:sb"/>
            </xsl:otherwise>
          </xsl:choose>
        </pz:metadata>
      </xsl:for-each>

      <!-- DDC -->
      <xsl:for-each select="tmarc:d082">
        <pz:metadata type="classification-ddc">
          <xsl:value-of select="tmarc:sa"/>
        </pz:metadata>
      </xsl:for-each>

      <!-- Marc 084 contains generic classification numbers with the
           classification name in $2. Turn these into metadata fields with
           name classification-XXX where XXX is the content of $2.
           Create a new pazpar2 metadata field for each $a subfield.
      -->
      <xsl:for-each select="tmarc:d084">

      <xsl:if test="tmarc:s2='rvk'">
          <xsl:for-each select="tmarc:sa">
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
          </xsl:for-each>
      </xsl:if>
      </xsl:for-each>


      <xsl:for-each select="tmarc:d100 | tmarc:d700[tmarc:s4='aut']">
        <xsl:for-each select="tmarc:sa">
          <pz:metadata type="author">
            <xsl:value-of select="."/>
          </pz:metadata>
          <xsl:if test="$vmedium='book'">
            <pz:metadata type="author-boost">
              <xsl:value-of select="." />
            </pz:metadata>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sc">
          <pz:metadata type="author-title">
            <xsl:value-of select="."/>
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sd">
          <pz:metadata type="author-date">
            <xsl:value-of select="."/>
          </pz:metadata>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d700">
        <xsl:if test="not(tmarc:sa = ../tmarc:d100/tmarc:sa) and not(tmarc:s4='aut')">
          <pz:metadata type="other-person">
            <xsl:value-of select="tmarc:sa"/>
          </pz:metadata>
        </xsl:if>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d110">
        <xsl:for-each select="tmarc:sa">
          <pz:metadata type="corporate-name">
            <xsl:value-of select="."/>
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sc">
          <pz:metadata type="corporate-location">
            <xsl:value-of select="."/>
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sd">
          <pz:metadata type="corporate-date">
            <xsl:value-of select="."/>
          </pz:metadata>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d111">
        <xsl:for-each select="tmarc:sa">
          <pz:metadata type="meeting-name">
            <xsl:value-of select="."/>
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sc">
          <pz:metadata type="meeting-location">
            <xsl:value-of select="."/>
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sd">
          <pz:metadata type="meeting-date">
            <xsl:value-of select="."/>
          </pz:metadata>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d260">
        <xsl:for-each select="tmarc:sc">
          <pz:metadata type="date">
            <xsl:value-of select="translate(., 'cp[].', '')"/>
          </pz:metadata>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:if test="string-length($date_008) &gt; 0 and not(tmarc:d260/tmarc:sc)">
        <pz:metadata type="date">
          <xsl:choose>
            <xsl:when test="$date_end_008">
              <xsl:value-of select="concat($date_008,'-',$date_end_008)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$date_008"/>
            </xsl:otherwise>
          </xsl:choose>
        </pz:metadata>
      </xsl:if>

      <xsl:for-each select="tmarc:d130">
        <xsl:for-each select="tmarc:sa">
          <pz:metadata type="title-uniform">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sm">
          <pz:metadata type="title-uniform-media">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sn">
          <pz:metadata type="title-uniform-parts">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sp">
          <pz:metadata type="title-uniform-partname">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sr">
          <pz:metadata type="title-uniform-key">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d245">
        <xsl:for-each select="tmarc:sa">
          <pz:metadata type="title">
            <xsl:value-of select="." />
          </pz:metadata>
          <xsl:if test="$vmedium='book'">
            <pz:metadata type="book-title">
              <xsl:value-of select="." />
            </pz:metadata>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sb">
          <pz:metadata type="title-remainder">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sc">
          <pz:metadata type="title-responsibility">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sf">
          <pz:metadata type="title-dates">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sh">
          <pz:metadata type="title-medium">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
        <xsl:variable name="number-info">
          <xsl:for-each select="tmarc:sn|tmarc:sp">
            <xsl:value-of select="."/>
            <xsl:if test="not(contains(',.;:' ,substring(., string-length(.), 1)))">
              <xsl:choose>
                <xsl:when test="name(.)='sn' and name(following-sibling::*[1])='sp'">
                  <xsl:text>:</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>.</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:if>
            <xsl:text> </xsl:text>
          </xsl:for-each>
        </xsl:variable>
        <pz:metadata type="title-number-section">
          <xsl:value-of select="$number-info"/>
        </pz:metadata>
        <pz:metadata type="title-complete">
          <xsl:value-of select="tmarc:sa"/>
          <xsl:if test="tmarc:sn|tmarc:sp">
            <xsl:value-of select="concat(' ', $number-info)"/>
          </xsl:if>
          <xsl:if test="tmarc:sb">
            <xsl:value-of select="concat(': ', tmarc:sb)"/>
          </xsl:if>
        </pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d250">
        <xsl:for-each select="tmarc:sa">
          <pz:metadata type="edition">
            <xsl:value-of select="."/>
          </pz:metadata>
        </xsl:for-each>
      </xsl:for-each>

      <!-- Map information:
           Create the mapscale field, add the scale as its text and
           the projection/coordinates fields as attributes.
           Delete the brackets and punctuation surrounding the
           coordinates string.
      -->
      <xsl:for-each select="tmarc:d255">
        <pz:metadata type="mapscale">
          <xsl:if test="tmarc:sb">
            <xsl:attribute name="projection">
              <xsl:value-of select="tmarc:sb"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="tmarc:sc">
            <xsl:attribute name="coordinates">
              <xsl:value-of select="translate(tmarc:sc, '().', '')"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:value-of select="tmarc:sa"/>
       </pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d260">
        <xsl:for-each select="tmarc:sa">
          <pz:metadata type="publication-place">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sb">
          <pz:metadata type="publication-name">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sc">
          <pz:metadata type="publication-date">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d300">
        <xsl:for-each select="tmarc:sa">
          <pz:metadata type="physical-extent">
            <xsl:value-of select="." />
          </pz:metadata>
          <xsl:if test="$BSZPage = 'y'">
            <pz:metadata type="pages-number">
 		<xsl:value-of select="number(substring-before(concat(normalize-space(translate(.,
'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.-;:_!§%()=?[]',
'                                                                   ')),' '),' '))"/>           
</pz:metadata>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sb">
          <pz:metadata type="physical-format">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sc">
          <pz:metadata type="physical-dimensions">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:se">
          <pz:metadata type="physical-accomp">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sf">
          <pz:metadata type="physical-unittype">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sg">
          <pz:metadata type="physical-unitsize">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:s3">
          <pz:metadata type="physical-specified">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d440">
        <xsl:for-each select="tmarc:sa">
          <pz:metadata type="series-title">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
      </xsl:for-each>

      <!--
        If the multipart variable (leader position 19) is b, the first Field 490
        contains the multivolume work title. If the multivolume work is part of a series,
        the series will be stated in the following 490 field.
      -->
      <xsl:for-each select="tmarc:d490">
        <xsl:choose>
          <xsl:when test="$multipart = 'b' and position() = 1">
            <pz:metadata type="multivolume-title">
              <xsl:value-of select="tmarc:sa"/>
              <xsl:if test="tmarc:sv">
                <xsl:text> </xsl:text>
                <xsl:value-of select="tmarc:sv"/>
              </xsl:if>
            </pz:metadata>
          </xsl:when>
          <xsl:otherwise>
            <pz:metadata type="series-title">
              <xsl:value-of select="tmarc:sa"/>
              <xsl:if test="tmarc:sv">
                <xsl:text> </xsl:text>
                <xsl:value-of select="tmarc:sv"/>
              </xsl:if>
            </pz:metadata>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>

      <!-- Note fields
           [general/500, with/501, dissertation/502, formatted contents/505,
            event/518, summary/520, geographic coverage/522]
           Concatenate their values with commas in between and write a description field.
           Ignore abstracts (520 with i1=3) which are treated separately below.
      -->
      <xsl:for-each select="tmarc:d500 | tmarc:d501 | tmarc:d502 | tmarc:d505 |
                            tmarc:d520[@i1!='3']  |  tmarc:d518 | tmarc:d522">
        <pz:metadata type="description">
          <xsl:for-each select="./*">
            <xsl:value-of select="text()"/>
            <xsl:if test="position()!=last() and .!=''">
              <xsl:text>, </xsl:text>
            </xsl:if>
          </xsl:for-each>
        </pz:metadata>
      </xsl:for-each>

      <!-- Corporate name (710) or meeting name (711):
           Join the (non-control) subfields of these fields with spaces
           as separators so they are reasonably legible and write into
           a description field.
      -->
      <xsl:for-each select="tmarc:d710 | tmarc:d711">
        <pz:metadata type="description">
          <xsl:for-each select="./*[local-name() != 's0' and local-name() != 's3'
                                    and local-name() != 's5' and local-name() != 's6'
                                    and local-name() != 's8']">
            <xsl:value-of select="text()"/>
            <xsl:if test="position()!=last() and .!=''">
              <xsl:text> </xsl:text>
            </xsl:if>
          </xsl:for-each>
        </pz:metadata>
      </xsl:for-each>

      <!-- Abstracts (520 with i1=3) get their own metadata field.
           They are explicitly excluded from becoming descriptions above.
      -->
      <xsl:for-each select="tmarc:d520[@i1='3']">
        <pz:metadata type="description"> <!-- abstract -->
          <xsl:for-each select="./*">
            <xsl:value-of select="text()"/>
            <xsl:if test="position()!=last() and .!=''">
              <xsl:text> </xsl:text>
            </xsl:if>
          </xsl:for-each>
        </pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d911">
        <pz:metadata type="description">
          <xsl:for-each select="node()">
            <xsl:value-of select="text()"/>
          </xsl:for-each>
        </pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d600 | tmarc:d610 | tmarc:d611 | tmarc:d630 |
                            tmarc:d648 | tmarc:d650 | tmarc:d651 | tmarc:d653 |
                            tmarc:d654 | tmarc:d655 | tmarc:d656 | tmarc:d657 |
                            tmarc:d658 | tmarc:d662 | tmarc:d690 | tmarc:d691 |
                            tmarc:d692 | tmarc:d693 | tmarc:d694 | tmarc:d696 |
                            tmarc:d697 | tmarc:d698 | tmarc:d699 | tmarc:d69X">
        <xsl:for-each select="tmarc:sa">
          <pz:metadata type="subject">
            <xsl:value-of select="."/>
          </pz:metadata>
          <xsl:if test="$vmedium='book'">
            <pz:metadata type="subject-boost">
              <xsl:value-of select="." />
            </pz:metadata>
          </xsl:if>
        </xsl:for-each>

        <pz:metadata type="subject-long">
          <xsl:for-each select="node()/text()">
            <xsl:if test="position() &gt; 1">
              <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:variable name='value'>
              <xsl:value-of select='normalize-space(.)'/>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="substring($value, string-length($value)) = ','">
                <xsl:value-of select="substring($value, 1, string-length($value)-1)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$value"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </pz:metadata>
      </xsl:for-each>


      <!--
        Grab potential parent-id from 800/810/830 $w.
        Parent links can occur in these fields (corresponding to the parent items mentioned
        in 490 fields or 245) as well as in 773 $w.
        There should be at most one parent-id.
      -->
      <xsl:for-each select="tmarc:d800 | tmarc:d810 | tmarc:d830">
        <xsl:if test="tmarc:sw">
          <pz:metadata type="parent-id">
            <xsl:value-of select="tmarc:sw"/>
          </pz:metadata>
        </xsl:if>
      </xsl:for-each>

      <!-- Links: 856, with an attempt to try and isolate DOIs and URNs -->
      <xsl:for-each select="tmarc:d856">
        <xsl:choose>
          <!-- Map DOI URLs to the doi field -->
          <xsl:when test="substring(tmarc:su, 1, 18) = 'http://dx.doi.org/'">
            <pz:metadata type="doi">
              <xsl:value-of select="tmarc:su"/>
              <!-- xsl:value-of select="substring-after(tmarc:su, 'http://dx.doi.org/')"/-->
            </pz:metadata>
          </xsl:when>
          <!-- Map URNs to the urn field -->
          <xsl:when test="substring(tmarc:su, 1, 4) = 'urn:'">
            <pz:metadata type="urn">
              <xsl:value-of select="tmarc:su"/>
            </pz:metadata>
          </xsl:when>
          <!-- Generic URLs -->
          <xsl:when test="tmarc:su">
            <pz:metadata type="electronic-url">
              <xsl:if test="tmarc:sy|tmarc:s3|tmarc:sa">
                <xsl:variable name="name">
                  <!-- for the name: use the first available of $y, $3, $a -->
                  <xsl:choose>
                    <!-- $y Link text: repetitions separated by ;  -->
                    <xsl:when test="tmarc:sy">
                      <xsl:variable name="name">
                        <xsl:for-each select="tmarc:sy">
                          <xsl:value-of select="."/>
                          <xsl:if test="position() != last()">; </xsl:if>
                        </xsl:for-each>
                      </xsl:variable>
                      <xsl:value-of select="$name"/>
                    </xsl:when>
                    <!-- $3 Materials Specified: not repeatable -->
                    <xsl:when test="tmarc:s3">
                      <xsl:value-of select="tmarc:s3"/>
                    </xsl:when>
                    <!-- $a Host Name: repetitions separated by ;  -->
                    <xsl:when test="tmarc:sa">
                      <xsl:variable name="name">
                        <xsl:for-each select="tmarc:sa">
                          <xsl:value-of select="."/>
                          <xsl:if test="position() != last()">; </xsl:if>
                        </xsl:for-each>
                      </xsl:variable>
                      <xsl:value-of select="$name"/>
                    </xsl:when>
                  </xsl:choose>
                </xsl:variable>
                <xsl:if test="string-length($name) &gt; 0">
                  <xsl:attribute name="name">
                    <xsl:value-of select="$name"/>
                  </xsl:attribute>
                </xsl:if>
              </xsl:if>
              <!-- $z Public Note: repetitions separated by ;  -->
              <xsl:if test="tmarc:sz">
                <xsl:variable name="note">
                  <xsl:for-each select="tmarc:sz">
                    <xsl:value-of select="."/>
                    <xsl:if test="position() != last()">; </xsl:if>
                  </xsl:for-each>
                </xsl:variable>
                <xsl:if test="string-length($note) &gt; 0">
                  <xsl:attribute name="note">
                    <xsl:value-of select="$note"/>
                  </xsl:attribute>
                </xsl:if>
              </xsl:if>
              <!-- $i Instruction: repetitions separated by ;  -->
              <xsl:if test="tmarc:si">
                <xsl:variable name="instruction">
                  <xsl:for-each select="tmarc:si">
                    <xsl:value-of select="."/>
                    <xsl:if test="position() != last()">; </xsl:if>
                  </xsl:for-each>
                </xsl:variable>
                <xsl:if test="string-length($instruction) &gt; 0">
                  <xsl:attribute name="format-instruction">
                    <xsl:value-of select="$instruction"/>
                  </xsl:attribute>
                </xsl:if>
              </xsl:if>
              <!-- $q Electronic Format Type: not repeatable -->
              <xsl:if test="tmarc:sq">
                <xsl:attribute name="format-type">
                  <xsl:value-of select="tmarc:sq"/>
                </xsl:attribute>
              </xsl:if>
              <!-- $u URL -->
              <xsl:value-of select="tmarc:su"/>
            </pz:metadata>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d773">
        <!-- full citation -->
        <pz:metadata type="citation">
          <xsl:for-each select="*">
            <xsl:value-of select="normalize-space(.)"/>
            <xsl:text> </xsl:text>
          </xsl:for-each>
        </pz:metadata>
        <!-- ISSN -->
        <xsl:if test="tmarc:sx">
          <pz:metadata type="issn">
            <xsl:value-of select="tmarc:sx"/>
          </pz:metadata>
        </xsl:if>
        <!-- ISBN, can appear for essays in a book -->
        <xsl:if test="tmarc:sz">
          <pz:metadata type="isbn">
            <xsl:value-of select="tmarc:sz"/>
          </pz:metadata>
        </xsl:if>
        <!-- title: $parent-title combines $a and $t -->
        <xsl:if test="$parent-title">
          <pz:metadata type="journal-title">
            <xsl:value-of select="$parent-title"/>
          </pz:metadata>
        </xsl:if>
        <!-- short title -->
        <xsl:if test="tmarc:sp">
          <pz:metadata type="journal-title-abbrev">
            <xsl:value-of select="tmarc:sp"/>
          </pz:metadata>
        </xsl:if>
        <!-- parent ID -->
        <xsl:if test="tmarc:sw">
          <pz:metadata type="parent-id">
            <xsl:value-of select="tmarc:sw"/>
          </pz:metadata>
        </xsl:if>

        <!-- if necessary evaluate volume/pages information from $g -->
        <xsl:if test="tmarc:sg">
          <xsl:variable name="subpart">
            <xsl:for-each select="tmarc:sg">
              <xsl:value-of select="."/>
              <xsl:text> </xsl:text>
            </xsl:for-each>
          </xsl:variable>

          <pz:metadata type="journal-subpart">
            <xsl:value-of select="normalize-space($subpart)"/>
          </pz:metadata>

          <xsl:if test="not(tmarc:sq)">
            <xsl:variable name="l">
              <xsl:value-of select="translate($subpart,
                                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ.',
                                   'abcdefghijklmnopqrstuvwxyz ')"/>
            </xsl:variable>
            <xsl:variable name="volume">
              <xsl:choose>
                <xsl:when test="string-length(substring-after($l,'vol ')) &gt; 0">
                  <xsl:value-of select="substring-before(normalize-space(substring-after($l,'vol ')),' ')"/>
                </xsl:when>
                <xsl:when test="string-length(substring-after($l,'v ')) &gt; 0">
                  <xsl:value-of select="substring-before(normalize-space(substring-after($l,'v ')),' ')"/>
                </xsl:when>
              </xsl:choose>
            </xsl:variable>
            <xsl:variable name="issue">
              <xsl:value-of select="substring-before(translate(normalize-space(substring-after($l,'issue')), ',', ' '),' ')"/>
            </xsl:variable>
            <xsl:variable name="pages">
              <xsl:choose>
                <xsl:when test="string-length(substring-after($l,' p ')) &gt; 0">
                  <xsl:value-of select="normalize-space(substring-after($l,' p '))"/>
                </xsl:when>
                <xsl:when test="string-length(substring-after($l,',p')) &gt; 0">
                  <xsl:value-of select="normalize-space(substring-after($l,',p'))"/>
                </xsl:when>
                <xsl:when test="string-length(substring-after($l,' p')) &gt; 0">
                  <xsl:value-of select="normalize-space(substring-after($l,' p'))"/>
                </xsl:when>
              </xsl:choose>
            </xsl:variable>

            <!-- volume -->
            <xsl:if test="string-length($volume) &gt; 0">
              <pz:metadata type="volume-number">
                <xsl:value-of select="$volume"/>
              </pz:metadata>
            </xsl:if>
            <!-- issue -->
            <xsl:if test="string-length($issue) &gt; 0">
              <pz:metadata type="issue-number">
                <xsl:value-of select="$issue"/>
              </pz:metadata>
            </xsl:if>
            <!-- pages -->
            <xsl:if test="string-length($pages) &gt; 0">
              <pz:metadata type="pages-number">
                <xsl:value-of select="$pages"/>
              </pz:metadata>
            </xsl:if>
          </xsl:if> <!-- not(tmarc:sq) -->
        </xsl:if> <!-- tmarc:sg -->

        <!--
          Evaluate Marc 773 $q for article page numbers.
          The field contains a string of the form
            volume:issue:subissue<pagenumber
            ..1...:......2.......<....3.....
          where each component is potentially optional and the depth of the subissue
          hierarchy can be extended as needed. Map the components to the pz:metadata fields:
            1: volume-number
            2: issue-number
            3: pages
          omitting blank fields if they occur.
        -->
        <xsl:if test="tmarc:sq">
          <xsl:variable name="volumeIssue">
            <xsl:choose>
              <xsl:when test="contains(tmarc:sq, '&lt;')">
                <xsl:value-of select="substring-before(tmarc:sq, '&lt;')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="tmarc:sq"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="volume">
            <xsl:choose>
              <xsl:when test="contains($volumeIssue, ':')">
                <xsl:value-of select="normalize-space(substring-before($volumeIssue, ':'))"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="normalize-space($volumeIssue)"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="issue" select="normalize-space(substring-after($volumeIssue, ':'))"/>
          <xsl:variable name="pages" select="normalize-space(substring-after(tmarc:sq, '&lt;'))"/>

          <!-- volume -->
          <xsl:if test="string-length($volume) &gt; 0">
            <pz:metadata type="volume-number">
              <xsl:value-of select="$volume"/>
            </pz:metadata>
          </xsl:if>
          <!-- issue -->
          <xsl:if test="string-length($issue) &gt; 0">
            <pz:metadata type="issue-number">
              <xsl:value-of select="$issue"/>
            </pz:metadata>
          </xsl:if>
          <!-- pages -->
          <xsl:if test="string-length($pages) &gt; 0">
            <pz:metadata type="pages-number">
              <xsl:value-of select="$pages"/>
            </pz:metadata>
          </xsl:if>
        </xsl:if> <!-- tmarc:sq -->

      </xsl:for-each> <!-- tmarc:d773 -->

      <xsl:for-each select="tmarc:d852">
        <xsl:for-each select="tmarc:sy">
          <pz:metadata type="publicnote">
            <xsl:value-of select="."/>
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sh">
          <pz:metadata type="callnumber">
            <xsl:value-of select="."/>
          </pz:metadata>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d876">
        <xsl:if test="tmarc:sf">
          <pz:metadata type="loan-period">
            <xsl:value-of select="concat(tmarc:s5,':',tmarc:sf)"/>
          </pz:metadata>
        </xsl:if>
      </xsl:for-each>

      <pz:metadata type="medium">
        <xsl:value-of select="$vmedium"/>
        <xsl:if test="string-length($electronic) and $vmedium != 'electronic'">
          <xsl:text> (electronic)</xsl:text>
        </xsl:if>
      </pz:metadata>

      <xsl:for-each select="tmarc:d900">
        <pz:metadata type="fulltext">
          <xsl:for-each select="tmarc:sa | tmarc:sb | tmarc:se | tmarc:sf |
                              tmarc:si | tmarc:sk | tmarc:sk | tmarc:sq |
                              tmarc:ss | tmarc:su | tmarc:sy">
            <xsl:value-of select="."/>
          </xsl:for-each>
        </pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d903">
        <xsl:if test="tmarc:sa">
          <pz:metadata type="publication-date">
            <xsl:value-of select="substring(tmarc:sa,1,4)"/>
          </pz:metadata>
          <pz:metadata type="date">
            <xsl:value-of select="substring(tmarc:sa,1,4)"/>
          </pz:metadata>
        </xsl:if>
      </xsl:for-each>

      <pz:metadata type="has-fulltext">
        <xsl:value-of select="$has_fulltext"/>
      </pz:metadata>

      <xsl:for-each select="tmarc:d907 | tmarc:d901">
        <pz:metadata type="iii-id">
          <xsl:value-of select="tmarc:sa"/>
        </pz:metadata>
      </xsl:for-each>
      <xsl:for-each select="tmarc:d926">
        <pz:metadata type="locallocation" empty="PAZPAR2_NULL_VALUE">
          <xsl:value-of select="tmarc:sa"/>
        </pz:metadata>
        <pz:metadata type="callnumber" empty="PAZPAR2_NULL_VALUE">
          <xsl:value-of select="tmarc:sc"/>
        </pz:metadata>
        <pz:metadata type="available" empty="PAZPAR2_NULL_VALUE">
          <xsl:value-of select="tmarc:se"/>
        </pz:metadata>
      </xsl:for-each>

      <!-- OhioLINK holdings -->
      <xsl:for-each select="tmarc:d945">
        <pz:metadata type="locallocation" empty="PAZPAR2_NULL_VALUE">
          <xsl:value-of select="tmarc:sa"/>
        </pz:metadata>
        <pz:metadata type="callnumber" empty="PAZPAR2_NULL_VALUE">
          <xsl:value-of select="tmarc:sb"/>
        </pz:metadata>
        <pz:metadata type="publicnote" empty="PAZPAR2_NULL_VALUE">
          <xsl:value-of select="tmarc:sc"/>
        </pz:metadata>
        <pz:metadata type="available" empty="PAZPAR2_NULL_VALUE">
          <xsl:choose>
            <xsl:when test="tmarc:ss = 'N'">Available</xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="tmarc:sd"/>
            </xsl:otherwise>
          </xsl:choose>
        </pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d948 | tmarc:d991">
        <pz:metadata type="holding">
          <xsl:for-each select="tmarc:s">
            <xsl:if test="position() &gt; 1">
              <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:value-of select="."/>
          </xsl:for-each>
        </pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d999">
        <pz:metadata type="localid">
          <xsl:choose>
            <xsl:when test="tmarc:sa">
              <xsl:value-of select="tmarc:sa"/>
            </xsl:when>
            <xsl:when test="tmarc:sc">
              <xsl:value-of select="tmarc:sc"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="tmarc:sd"/>
            </xsl:otherwise>
          </xsl:choose>
        </pz:metadata>
      </xsl:for-each>

      <!-- passthrough id data -->
      <xsl:for-each select="pz:metadata">
        <xsl:copy-of select="."/>
      </xsl:for-each>

      <!-- other stylesheets importing this might want to define this -->
      <xsl:call-template name="record-hook"/>

    </pz:record>
  </xsl:template>

  <xsl:template match="text()" />

</xsl:stylesheet>
