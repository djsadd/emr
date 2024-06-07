<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- Generated by Hand -->
<!--
Copyright (C) 2011 Julia Longtin <julia.longtin@gmail.com>

This program is free software; you can redistribute it and/or
Modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.
 -->
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" omit-xml-declaration="yes"/>
<xsl:include href="common_objects.xslt"/>
<xsl:include href="report_objects.xslt"/>
<xsl:strip-space elements="*"/>
<xsl:template match="/">
<xsl:apply-templates select="form"/>
</xsl:template>
<!-- The variable telling field_objects.xslt what form is calling it -->
<xsl:variable name="page">show</xsl:variable>
<!-- if fetchrow has contents, a variable with that name will be created by field_objects.xslt, and all fields created by it will retreive values from it. -->
<xsl:variable name="fetchrow">xyzzy</xsl:variable>
<xsl:template match="form">
<xsl:text disable-output-escaping="yes"><![CDATA[<?php
/*
 * The page shown when the user requests to see this form in a "report view". does not allow editing contents, or saving. has 'print' and 'delete' buttons.
 */

/* for $GLOBALS[], ?? */
require_once('../../globals.php');
require_once($GLOBALS['srcdir'].'/api.inc.php');
/* for display_layout_rows(), ?? */
require_once($GLOBALS['srcdir'].'/options.inc.php');

use OpenEMR\Common\Acl\AclMain;
use OpenEMR\Core\Header;

]]></xsl:text>
<!-- These templates generate PHP code -->
<xsl:apply-templates select="table|RealName|safename|acl|style"/>
<!-- Fetch form contents from the database. -->
<xsl:apply-templates select="table" mode="fetch"/>
<!-- set up for using the layouts engine -->
<xsl:apply-templates select="layout" mode="head"/>
<!-- and set up the fake table of layouts for fields using the manual engine -->
<xsl:apply-templates select="manual" mode="head"/>
<xsl:text disable-output-escaping="yes"><![CDATA[
/* since we have no-where to return, abuse returnurl to link to the 'edit' page */
/* FIXME: pass the ID, create blank rows if necissary. */
$returnurl = "../../forms/$form_folder/view.php?mode=noencounter";

]]></xsl:text>
<!-- FIXME: this needs to work for layout based fields added after form creation. ideas? -->
<xsl:if test="//field[@type='date']">
<xsl:text disable-output-escaping="yes"><![CDATA[/* remove the time-of-day from all date fields */
]]></xsl:text>
<xsl:apply-templates select="//field[@type='date']" mode="split_timeofday"/>
</xsl:if>
<xsl:call-template name="generate_chkdata"/>
<xsl:text disable-output-escaping="yes"><![CDATA[
?><!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>

<!-- declare this document as being encoded in UTF-8 -->
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" ></meta>

<!-- assets -->
<?php Header::setupHeader(); ?>
<!-- Form Specific Stylesheet. -->
<link rel="stylesheet" href="../../forms/<?php echo $form_folder; ?>/style.css">

<script>

<!-- FIXME: this needs to detect access method, and construct a URL appropriately! -->
function PrintForm() {
    newwin = window.open("<?php echo $rootdir.'/forms/'.$form_folder.'/print.php?id='.$_GET['id']; ?>","print_<?php echo $form_name; ?>");
}

</script>
<title><?php echo htmlspecialchars('Show '.$form_name); ?></title>

</head>
<body class="body_top">

<div id="title">
<span class="title"><?php xl($form_name,'e'); ?></span>
<?php
 if ($thisauth_write_addonly)
  { ?>
<a href="<?php echo $returnurl; ?>" onclick="top.restoreSession()">
<span class="back"><?php xl($tmore,'e'); ?></span>
</a>
<?php }; ?>
</div>

<form method="post" id="<?php echo $form_folder; ?>" action="">

<!-- container for the main body of the form -->
<div id="form_container">

<div id="show">

]]></xsl:text>
<xsl:apply-templates select="H2|H3|H4|layout|manual"/>
<xsl:text disable-output-escaping="yes"><![CDATA[

</div><!-- end show -->

</div><!-- end form_container -->

<!-- Print button -->
<div id="button_bar" class="button_bar">
<fieldset class="button_bar">
<input type="button" class="print" value="<?php xl('Print','e'); ?>" />
</fieldset>
</div><!-- end button_bar -->

</form>
<script>
// jQuery stuff to make the page a little easier to use

$(function () {
    $(".print").click(function() { PrintForm(); });
});
</script>
</body>
</html>
]]></xsl:text>
</xsl:template>
</xsl:stylesheet>
