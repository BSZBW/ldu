<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:pz="http://www.indexdata.com/pazpar2/1.0">
    <xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>

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
