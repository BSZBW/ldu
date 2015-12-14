<?xml version="1.0" encoding="UTF-8"?>
<!--
	Create special fields used for BSZ.

	Nov 2014 C. Elmlinger, BSZ Konstanz <clemens.elmlinger@bsz-bw.de>
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
