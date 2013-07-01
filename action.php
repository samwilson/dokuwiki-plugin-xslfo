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
if (!defined('DOKU_PLUGIN')) {
    define('DOKU_PLUGIN', DOKU_INC.'lib/plugins/');
}

/**
 * The main xslfo class.
 */
class action_plugin_xslfo extends DokuWiki_Action_Plugin {

    /** @var string Current XSL template */
    private $template;

    /** @var string Full path to the current XSL file */
    private $template_path;

    /**
     * Register the events
     */
    function register(&$controller) {
        $controller->register_hook('ACTION_ACT_PREPROCESS', 'BEFORE', $this, 'preprocess', array());
    }

    /**
     * Do the HTML to PDF conversion work
     *
     * @param Doku_Event $event
     * @param array      $param
     * @return bool
     */
    function preprocess(&$event, $param) {
        global $ID, $REV, $ACT;

        // Check that this is our action
        if ($ACT != 'export_pdf') {
            return false;
        }
        $event->preventDefault();

        // Check for the XML plugin
        if (!class_exists('renderer_plugin_xml')) {
            msg('The XML plugin is required by the XSLFO plugin.', -1);
            return false;
        }

        // Check user authorisation
        if (auth_quickaclcheck($ID) < AUTH_READ) {
            return false;
        }

        // Set up template and page title
        $this->setupTemplate();
        $title = p_get_first_heading($ID);

        // Prepare and check the cache
        // (The same cache key is also used below for the XML file)
        $cache_key = $ID.$REV.$this->template;
        $pdf_cache = new cache($cache_key, '.pdf');
        $cache_dependencies['files'] = array(
            __FILE__,
            wikiFN($ID, $REV),
            $this->template_path,
            getConfigFiles('main'),
        );
        if (!$this->getConf('usecache') || !$pdf_cache->useCache($cache_dependencies)) {
            if (!$this->generatePDF($cache_key, $pdf_cache->cache)) {
                return false;
            }
        }

        $this->sendFile($pdf_cache->cache, $title);
    }

    /**
     * Generate the PDF file.
     * 
     * @global string $ID
     * @global string $REV
     * @param string $cache_key The key of the cache, for the XML file
     * @param string $pdf_filename The full path to write the PDF to
     * @return boolean True if the PDF was generated successfully
     */
    public function generatePDF($cache_key, $pdf_filename) {
        global $ID, $REV;

        // Get the XML and save it to a cache
        $xml = p_cached_output(wikiFN($ID, $REV), 'xml', $ID);
        //$xml_cache = new cache_renderer($ID, wikiFN($ID, $REV), 'xml');
        $xml_filename = getCacheName($cache_key, '.xml');
        io_saveFile($xml_filename, $xml);

        // Replace placeholders in the command string
        $filenames = array(
            'xml' => $xml_filename,
            'xsl' => $this->template_path,
            'pdf' => $pdf_filename,
        );
        $command_template = $this->getConf('command').' 2>&1';
        $command = preg_replace_callback('/{(\w+)}/', function ($m) use ($filenames) {
                    return $filenames[$m[1]];
                }, $command_template);

        // Execute the FO processor command, and give up if it fails
        if (file_exists($pdf_filename)) {
            unlink($pdf_filename);
        }
        io_exec($command, null, $out);
        if (!file_exists($pdf_filename)) {
            msg("Unable to produce PDF.", -1);
            msg("Command: <code>$command</code><br />Output:<pre>".$out.'</pre>', 0, '', '', MSG_ADMINS_ONLY);
            return false;
        } else {
            return true;
        }
    }

    /**
     * Get the full filesystem path to the current XSL in the current site
     * template's xslfo directory.
     * 
     * @uses $_REQUEST['tpl']
     * @return string The full path to the XSL file
     */
    protected function setupTemplate() {
        if (isset($_REQUEST['tpl'])) {
            $this->template = $_REQUEST['tpl'];
        } else {
            $this->template = $this->getConf('template');
        }
        $this->template_path = realpath(tpl_incdir().$this->template);
        if (!$this->template_path) {
            $this->template = 'default.xsl';
            $this->template_path = __DIR__.DIRECTORY_SEPARATOR.$this->template;
        }
    }

    /**
     * Send the PDF file to the user.
     * 
     * @param string $file Full filesystem path to the cached PDF
     * @param string $title The title of the document, to be turned into a filename
     */
    public function sendFile($file, $title) {

        // Start sending HTTP headers
        header('Content-Type: application/pdf');
        header('Cache-Control: must-revalidate, no-transform, post-check=0, pre-check=0');
        header('Pragma: public');
        http_conditionalRequest(filemtime($file));

        // Construct a nice filename from the title
        $filename = rawurlencode(cleanID(strtr($title, ':/;"', '    ')));
        if ($this->getConf('output') == 'file') {
            header('Content-Disposition: attachment; filename="'.$filename.'.pdf";');
        } else {
            header('Content-Disposition: inline; filename="'.$filename.'.pdf";');
        }

        // Use sendfile if possible
        if (http_sendfile($file)) {
            exit(0);
        }

        // Send file or fail with error
        $fp = @fopen($file, "rb");
        if ($fp) {
            http_rangeRequest($fp, filesize($file), 'application/pdf');
            exit(0);
        } else {
            header("HTTP/1.0 500 Internal Server Error");
            print "Could not read file - bad permissions?";
            exit(1);
        }
    }

}
