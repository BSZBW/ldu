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
				<xsl:when test="starts-with(., 'Englisch')">
					<xsl:value-of select="'eng'"/>
				</xsl:when>
				<xsl:when test="starts-with(., 'Spanisch')">
					<xsl:value-of select="'spa'"/>
				</xsl:when>
				<xsl:when test="starts-with(., 'Chinesisch')">
					<xsl:value-of select="'chi'"/>
				</xsl:when>
				<xsl:when test="starts-with(., 'Deutsch')">
					<xsl:value-of select="'ger'"/>
				</xsl:when>
				<xsl:when test="starts-with(., 'Franz')">
					<xsl:value-of select="'fre'"/>
				</xsl:when>
				<xsl:when test="starts-with(., 'Italienisch')">
					<xsl:value-of select="'ita'"/>
				</xsl:when>
				<xsl:when test="starts-with(., 'Japanisch')">
					<xsl:value-of select="'jpn'"/>
				</xsl:when>
				<xsl:when test="starts-with(., 'Polnisch')">
					<xsl:value-of select="'pol'"/>
				</xsl:when>
				<xsl:when test="starts-with(., 'Portugiesisch')">
					<xsl:value-of select="'por'"/>
				</xsl:when>
				<xsl:when test="starts-with(., 'Russisch')">
					<xsl:value-of select="'rus'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'sonstig'"/>
				</xsl:otherwise>
			</xsl:choose>
		</pz:metadata>
	</xsl:template>


</xsl:stylesheet>
