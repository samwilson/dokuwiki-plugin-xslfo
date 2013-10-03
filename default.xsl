<?xml version="1.0" encoding="utf-8"?>
<!--
  - DokuWiki xslfo plugin: Export single pages to PDF via XSL-FO.
  - 
  - @license GPL 3 (http://www.gnu.org/licenses/gpl.html)
  - @author Sam Wilson <sam@samwilson.id.au>
  -->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format">
    <xsl:variable name="tplincdir" select="document/dokuwiki/tplincdir/text()" />
    <xsl:variable name="mediadir" select="document/dokuwiki/mediadir/text()" />

    <xsl:template match="/">
        <fo:root>

            <fo:layout-master-set>
                <fo:simple-page-master master-name="A4-portrait" page-height="29.7cm" page-width="21.0cm" margin="2cm">
                    <fo:region-body margin-top="2.5cm" margin-bottom="2.5cm"/>
                    <fo:region-before extent="2.0cm"/>
                    <fo:region-after extent="2.0cm"/>
                </fo:simple-page-master>
            </fo:layout-master-set>

            <fo:page-sequence master-reference="A4-portrait">

                <fo:static-content flow-name="xsl-region-before">
                    <fo:block>
                        <xsl:call-template name="header"/>
                    </fo:block>
                </fo:static-content>

                <fo:static-content flow-name="xsl-region-after">
                    <fo:block>
                        <xsl:call-template name="footer"/>
                    </fo:block>
                </fo:static-content>

                <xsl:apply-templates select="document" />

            </fo:page-sequence>

        </fo:root>
    </xsl:template>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- Begin header and footer -->
    <xsl:template name="header">
        <fo:block font-size="8pt" border-bottom="thin solid black">
            <fo:block-container position="absolute">
                <fo:block text-align="left">
                    <xsl:value-of select="//header[@level='1']" />
                </fo:block>
            </fo:block-container>
            <fo:block text-align="center">
                
            </fo:block>
            <fo:block-container position="absolute">
                <fo:block text-align="right">
                    <xsl:value-of select="//dokuwiki/lastmod/text()" />
                </fo:block>
            </fo:block-container>
        </fo:block>
    </xsl:template>
    <xsl:template name="footer">
        <fo:block font-size="8pt" border-top="thin solid black" text-align="center">
            <fo:table table-layout="fixed">
                <fo:table-body>
                    <fo:table-row>
                        <fo:table-cell>
                            <fo:block text-align="left">
                                <xsl:value-of select="//dokuwiki/url/text()" />
                            </fo:block>
                        </fo:table-cell>
                        <fo:table-cell>
                            <fo:block text-align="right">
                                Page <fo:page-number/> of <fo:page-number-citation ref-id="document-end" />
                            </fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                </fo:table-body>
            </fo:table>
        </fo:block>
    </xsl:template>
    <!-- End header and footer -->

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- Document and sections -->
    <xsl:template match="document">
        <fo:flow flow-name="xsl-region-body">
            <xsl:apply-templates />
            <!-- End ID for total-page-count reference in header -->
            <fo:block id="document-end"></fo:block>
        </fo:flow>
    </xsl:template>

    <xsl:template match="section">
        <fo:block>
            <xsl:apply-templates />
        </fo:block>
    </xsl:template>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- Headings -->
    <xsl:template match="header[@level='1']">
        <fo:block font-size="20pt" line-height="15pt" space-before="15pt" space-after="12pt" text-align="center">
            <xsl:apply-templates />
        </fo:block>
    </xsl:template>
    <xsl:template match="header[@level='2']">
        <fo:block font-size="17pt" line-height="15pt" space-before="15pt" space-after="12pt">
            <xsl:apply-templates />
        </fo:block>
    </xsl:template>
    <xsl:template match="header[@level='3']">
        <fo:block font-size="12pt" space-before="15pt" space-after="5pt">
            <xsl:apply-templates />
        </fo:block>
    </xsl:template>

    <!-- Paragraphs -->
    <xsl:template match="p">
        <fo:block font-size="10pt" space-after="12pt">
            <xsl:apply-templates />
        </fo:block>
    </xsl:template>

    <!-- Inline elements: strong, emphasis, monospace, underline -->
    <xsl:template match="strong">
        <fo:inline font-weight="bold">
            <xsl:apply-templates />
        </fo:inline>
    </xsl:template>

    <xsl:template match="monospace">
        <fo:inline font-family="monospace">
            <xsl:apply-templates />
        </fo:inline>
    </xsl:template>

    <xsl:template match="emphasis">
        <fo:inline font-style="italic">
            <xsl:apply-templates />
        </fo:inline>
    </xsl:template>

    <xsl:template match="underline">
        <fo:inline text-decoration="underline">
            <xsl:apply-templates />
        </fo:inline>
    </xsl:template>

    <xsl:template match="multiplyentity">
        <fo:inline>
            <xsl:value-of select="./x" />
            <xsl:text>&#215;</xsl:text>
            <xsl:value-of select="./y" />
        </fo:inline>
    </xsl:template>

    <xsl:template match="preformatted|code">
        <fo:block font-family="monospace" font-size="9pt" space-after="12pt"
                  white-space-collapse="false" wrap-option="no-wrap" padding="3pt"
                  linefeed-treatment="preserve" white-space-treatment="preserve">
            <xsl:apply-templates />
        </fo:block>
    </xsl:template>
    <xsl:template match="code">
        <fo:block font-family="monospace" font-size="9pt" space-after="12pt"  padding="3pt"
                  white-space-collapse="false" wrap-option="no-wrap" background-color="#efefef"
                  linefeed-treatment="preserve" white-space-treatment="preserve">
            <xsl:apply-templates />
        </fo:block>
    </xsl:template>
    <xsl:template match="file">
        <fo:block font-family="monospace" font-size="9pt" space-after="12pt"
                  white-space-collapse="false" wrap-option="no-wrap" padding="3pt"
                  linefeed-treatment="preserve" white-space-treatment="preserve" border="thin solid black">
            <xsl:apply-templates />
        </fo:block>
    </xsl:template>

    <xsl:template match="subscript">
        <fo:inline vertical-align="sub" font-size="75%">
            <xsl:apply-templates />
        </fo:inline>
    </xsl:template>

    <xsl:template match="superscript">
        <fo:inline vertical-align="super" font-size="75%">
            <xsl:apply-templates />
        </fo:inline>
    </xsl:template>

    <xsl:template match="delete">
        <fo:inline text-decoration="line-through">
            <xsl:apply-templates />
        </fo:inline>
    </xsl:template>

    <xsl:template match="linebreak">
        <fo:block></fo:block>
    </xsl:template>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- Links -->
    <xsl:template match="link">
        <fo:basic-link color="blue">
            <xsl:choose>
                <xsl:when test="starts-with(@href, '#')">
                    <xsl:attribute name="internal-destination">
                        <xsl:value-of select="substring(@href, 2)"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="external-destination">
                        <xsl:value-of select="@href"/>
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates />
        </fo:basic-link>
    </xsl:template>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- Images and other attachments -->
    <xsl:template match="media">
        <xsl:variable name="src" select="@src" />
        <xsl:variable name="ext" select="@ext" />
        <xsl:variable name="width" select="@width" />
        <xsl:variable name="height" select="@height" />
        <xsl:variable name="filename">
            <xsl:value-of select="//dokuwiki/media_filename[@src=$src and @width=$width and @height=$height]/text()" />
        </xsl:variable>
        <fo:inline>
            <fo:basic-link color="blue">
                <xsl:attribute name="external-destination">
                    <xsl:value-of select="@href"/>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="(@ext!='jpg' and @ext!='gif') or @linking = 'linkonly'">
                        <fo:external-graphic content-width="1em" src="url('{$tplincdir}../../images/fileicons/{$ext}.png')" />
                        <xsl:apply-templates />
                    </xsl:when>
                    <xsl:otherwise>
                        <fo:external-graphic src="url({$filename})" />
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="(@ext!='jpg' and @ext!='gif' and not(normalize-space(.))) or @linking = 'linkonly'">
                        <xsl:value-of select="@basename" />
                    </xsl:when>
                </xsl:choose>
            </fo:basic-link>
        </fo:inline>
    </xsl:template>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- Lists -->
    <xsl:template match="listu|listo">
        <fo:list-block provisional-distance-between-starts="0.5cm" provisional-label-separation="0.2cm" font-size="10pt">
            <xsl:attribute name="start-indent">
                <xsl:variable name="ancestors">
                    <xsl:choose>
                        <xsl:when test="count(ancestor::listo) or count(ancestor::listu)">
                            <xsl:value-of select="count(ancestor::listo) + count(ancestor::listu)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>0</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:value-of select="concat((0.5+($ancestors*0.5)), 'cm')"/>
            </xsl:attribute>
            <xsl:apply-templates />
        </fo:list-block>
    </xsl:template>

    <xsl:template match="listu/listitem">
        <fo:list-item>
            <fo:list-item-label end-indent="label-end()">
                <fo:block>
                    <xsl:choose>
                        <xsl:when test="count(ancestor::listu)=1">&#x2022;</xsl:when>
                        <xsl:when test="count(ancestor::listu)=2">&#x2013;</xsl:when>
                        <xsl:otherwise>&#x2219;</xsl:otherwise>
                    </xsl:choose>
                </fo:block>
            </fo:list-item-label>
            <fo:list-item-body start-indent="body-start()">
                <fo:block>
                    <xsl:apply-templates />
                </fo:block>
            </fo:list-item-body>
        </fo:list-item>
    </xsl:template>
    <xsl:template match="listo/listitem">
        <fo:list-item>
            <fo:list-item-label end-indent="label-end()">
                <fo:block>
                    <xsl:variable name="format">
                        <xsl:choose>
                            <xsl:when test="count(ancestor::listo)=1">1.</xsl:when>
                            <xsl:when test="count(ancestor::listo)=2">a)</xsl:when>
                            <xsl:when test="count(ancestor::listo)=3">I.</xsl:when>
                            <xsl:when test="count(ancestor::listo)=4">A)</xsl:when>
                            <xsl:when test="count(ancestor::listo)=5">i.</xsl:when>
                            <xsl:otherwise>1.</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:number format="{$format}" />
                </fo:block>
            </fo:list-item-label>
            <fo:list-item-body start-indent="body-start()">
                <fo:block>
                    <xsl:apply-templates />
                </fo:block>
            </fo:list-item-body>
        </fo:list-item>
    </xsl:template>
    <xsl:template match="listcontent">
        <fo:block>
            <xsl:apply-templates />
        </fo:block>
    </xsl:template>

</xsl:stylesheet>
