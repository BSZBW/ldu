<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
                version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:daia="http://ws.gbv.de/daia/"
                xmlns:pz="http://www.indexdata.com/pazpar2/1.0">
    <xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>
    <xsl:strip-space elements="*" />
    <xsl:namespace-alias stylesheet-prefix="daia" result-prefix="pz"/>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="pz:metadata[@type='available']">
        <xsl:variable name="ws" select="."/>
        <xsl:variable name="help" select="../pz:metadata[@type='medium']"/>
        <xsl:choose>
            <xsl:when  test="contains($help,'ebook') or contains($help,'ejournal')">
                <pz:metadata type="countEx">
                    <xsl:copy-of select="'1'"/>
                </pz:metadata>
                <pz:metadata type="countAvail">
                    <xsl:copy-of select="'1'"/>
                </pz:metadata>
                <pz:metadata type="available">
                    <xsl:copy-of select="'0'"/>
                </pz:metadata>
            </xsl:when>
            <xsl:otherwise>
                <pz:metadata type="countEx">
				    <xsl:copy-of select="count(document($ws)//daia:item)"/>
                </pz:metadata>
                <pz:metadata type="countAvail">
                   <xsl:copy-of select="count(document($ws)/daia:daia/daia:document/daia:item//daia:message[.='available'])+count(document($ws)/daia:daia/daia:document/daia:item//daia:message[.='returned today'])"/>
                </pz:metadata>
                <pz:metadata type="available">
                   <xsl:choose>
                   <xsl:when test="count(document($ws)/daia:daia/daia:document/daia:item//daia:message[.='available'])+count(document($ws)/daia:daia/daia:document/daia:item//daia:message[.='returned today']) > 0">
		      <xsl:value-of select="'0'"/>
	           </xsl:when>
                   <xsl:otherwise>
                      <xsl:value-of select="'1'"/>
                   </xsl:otherwise>
                   </xsl:choose>
                </pz:metadata>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
