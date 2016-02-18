<?xml version="1.0"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:pz="http://www.indexdata.com/pazpar2/1.0"
	version="1.0">
<!--
	Transforms Solr documents into pazpar2 records.
	
	Catches fields of type str, int, long, float
	as well as arrays of those fields.
	
	2013 Sven-S. Porst, SUB Göttingen <porst@sub.uni-goettingen.de>
	modified by C. Elmlinger BSZ Konstanz <clemens.elmlinger@bsz-bw.de>
 
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
	
	<xsl:output indent="yes" method="xml" encoding="UTF-8"/>

	<xsl:template match="text()"/>


	<xsl:template match="/">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="response">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template	match="records">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="doc">
		<pz:record>
			<xsl:apply-templates/>
		</pz:record>
	</xsl:template>

	<xsl:template match="arr">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="str|int|long|float">
		<xsl:variable name="fieldName">
			<xsl:choose>
				<xsl:when test="@name">
					<xsl:value-of select="@name"/>
				</xsl:when>
				<xsl:when test="../@name">
					<xsl:value-of select="../@name"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

                <xsl:if test="not(@name='author') and not(@name='author-syn')">
		<pz:metadata type="{$fieldName}">
			<xsl:value-of select="."/>
		</pz:metadata>
                </xsl:if>
	</xsl:template>

</xsl:stylesheet>
