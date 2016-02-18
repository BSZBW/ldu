<?xml version="1.0" encoding="UTF-8"?>
<!--
	Create special fields used for BSZ.

	Nov 2014 C. Elmlinger, BSZ Konstanz <clemens.elmlinger@bsz-bw.de>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2, or (at your option)
    any later version.
  
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
  
    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software Foundation,
    Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA.	
	
-->

<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:pz="http://www.indexdata.com/pazpar2/1.0">

	<xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>
	<xsl:strip-space elements="*" />

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>



	<xsl:template match="pz:record">
		<xsl:copy>
			<!-- preserve all existing nodes -->
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

        <!--xsl:variable name="dedup" select="//pz:metadata[@type='department']"/>

        <xsl:template match="/">
          <xsl:for-each select="$dedup">
             <xsl:if test="generate-id() = generate-id($dedup[. = current()][1])">
                <pz:metadata type="department">
                <xsl:value-of select="."/>
                </pz:metadata>
             </xsl:if>
          </xsl:for-each>
        </xsl:template-->
 
        <xsl:template match="pz:metadata[@type='isbn']">
        <pz:metadata type="isbn">
            <xsl:value-of select="."/>
        </pz:metadata>
        <!--pz:metadata type="coverurls">
            <xsl:value-of select="concat('http://blauen.bsz-bw.de/bookcover.php?
size=small&amp;isn=',.)"/>
        </pz:metadata>
        <pz:metadata type="coverurlm">
            <xsl:value-of select="concat('http://blauen.bsz-bw.de/bookcover.php?
size=medium&amp;isn=',.)"/>
        </pz:metadata>
        <pz:metadata type="coverurll">
            <xsl:value-of select="concat('http://blauen.bsz-bw.de/bookcover.php?
size=large&amp;isn=',.)"/>
        </pz:metadata-->
        </xsl:template>
</xsl:stylesheet>
