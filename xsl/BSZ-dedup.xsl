<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:pz="http://www.indexdata.com/pazpar2/1.0">
    <xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>
	
<!--
	Deduplication of ISBN data (formerly ISBN10 or ISBN13).

	2014-2015: Clemens Elmlinger, BSZ Konstanz <clemens.elmlinger@bsz-bw.de>
	
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

    <xsl:variable name="dedupDep" select="//pz:metadata[@type='department']"/>
    <xsl:variable name="dedupISBN" select="//pz:metadata[@type='isbn']"/>

    <xsl:template match="/">

        <pz:record>
        <xsl:apply-templates select="@*|node()"/>
        <xsl:for-each select="$dedupDep">
            <xsl:if test="generate-id() = generate-id($dedupDep[. = current()][1])">
                <pz:metadata type="department">
                <xsl:value-of select="."/>
                </pz:metadata>
            </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="$dedupISBN">
            <xsl:if test="generate-id() = generate-id($dedupISBN[. = current()][1])">
                <pz:metadata type="isbn">
                <xsl:value-of select="."/>
                </pz:metadata>
            </xsl:if>
        </xsl:for-each>

        </pz:record>
    </xsl:template>

    <xsl:template match="pz:metadata[@type!='department' and @type!='isbn']">
        <xsl:copy-of select="."/>
    </xsl:template>

</xsl:stylesheet>
