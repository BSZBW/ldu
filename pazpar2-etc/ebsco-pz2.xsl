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
-->
	
	<xsl:output indent="yes" method="xml" encoding="UTF-8"/>

	<xsl:template match="text()"/>


	<xsl:template match="response/result">
	  <document>
		<xsl:apply-templates/>
	  </document>
	</xsl:template>
<!--
	<xsl:template match="response">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template	match="records">
		<xsl:apply-templates/>
	</xsl:template>
-->
	
	<xsl:template match="doc">
		<pz:record>
			<xsl:apply-templates/>
		</pz:record>
	</xsl:template>

	<xsl:template match="lst">
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

                <xsl:if test="not(@name='status') and not(@name='QTime') and not(@name='q') and not(@name='facet') and not(@name='wt')">
		<pz:metadata type="{$fieldName}">
			<xsl:value-of select="."/>
		</pz:metadata>
                </xsl:if>
	</xsl:template>
</xsl:stylesheet>
