<?php

$conf['output'] = 'browser';
$conf['usecache'] = true;
$conf['template'] = 'default.xsl';
$conf['command'] = 'fop -xml "{xml}" -xsl "{xsl}" -pdf "{pdf}"';
