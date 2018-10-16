<#
.SYNOPSIS
	Use Powershell Remoting to access a remote server and update the styling of the CAS.

.DESCRIPTION
	//todo please explain how this works

	This script is based on work done by Luke Boyling
	Assumption: that the Adlex registry key has not changed and is the most reliable way to get the install folder across versions.

.EXAMPLE
	.\DCRUMConfig.ps1 -targetMachine x.x.x.x -cred $(get-credential)

.NOTES
	Author: Michael Ball
	Contact: michael.ball@dynatrace.com
	version: 181016
#>

[cmdletbinding()]
PARAM (
  [Parameter(Mandatory)][String]$targetMachine,
  [Parameter(Mandatory)][PScredential]$credential,
  [Switch]$SecurityOnly,
  [String]$LongTitleBarDefault = "Normal Length Header Text" ,
  [String]$ShortTitleBarDefault = "Short Stuff",
  [String]$SecurityClassificationDefault = "Security Classification Marking",
  [String]$customHelpLink = "https://community.dynatrace.com/community/display/PUBDCRUM/DC+RUM+Home",
  [String]$customHelpText = "Contact us!"
)

# Create the session
$session = New-PSSession $targetMachine -Credential $credential -ErrorAction stop

$remoteScriptBlock = {
  # Check that this user is an admin?
  ## Check we're admin
  $RunningAsAdmin = ( [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
  if (-Not $RunningAsAdmin ) {
    return 0
  }

  # Check registry to determine install of CAS
  $AdlexRegistry = "HKLM:\Software\Adlex"
  if (-not (Test-Path -Path $AdlexRegistry -PathType Container)) {
    #Key does not exist
    return 1
  }
  $AdlexProperties = Get-ItemProperty -Path $AdlexRegistry
  if (-not $AdlexProperties) {
    #Key has no values
    return 1
  }

  $CASInstalled = $null -ne (Get-Member -InputObject $AdlexProperties -Name "CAS_userInstallRoot" -ErrorAction SilentlyContinue)
  $ADSInstalled = $null -ne (Get-Member -InputObject $AdlexProperties -Name "ADS_userInstallRoot" -ErrorAction SilentlyContinue)

  if (-Not $CASInstalled -And -Not $ADSInstalled) {
    return 2
  }

  $CASKey = Get-ChildItem "HKLM:\Software\Adlex\Watchdog" | Where-Object {$(Get-ItemProperty $_.pspath -ErrorAction SilentlyContinue).pschildname.EndsWith("Central Analysis Server")}
  $ADSKey = Get-ChildItem "HKLM:\Software\Adlex\Watchdog" | Where-Object {$(Get-ItemProperty $_.pspath -ErrorAction SilentlyContinue).pschildname.EndsWith("Advanced Diagnostics Server")}

  $output = @{
    "CAS" = @{
      "installed"             = $CASInstalled;
      "installationDirectory" = $AdlexProperties.CAS_userInstallRoot;
      "name"                  = if ($CASKey) {$(Get-ItemProperty $CASKey.pspath).pschildname} else {$false}
      "entry"                 = $CASKey
    };
    "ADS" = @{
      "installed"             = $ADSInstalled;
      "installationDirectory" = $AdlexProperties.ADS_userInstallRoot;
      "name"                  = if ($ADSKey) {$(Get-ItemProperty $ADSKey.pspath).pschildname} else {$false}
      "entry"                 = $ADSKey
    }
  }

  return ConvertTo-Json $output -Depth 3
}

write-host "Connecting to $targetMachine and running remote code"
$invokeResult_ = Invoke-Command -Session $session -ScriptBlock $remoteScriptBlock
write-host "Ran Remote Code"

# handle any errors that may have come up
if (([String]$invokeResult_).length -le 1) {
  switch ($invokeResult_) {
    0 { Write-Output "Changes to DCRUM configuration files require admin privileges. Please run this script as an administrator." ; break}
    1 { Write-Output "Unable to detect any registered DCRUM components" ; break}
    2 { Write-Output "There is not a CAS installed on this machine. This script will not be able to install the RESTfulDC Helper" ; break}
    Default { Write-Output "Something went wrong in the remote session, return code was: '$invokeResult_'"}
  }
}

# convert the result from json to psobject
$envInfo = ConvertFrom-Json $invokeResult_

## Determine which product should be styled
$SelectedProductName
if ($envInfo.CAS.installed -And $envInfo.ADS.installed) {
  do {
    Write-Output "Multiple DCRUM components have been detected on this system. Please select one of the following:"
    Write-Output ""
    Write-Output "  0) Exit without making any changes"
    Write-Output "  1) $($envInfo.CAS.Name)"
    Write-Output "  2) $($envInfo.ADS.Name)"
    Write-Output ""
    $Selection = Read-Host -Prompt "Select a number from 0 to 2"
  } While (($Selection -lt 0) -Or ($Selection -gt 2))

  if ($Selection -Eq 0) {
    #User Choice
    Write-Output "Exiting"
    break
  }

  if ($Selection -Eq 1) {
    $SelectedProductName = 'CAS'
    $SelectedProductLocation = $envInfo.CAS.installationDirectory
  }

  if ($Selection -Eq 2) {
    $SelectedProductName = 'ADS'
    $SelectedProductLocation = $envInfo.ADS.installationDirectory
  }
}
if ((-Not $envInfo.CAS.installed) -And $envInfo.ADS.installed) {
  $SelectedProductName = 'ADS'
  $SelectedProductLocation = $envInfo.ADS.installationDirectory
}
if ($envInfo.CAS.installed -And (-Not $envInfo.ADS.installed)) {
  $SelectedProductName = 'CAS'
  $SelectedProductLocation = $envInfo.CAS.installationDirectory
}

# Create a selected Product object
$selectedProduct = if ($selectedProductName -eq 'CAS') {
  $envInfo.CAS
}
else {
  $envInfo.ADS 
}

## Do we want to restore or Style?
do {
  Write-Output "This script can style your $($selectedProduct.Name) installation. Would you like to configure the styling or restore to your CAS's original state."
  Write-Output ""
  Write-Output "  0) Exit without making any changes"
  Write-Output "  1) Configure and Install Style changes"
  Write-Output "  2) Restore to original Styling"
  Write-Output ""
  $Selection = Read-Host -Prompt "Select a number from 0 to 2"
} While (($Selection -lt 0) -Or ($Selection -gt 2))

# Leaving
if ( $Selection -eq 0) { return }

# Restoring
if ( $Selection -eq 2) {
  $remoteScriptBlock = {
    Param($SelectedProductLocation)
    # It's time to do the clean up
    Push-Location "$SelectedProductLocation/wwwroot/style/sass"
    Copy-Item "$(Get-Location)\corestyle.css.bkp" "$(Get-Location)\corestyle.css"

    Set-Location "$SelectedProductLocation/wwwroot/script"
    Copy-Item "$(Get-Location)\login.js.bkp" "$(Get-Location)\login.js"

    Set-Location "bundle"
    if (Test-Path "$(get-location)\bundle_Core.js.bkp") {
      Copy-Item "$(Get-Location)\bundle_Core.js.bkp" "$(Get-Location)\bundle_Core.js"
    }
    else {
      # we've lost the back up, but we can just remove this file to force a re-bundle
      remove-item .\bundle_Core.js
    }

    Pop-Location
  }
  
  Write-Output "Restored Styling from backups"  
  $invokeResult_ = Invoke-Command -Session $session -ScriptBlock $remoteScriptBlock -ArgumentList $selectedProduct.installationDirectory

  write-host $invokeResult_

  break
}

# If we're here then user chose 1 and we are configuring the styles

## Ask for user input on the styling choices
Write-Output "This script will modify the configuration for the $($SelectedProduct.Name), installed in $($SelectedProduct.installationDirectory)"

$SecurityMarking = Read-Host "Enter the security classification marking to be displayed in the header and footer. ($SecurityClassificationDefault)"
if ( $SecurityMarking -eq "" ) {
  $SecurityMarkingSanitised = $SecurityClassificationDefault
  Write-Output "	Using default: $SecurityMarkingSanitised"
}
else {
  $SecurityMarkingSanitised = $SecurityMarking -Replace "[^a-zA-Z0-9\[\]\- ]", ""
  Write-Output "	Sanitised output: $SecurityMarkingSanitised"
}
Write-Output ""

$customisingColours = Read-Host "Do you wish to update the colour of the $($selectedProduct.Name) header? y/n :"
if ( $customisingColours -eq 'y') {
  # What color do they want the UI?
  Write-Output "Prompting for UI colour"
  Add-Type -AssemblyName System.Windows.Forms
  $uiColorDialog = new-object System.Windows.Forms.ColorDialog
  $uiColorDialog.AllowFullOpen = $true
  $uiColorDialog.FullOpen = $True
  
  # Set default colors of the picker to be the default colors of the environments
  $DefaultMenuColor = [System.Drawing.ColorTranslator]::ToOle([System.Drawing.ColorTranslator]::FromHtml('#191919'))
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
}
else {
  write-host "Input was '$customisingColours', so colours will not be updated" 
}
  
## Change corestyle.css
$customCoreSecurityHeader = "
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
"

$customCoreColourStyles = "
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
"
# if user said they didn't want colours, blank $customCoreColourStyles
if ($customisingColours -ne 'y') {
  $customCoreColourStyles = ""
}

## Change Login.js (and bundle.js)
$customLoginJS = "

/* ==================================================================================================== */
// custom Customization

function customizeLogin () {
	console.log('Applying custom Style customisations')
	document.getElementById('login_support').childNodes[1].href = `"$customHelpLink`"
  document.getElementById('login_support').childNodes[1].text = `"$customHelpText`"
  document.getElementById('login_langs').remove()
};

document.addEventListener('DOMContentLoaded', customizeLogin, false);

"

$remoteScriptBlock = {
  PARAM(
    [string]$SelectedProductLocation,
    [string]$SecurityMarkingCustomisation,
    [String]$coreColourCustomisation,
    [String]$loginJSAdditions
  )

  # Update the core CSS file
  Set-Location $SelectedProductLocation
  Set-Location "wwwroot\style\sass"
  
  # Make a backup if there isn't already one.
  if (Test-Path "$(Get-Location)\corestyle.css.bkp") {
    Write-Output "Found previous corestyle.css.bkp file. Restoring from it to prevent stacked changes."
    Copy-Item "$(Get-Location)\corestyle.css.bkp" "$(Get-Location)\corestyle.css"
  }
  else {
    Copy-Item "$(Get-Location)\corestyle.css" "$(Get-Location)\corestyle.css.bkp"
    Write-Output "Copied original corestyle.css to corestyle.css.bkp as a backup."
  }
  
  # load the file
  $CASCoreStylesCSS = [IO.file]::ReadAllText( "$(Get-Location)\corestyle.css" )
  
  #Add the styling changes to the original file
  $CASCoreStylesCSS += $coreColourCustomisation
  $CASCoreStylesCSS += $SecurityMarkingCustomisation
  
  # Output the new file with all the changes
  $CASCoreStylesCSS | Out-file -encoding ASCII "$(Get-Location)\corestyle.css"
  Write-Output "Copied style additions to $(Get-Location)\corestyle.css"
  
  # Update the login js
  Set-Location $SelectedProductLocation
  Set-Location "wwwroot\script"
  $FileName = "login.js"
  
  # Make a backup if there isn't already one.
  if (Test-Path "$(Get-Location)\$FileName.bkp") {
    Write-Output "Found previous $FileName.bkp file. Restoring from it to prevent stacked changes."
    Copy-Item "$(Get-Location)\$FileName.bkp" "$(Get-Location)\$FileName"
  }
  else {
    Copy-Item "$(Get-Location)\$FileName" "$(Get-Location)\$FileName.bkp"
    Write-Output "Copied original $FileName to $FileName.bkp as a backup."
  }
  
  $CASLoginJS = [IO.file]::ReadAllText( "$(Get-Location)\$FileName")
  #Add the styling changes to the original file
  $CASLoginJS += $loginJSAdditions
  
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
    $CASBundleCoreJS += $loginJSAdditions
    
    # Output the new file with all the changes
    $CASBundleCoreJS | Out-file -encoding ASCII "$(Get-Location)\$FileName"
  }
  else {
    Write-Output "bundle_Core.js.bkp not found. The CAS has not been logged into since it's last restart"
    remove-item -Force "$(Get-Location)\$FileName" # Kill the file just incase it's there
    Write-Output "Login to the case to build missing files"
  }
  Write-Host "`r`nCopied script additions to $(Get-Location)\$FileName"
}

$invokeResult_ = Invoke-Command -Session $session -ScriptBlock $remoteScriptBlock -ArgumentList $SelectedProduct.installationDirectory, $customCoreSecurityHeader, $customCoreColourStyles, $customLoginJS
Write-Host ($invokeResult_ -join "`r`n")

write-host "`r`nCustomisation Complete"