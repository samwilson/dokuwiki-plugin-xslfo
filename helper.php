<?php
/**
 * DokuWiki xslfo plugin: Export single pages to PDF via XSL-FO.
 * 
 * @license GPL 3 (http://www.gnu.org/licenses/gpl.html)
 * @author Sam Wilson <sam@samwilson.id.au>
 */

/**
 * Ensure that we're running within Dokuwiki.
 */
if (!defined('DOKU_INC')) {
    die();
}

/**
 * Helper class for static methods.
 */
class helper_plugin_xslfo extends DokuWiki_Plugin {

    /**
     * Get a list of all XSL files available in the current template.
     * 
     * @return array List of XSL files
     */
    public static function xsl() {
        $plugin = array('default.xsl');
        $template = preg_grep('|.*\.xsl$|i', scandir(tpl_incdir()));
        return array_merge($plugin, $template);
    }

}
