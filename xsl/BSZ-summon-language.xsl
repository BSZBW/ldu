<?xml version="1.0" encoding="UTF-8"?>
<!--

        Transfer of Summon language code to iso 639-2

	October 2014
	C. Elmlinger,  BSZ Konstanz <clemens.elmlinger@bsz-bw.de>>
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

	
	<xsl:template match="pz:metadata[@type='language']">
		<pz:metadata type="language">
			<xsl:choose>
				<xsl:when test="starts-with(., 'English')">
					<xsl:value-of select="'eng'"/>
				</xsl:when>
				<xsl:when test="starts-with(., 'Spanish')">
					<xsl:value-of select="'spa'"/>
				</xsl:when>
				<xsl:when test="starts-with(., 'Chinese')">
					<xsl:value-of select="'chi'"/>
				</xsl:when>
				<xsl:when test="starts-with(., 'German')">
					<xsl:value-of select="'ger'"/>
				</xsl:when>
				<xsl:when test="starts-with(., 'French')">
					<xsl:value-of select="'fre'"/>
				</xsl:when>
				<xsl:when test="starts-with(., 'Italian')">
					<xsl:value-of select="'ita'"/>
				</xsl:when>
				<xsl:when test="starts-with(., 'Japanese')">
					<xsl:value-of select="'jpn'"/>
				</xsl:when>
				<xsl:when test="starts-with(., 'Polish')">
					<xsl:value-of select="'pol'"/>
				</xsl:when>
				<xsl:when test="starts-with(., 'Portuguese')">
					<xsl:value-of select="'por'"/>
				</xsl:when>
				<xsl:when test="starts-with(., 'Russian')">
					<xsl:value-of select="'rus'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'sonstig'"/>
				</xsl:otherwise>
			</xsl:choose>
		</pz:metadata>
	</xsl:template>


</xsl:stylesheet>
