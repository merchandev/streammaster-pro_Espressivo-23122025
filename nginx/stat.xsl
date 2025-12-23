<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
   <xsl:output method="html" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN" />
   <xsl:template match="/">
      <html>
         <head>
            <title>RTMP Statistics</title>
            <style>
               body { font-family: sans-serif; background: #f0f2f5; padding: 20px; }
               table { border-collapse: collapse; width: 100%; background: white; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
               th, td { text-align: left; padding: 12px; border-bottom: 1px solid #ddd; }
               th { background-color: #667eea; color: white; }
               tr:hover { background-color: #f5f5f5; }
               h1 { color: #333; }
            </style>
         </head>
         <body>
            <h1>StreamMaster Pro - RTMP Stats</h1>
            <xsl:apply-templates select="rtmp"/>
         </body>
      </html>
   </xsl:template>

   <xsl:template match="rtmp">
      <table>
         <tr>
            <th>Name</th>
            <th>State</th>
            <th>Time</th>
            <th>Bitrate</th>
            <th>Video/Audio</th>
         </tr>
         <xsl:apply-templates select="server/application"/>
      </table>
   </xsl:template>

   <xsl:template match="application">
      <xsl:apply-templates select="live/stream"/>
   </xsl:template>

   <xsl:template match="stream">
      <tr>
         <td><xsl:value-of select="name"/></td>
         <td>
             <xsl:choose>
                 <xsl:when test="publishing">Publishing</xsl:when>
                 <xsl:otherwise>Idle</xsl:otherwise>
             </xsl:choose>
         </td>
         <td><xsl:value-of select="time"/></td>
         <td><xsl:value-of select="bw_in"/></td>
         <td><xsl:value-of select="meta/video/width"/>x<xsl:value-of select="meta/video/height"/></td>
      </tr>
   </xsl:template>
</xsl:stylesheet>
