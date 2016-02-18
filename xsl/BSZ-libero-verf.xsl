<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xmlns:kn="http://www.ub.uni-konstanz.de/xmlschema/libero/availability"
	xmlns:pz="http://www.indexdata.com/pazpar2/1.0">
    <xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>
	
<!--
	Getting libero data for availability.

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
	
    <xsl:strip-space elements="*" />
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>


    <xsl:template match="pz:metadata[@type='available']">
        <xsl:variable name="ws" select="."/>
        <xsl:variable name="help" select="../pz:metadata[@type='title-medium']"/>
 
        <xsl:choose>
        <xsl:when  test="contains($help,'Elektronische Ressource')">
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
               <xsl:copy-of select="count(document($ws)/kn:results/kn:result/kn:availability)"/>
           </pz:metadata>
            <pz:metadata type="countAvail">
                <xsl:copy-of select="count(document($ws)/kn:results/kn:result/kn:availability[contains(.,'verf')])"/>
            </pz:metadata>
            <pz:metadata type="available">
               <xsl:variable name="av" select="document($ws)/kn:results/kn:result/kn:availability"/>
               <xsl:choose>
               <xsl:when test="contains($av,'verf')">
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
    <!-- xsl:template match="pz:metadata[@type='available']" >
        <pz:metadata type="available">0</pz:metadata-->
