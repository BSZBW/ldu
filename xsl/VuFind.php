<?php
/**
* XSLT importer support methods.
*
*/

/**
* XSLT support class -- all methods of this class must be public and static;
* they will be automatically made available to your XSL stylesheet for use
* with the php:function() function.
*
*/

echo "Hello World!";

class VuFind
{

    /**
     * Fetch some ASCII text from an URL
     * @param string $url URL of file to retrieve.
     *
     * @return string     text contents of file.
     * @access public
     */
    public static function fetch_text()
    {
// mach irgendwas mit der URL
// vgl. http://php.net/manual/de/function.http-get.php oder http://php.net/manual/de/function.file-get-contents.php

// $response = http_get($url, array("timeout"=>1), $info); 
// oder:
// $response = file_get_contents($url);
$response = "Winkler,Stefan";
echo $response;
// Text zurückgeben
return $response;
    }
}
?>

