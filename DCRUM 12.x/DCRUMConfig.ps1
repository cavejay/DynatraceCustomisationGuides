# CAS/ADS custom Styling Script

# Author: Michael Ball
# Contact: michael.ball@dynatrace.com
# version: 170310

# This script is based on work done by Luke Boyling

# Assumption: that the Adlex registry key has not changed and is the most reliable way to get the install folder across versions.

# Variables:
$LongTitleBarDefault = "Normal Length Header Text" 
$ShortTitleBarDefault = "Short Stuff"
$SecurityClassificationDefault = "Security Classification Marking"


## Check we're admin
$RunningAsAdmin =    ( [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(   [Security.Principal.WindowsBuiltInRole] "Administrator")
$PWD = Get-Location
if (-Not $RunningAsAdmin ) {
	Write-Output "Changes to DCRUM configuration files require admin privileges. Please run this script as an administrator."
	break
}


## Check CAS and/or ADS are actually installed
$AdlexRegistry = "HKLM:\Software\Adlex"
if (-not (Test-Path -Path $AdlexRegistry -PathType Container)) {
	#Key does not exist
	Write-Output "Unable to detect any registered DCRUM components"
	break
}
$AdlexProperties = Get-ItemProperty -Path $AdlexRegistry
if (-not $AdlexProperties) {
	#Key has no values
	Write-Output "Unable to detect any registered DCRUM components"
	break
}

$CASInstalled = (Get-Member -InputObject $AdlexProperties -Name "CAS_userInstallRoot")-ne $Null
$ADSInstalled = (Get-Member -InputObject $AdlexProperties -Name "ADS_userInstallRoot")-ne $Null

if (-Not $CASInstalled  -And -Not $ADSInstalled) {
	#Neither CAS or ADS installed
	Write-Output "Unable to detect a registered CAS or ADS installation"
	exit
}


## Determine which product should be styled
$SelectedProduct = $()
$CASKey = Get-ChildItem "HKLM:\Software\Adlex\Watchdog" | Where {$(Get-ItemProperty $_.pspath).pschildname.EndsWith("Central Analysis Server")}
$ADSKey = Get-ChildItem "HKLM:\Software\Adlex\Watchdog" | Where {$(Get-ItemProperty $_.pspath).pschildname.EndsWith("Advanced Diagnostics Server")}

if ($CASInstalled -And $ADSInstalled) {
	do {
		Write-Output "Multiple DCRUM components have been detected on this system. Please select one of the following:"
		Write-Output ""	
		Write-Output "  0) Exit without making any changes"
		Write-Output "  1) $($CASKey.Name)"
		Write-Output "  2) $($ADSKey.Name)"
		Write-Output ""
		$Selection = Read-Host -Prompt "Select a number from 0 to 2"
	} While (($Selection -lt 0) -Or ($Selection -gt 2))

	if ($Selection -Eq 0) {
		#User Choice
		Write-Output "Exiting"
		break
	}

	if ($Selection -Eq 1) {
		$SelectedProduct = (Get-ItemProperty $CASKey.pspath)
		$SelectedProductLocation = $AdlexProperties.CAS_userInstallRoot
	}
	
	if ($Selection -Eq 2) {
		$SelectedProduct = (Get-ItemProperty $ADSKey.pspath)
		$SelectedProductLocation = $AdlexProperties.ADS_userInstallRoot
	}
}
if ((-Not $CASInstalled) -And $ADSInstalled) {
	$SelectedProduct = (Get-ItemProperty $ADSKey.pspath)
	$SelectedProductLocation = $AdlexProperties.ADS_userInstallRoot
}
if ($CASInstalled -And (-Not $ADSInstalled)) {
	$SelectedProduct = (Get-ItemProperty $CASKey.pspath)
	$SelectedProductLocation = $AdlexProperties.CAS_userInstallRoot
}


## Do we want to restore or Style?
do {
	Write-Output "This script can style your $($SelectedProduct.name) installation. Would you like to configure the styling or restore to your CAS's original state."
	Write-Output ""	
	Write-Output "  0) Exit without making any changes"
	Write-Output "  1) Configure and Install Style changes"
	Write-Output "  2) Restore to original Styling"
	Write-Output ""
	$Selection = Read-Host -Prompt "Select a number from 0 to 2"
} While (($Selection -lt 0) -Or ($Selection -gt 2))

if ( $Selection -eq 0) { break }
if ( $Selection -eq 2) {
	# It's time to do the clean up
	Set-Location "$SelectedProductLocation/wwwroot/style/sass"
	Copy-Item "$(Get-Location)\corestyle.css.bkp" "$(Get-Location)\corestyle.css"

  Copy-Item "$(Get-Location)\coredmi.css.bkp" "$(Get-Location)\coredmi.css"

	Set-Location "component"
	Copy-Item "$(Get-Location)\WestCoastMenu.css.bkp" "$(Get-Location)\WestCoastMenu.css"

	Copy-Item "$(Get-Location)\EastCoastMenu.css.bkp" "$(Get-Location)\EastCoastMenu.css"

	Set-Location "$SelectedProductLocation/wwwroot/script"
	Copy-Item "$(Get-Location)\login.js.bkp" "$(Get-Location)\login.js"

	Set-Location "bundle"
	if (Test-Path "$(get-location)\bundle_Core.js.bkp") {
		Copy-Item "$(Get-Location)\bundle_Core.js.bkp" "$(Get-Location)\bundle_Core.js"
	} else {
		# we've lost the back up, but we can just remove this file to force a re-bundle
		remove-item .\bundle_Core.js
	}

	Write-Output "Restored Styling from backups"
	break
}

# If we're here then user chose 1 and we are configuring the styles


## Ask for user input on the styling choices
Write-Output "This script will modify the configuration for the $($SelectedProduct.Name), installed in $SelectedProductLocation"

$LongMenuTitle = Read-Host "Enter the long version of the title to be displayed in the menu bar. ($LongTitleBarDefault)"
if ( $LongMenuTitle -eq "" ) { 
	$LongMenuTitleSanitised = $LongTitleBarDefault
	Write-Output "	Using default: $LongMenuTitleSanitised"
} else {
	$LongMenuTitleSanitised = $LongMenuTitle -Replace "[^a-zA-Z0-9 ]", ""
	Write-Output "	Sanitised output: $LongMenuTitleSanitised"
}
Write-Output ""

# What strings do they want?
$ShortMenuTitle = Read-Host "Enter the short version of the title to be displayed in the menu bar. ($ShortTitleBarDefault)"
if ( $ShortMenuTitle -eq "" ) {
	$ShortMenuTitleSanitised = $ShortTitleBarDefault 
	Write-Output "	Using default: $ShortMenuTitleSanitised"
} else {
	$ShortMenuTitleSanitised = $ShortMenuTitle -Replace "[^a-zA-Z0-9 ]", ""
	Write-Output "	Sanitised output: $ShortMenuTitleSanitised"
}
Write-Output ""

$SecurityMarking = Read-Host "Enter the security classification marking to be displayed in the header and footer. ($SecurityClassificationDefault)"
if ( $SecurityMarking -eq "" ) { 
	$SecurityMarkingSanitised = $SecurityClassificationDefault 
	Write-Output "	Using default: $SecurityMarkingSanitised"
} else {
	$SecurityMarkingSanitised = $SecurityMarking -Replace "[^a-zA-Z0-9\[\]\- ]", ""
	Write-Output "	Sanitised output: $SecurityMarkingSanitised"
}
Write-Output ""

# What color do they want the UI?
Write-Output "Prompting for UI colour"
Add-Type -AssemblyName System.Windows.Forms
$uiColorDialog = new-object System.Windows.Forms.ColorDialog
$uiColorDialog.AllowFullOpen = $true
$uiColorDialog.FullOpen = $True

# Set default colors of the picker to be the default colors of the environments
$DefaultMenuColor = [System.Drawing.ColorTranslator]::ToOle([System.Drawing.ColorTranslator]::FromHtml('#494949'))
$Colour1 = [System.Drawing.ColorTranslator]::ToOle([System.Drawing.ColorTranslator]::FromHtml('#3e54da'))
$Colour2 = [System.Drawing.ColorTranslator]::ToOle([System.Drawing.ColorTranslator]::FromHtml('#309432'))
$Colour3 = [System.Drawing.ColorTranslator]::ToOle([System.Drawing.ColorTranslator]::FromHtml('#df8722'))
$Colour4 = [System.Drawing.ColorTranslator]::ToOle([System.Drawing.ColorTranslator]::FromHtml('#fa8072'))
$Colour5 = [System.Drawing.ColorTranslator]::ToOle([System.Drawing.ColorTranslator]::FromHtml('#b624f9'))

$uiColorDialog.CustomColors = @($DefaultMenuColor, $Colour1, $Colour2, $Colour3, $Colour4, $Colour5)
$uiColorResult = $uiColorDialog.ShowDialog()
$uiColorResult = [System.Drawing.ColorTranslator]::ToHtml($uiColorDialog.Color)

$oColourShader = "255,255,255"
$ColourShader = "0,0,0"

## Change corestyle.css
$customCoreStyles = "
/* ================================================================================================================== */
/* Customisation required classification markings on every page */

#footer:before, .reportTitleBar:after
{
  content: '$SecurityMarkingSanitised';
  display: block;
  color: rgb(192,0,0);
  font-family: 'roboto-medium', Arial, 'Arial Unicode MS', Helvetica, sans-serif;
  font-size: 13px;
  position: absolute;
  left: 50%;
  margin-left: -80px;
  margin-top: -5px;
}

.darkMode #footer:before, #darkMode .reportTitleBar:after, 
.darkMode.v-fullscreen .dmi-report-header:after
{
  color: ##fa0000;
}
 
#footer:before
{
  padding-bottom: 13px;
}

.v-fullscreen .dmi-report-header:after {
    line-height: 20px;
    height: 20px;
    content: '$SecurityMarkingSanitised';
    display: block;
    color: rgb(192,0,0);
    font-family: 'roboto-medium', Arial, 'Arial Unicode MS', Helvetica, sans-serif;
    font-size: 13px;
    position: relative;
    width: 100%;
    left: 50%;
    margin-left: -80px;
    margin-top: 5px;
}

/* ==================================================================================================== */
/* custom Header text

/* normally */
#custom-navlogo > #custom-shorttext
{
  display: none;
}
#custom-navlogo > #custom-fulltext
{
  display: inherit;
}

/* for small screens */
@media (max-width: 1300px) {
  #custom-navlogo > #custom-fulltext
  {
    display: none;
  }
  #custom-navlogo > #custom-shorttext
  {
    display: inherit;
  }
}

/* super small screens */
@media (max-width: 730px) {
  #custom-navlogo > #custom-shorttext
  {
    padding-left: 20vw;
  }
}

/* ================================================================================================================== */
/* custom Recolor for DCRUM UI */

#cp-menuBar-list_ID,
.cp-menuBar-item:hover:not(.b-nohover):not(.b-disabled):not(#custom-navlogo),
.cp-rmenu-root-menuIcon-selected, .cp-rmenu-root-menuIcon-selected:hover, 
.cp-rmenu-root-menuIcon-selected:focus, .cp-rmenu-root-menuIcon-selected:active,
.loginWrapper:before, .noc-header
{ /* Change only me */
  background-color: $uiColorResult !important
}

#cp-menuBar-list_ID, .loginWrapper:before, .noc-header
{
  box-shadow: inset 0 0 0 99999px rgba(255,255,255,0.1);
}

.darkMode .noc-header 
{
  box-shadow: inset 0 0 0 99999px rgba(0,0,0,0.5);
}

.cp-menuBar-item:hover:not(.b-nohover):not(.b-disabled):not(#custom-navlogo)
{
  box-shadow: inset 0 0 0 99999px rgba(0,0,0,0);
}

#custom-navlogo:hover {
    background-color: rgba(0,0,0,0);
}

.cp-rmenu-root-menuIcon-selected, .cp-rmenu-root-menuIcon-selected:hover, 
.cp-rmenu-root-menuIcon-selected:focus, .cp-rmenu-root-menuIcon-selected:active
{
  box-shadow: inset 0 0 0 99999px rgba(0,0,0,0.03);
}

.v-fullscreen.darkMode button:hover, 
.v-fullscreen.darkMode .cssButton:hover,
.buttonBar-item:hover,
.buttonBar .buttonBar-item-icon:hover,
.buttonBar-item.selected,
.v-fullscreen .cssButton
{
  border-color: whitesmoke !important;
}

.buttonBar-item.selected + .buttonBar-item
{
  border-left-color: whitesmoke !important;
}

.buttonBar .buttonBar-item,
.v-fullscreen.darkMode .noc-header 
{
  color: !important lightgray;
}

.v-fullscreen button:focus 
{
  box-shadow: initial;
}

.v-fullscreen .buttonBar .buttonBar-item-icon.selected, 
[class^='c-icon-svg-'], 
[class*=' c-icon-svg-'],
.cssButton.mixedButton,
.cssButton.mixedButton:hover,
.buttonBar .buttonBar-item-icon.selected,
.buttonBar .buttonBar-item-icon:hover,
[class^='c-icon-svg-']:not(span):focus, 
[class*=' c-icon-svg-']:not(span):focus
{
  color: whitesmoke !important;
}

.noc-header, 
.v-fullscreen.darkMode .noc-header 
{
  color: whitesmoke !important;
  font-family: 'bernina-regular', Arial, 'Arial Unicode MS', Helvetica, sans-serif !important;
}
"

Set-Location $SelectedProductLocation
Set-Location "wwwroot\style\sass"

# Make a backup if there isn't already one.
if (Test-Path "$(Get-Location)\corestyle.css.bkp") {
	Write-Output "Found previous corestyle.css.bkp file. Restoring from it to prevent stacked changes."
	Copy-Item "$(Get-Location)\corestyle.css.bkp" "$(Get-Location)\corestyle.css"
} else {
    Copy-Item "$(Get-Location)\corestyle.css" "$(Get-Location)\corestyle.css.bkp"
    Write-Output "Copied original corestyle.css to corestyle.css.bkp as a backup."
}

# load the file
$CASCoreStylesCSS = [IO.file]::ReadAllText( "$(Get-Location)\corestyle.css")

#Add the styling changes to the original file
$CASCoreStylesCSS += $customCoreStyles

# Output the new file with all the changes
$CASCoreStylesCSS | Out-file -encoding ASCII "$(Get-Location)\corestyle.css"
Write-Output "Copied style additions to $(Get-Location)\corestyle.css"


## Change WestCoastMenu.css
$customWestCoastMenu = "

/* ========================================================================================================================== */
/* custom Edit */

.cp-lmenu-header, .cp-lmenu-content, .cp-lmenu-leaf, .cp-lmenu-list-label, 
.cp-lmenu-header-user-link:hover, .cp-lmenu-list-wrap-level3:hover,
.cp-lmenu-header-collapsed .c-icon-svg-Menuclose:hover
{ /* match me to corestyle.css */
  background-color: $uiColorResult !important
}

.cp-lmenu-header, .cp-lmenu-content, .cp-lmenu-leaf, .cp-lmenu-list-label
{
  box-shadow: inset 0 0 0 99999px rgba($ColourShader,0.03);
}

.cp-lmenu-leaf-level2:hover, 
.cp-lmenu-leaf-level3:hover, 
.cp-lmenu-leaf-level4:hover,
.cp-lmenu-list-wrap-level3:hover,
.cp-lmenu-list-label-level3:hover,
.cp-lmenu-list-wrap-level3.cp-lmenu-list-wrap-expanded .cp-lmenu-list-label-level3, 
.cp-lmenu-header-user-link:hover,
.cp-lmenu-header-collapsed .c-icon-svg-Menuclose:hover
{
  box-shadow: inset 0 0 0 99999px rgba($ColourShader,0.1);
}

.cp-lmenu-list-label-level2
{
  color: lightgray;
}

.cp-lmenu-list-label .c-icon-svg.c-icon-svg-Chevron, .cp-lmenu-list-label .c-icon-svg.c-icon-svg-Chevron:hover,
.cp-lmenu-list-label .c-icon-svg.c-icon-svg-Chevron:focus, .cp-lmenu-list-label .c-icon-svg.c-icon-svg-Chevron:active
{
  color: lightgray !important;
}

.cp-lmenu-list-wrap-level3.cp-lmenu-list-wrap-expanded {
    border-top: 2px solid darkslategray;
    border-bottom: 2px solid darkslategray;
}
"

Set-Location $SelectedProductLocation
Set-Location "wwwroot\style\sass\component"
$FileName = "WestCoastMenu.css"

# Make a backup if there isn't already one.
if (Test-Path "$(Get-Location)\$FileName.bkp") {
	Write-Output "Found previous $FileName.bkp file. Restoring from it to prevent stacked changes."
	Copy-Item "$(Get-Location)\$FileName.bkp" "$(Get-Location)\$FileName"
} else {
    Copy-Item "$(Get-Location)\$FileName" "$(Get-Location)\$FileName.bkp"
    Write-Output "Copied original $FileName to $FileName.bkp as a backup."
}

$CASWestCoastMenuCSS = [IO.file]::ReadAllText( "$(Get-Location)\$FileName")
#Add the styling changes to the original file
$CASWestCoastMenuCSS += $customWestCoastMenu

# Output the new file with all the changes
$CASWestCoastMenuCSS | Out-file -encoding ASCII "$(Get-Location)\$FileName"
Write-Output "Copied style additions to $(Get-Location)\$FileName"


# Edit the EastCoastMenu now
$FileName = "EastCoastMenu.css"

$customEastCoastMenu = "
/* ========================================================================================================================== */
/* custom Edit */

.cp-rmenu-header, .cp-rmenu-content, .cp-rmenu-leaf, .cp-rmenu-list-label, 
.cp-rmenu-header-user-link:hover, .cp-rmenu-list-wrap-level3:hover
{ /* Match me to corestyle.css */
  background-color: $uiColorResult !important
}

.cp-rmenu-header, .cp-rmenu-content, .cp-rmenu-leaf, .cp-rmenu-list-label
{
  box-shadow: inset 0 0 0 99999px rgba($ColourShader,0.03);
}

.cp-rmenu-leaf-level2:hover, 
.cp-rmenu-leaf-level3:hover, 
.cp-rmenu-leaf-level4:hover,
.cp-rmenu-list-wrap-level3:hover,
.cp-rmenu-list-label-level3:hover,
.cp-rmenu-list-wrap-level3.cp-rmenu-list-wrap-expanded .cp-rmenu-list-label-level3, 
.cp-rmenu-header-user-link:hover 
{
  box-shadow: inset 0 0 0 99999px rgba($ColourShader,0.1);
}

.cp-rmenu-list-label-level2
{
  color: lightgray;
}

.cp-rmenu-list-label .c-icon-svg.c-icon-svg-Chevron, .cp-rmenu-list-label .c-icon-svg.c-icon-svg-Chevron:hover,
.cp-rmenu-list-label .c-icon-svg.c-icon-svg-Chevron:focus, .cp-rmenu-list-label .c-icon-svg.c-icon-svg-Chevron:active
{
  color: lightgray !important;
}

.cp-rmenu-list-wrap-level3.cp-rmenu-list-wrap-expanded {
    border-top: 2px solid darkslategray;
    border-bottom: 2px solid darkslategray;
}
"

# Make a backup if there isn't already one.
if (Test-Path "$(Get-Location)\$FileName.bkp") {
	Write-Output "Found previous $FileName.bkp file. Restoring from it to prevent stacked changes."
	Copy-Item "$(Get-Location)\$FileName.bkp" "$(Get-Location)\$FileName"
} else {
    Copy-Item "$(Get-Location)\$FileName" "$(Get-Location)\$FileName.bkp"
    Write-Output "Copied original $FileName to $FileName.bkp as a backup."
}

$CASEastCoastMenuCSS = [IO.file]::ReadAllText( "$(Get-Location)\$FileName")
#Add the styling changes to the original file
$CASEastCoastMenuCSS += $customEastCoastMenu

# Output the new file with all the changes
$CASEastCoastMenuCSS | Out-file -encoding ASCII "$(Get-Location)\$FileName"
Write-Output "Copied style additions to $(Get-Location)\$FileName"


## Change Login.js (and bundle.js)
$customLoginJS = "

/* ==================================================================================================== */
// custom Customization

makeHeader = function () {
	console.log('Applying custom Style customisations')
	var custom_nav = document.getElementById('cp-menuBar-list_ID');
	var custom_e = document.createElement('li');
	custom_e.style.cssText = 'line-height: 44px; font-size: 24px; position: absolute; left:50%; transform: translateX(-50%);';
	custom_e.id = 'custom-navlogo';
	custom_e.className = 'cp-menuBar-item cp-menuBar-item-level1 b-align-center';
	custom_e.innerHTML = '<div id=\'custom-fulltext\'>$LongMenuTitleSanitised</div><div id=\'custom-shorttext\'>$ShortMenuTitleSanitised</div>';
	custom_nav.appendChild(custom_e);
};

if ( typeof jQuery !== 'undefined' && jQuery ) {
  jQuery(document).ready(makeHeader);
}

"

Set-Location $SelectedProductLocation
Set-Location "wwwroot\script"
$FileName = "login.js"

# Make a backup if there isn't already one.
if (Test-Path "$(Get-Location)\$FileName.bkp") {
    Write-Output "Found previous $FileName.bkp file. Restoring from it to prevent stacked changes."
    Copy-Item "$(Get-Location)\$FileName.bkp" "$(Get-Location)\$FileName"
} else {
    Copy-Item "$(Get-Location)\$FileName" "$(Get-Location)\$FileName.bkp"
    Write-Output "Copied original $FileName to $FileName.bkp as a backup."
}

$CASLoginJS = [IO.file]::ReadAllText( "$(Get-Location)\$FileName")
#Add the styling changes to the original file
$CASLoginJS += $customLoginJS

# Output the new file with all the changes
$CASLoginJS | Out-file -encoding ASCII "$(Get-Location)\$FileName"
Write-Output "Copied style additions to $(Get-Location)\$FileName"

Set-Location "bundle"
$FileName = "bundle_Core.js"

# Make a backup if there isn't already one.
if (Test-Path "$(Get-Location)\$FileName.bkp") {
    Write-Output "Found previous $FileName.bkp file. Restoring from it to prevent stacked changes."
    Copy-Item "$(Get-Location)\$FileName.bkp" "$(Get-Location)\$FileName"
    
    $CASBundleCoreJS = [IO.file]::ReadAllText( "$(Get-Location)\$FileName")
    #Add the styling changes to the original file
    $CASBundleCoreJS += $customLoginJS

    # Output the new file with all the changes
    $CASBundleCoreJS | Out-file -encoding ASCII "$(Get-Location)\$FileName"
} else {
    Write-Output "bundle_Core.js.bkp not found. The CAS has not been logged into since it's last restart"
    remove-item -Force "$(Get-Location)\$FileName" # Kill the file just incase it's there
    Write-Output "Login to the case to build missing files"
}

Write-Output "
Copied script additions to $(Get-Location)\$FileName
"

# return to our starting location
Set-Location $PWD