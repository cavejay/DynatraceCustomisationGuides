# DCRUM Customisation Guide

Sometimes it's necessary to customise the UI of your DCRUM deployment. I've been doing this for one of the deployments I currently work with and the following outlines the changes I've made.
Colour changes are outlined in DCRUMColours.md, with this document focused on other changes to the UI.

## Classification Markings

`wwwroot/style/sass/corestyle.css`

```css
/* ================================================================================================================== */
/* Custom classification markings on every page */

#footer:before, .reportTitleBar:after
{
  content: 'Security Classification Marking'; /* This is the classification text in the header */
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
    content: 'Security Classification Marking';  /* This is the classificiation text in the footer */
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
```

## Login Screen

`wwwroot/style/sass/corestyle.css`

```css 
/* ==================================================================================================== */
/* Custom login screen */

li.cp-menuBar-item.level_1 {
  display: none;
}

body.loginForm #cp-menu_ID #cp-menuBar_ID:before {
    content: '';
    line-height: 44px;
    font-size: 24px;
    position: fixed;
    top: 0;
    z-index: 5002;
    min-width: 620px;
    left: 50%;
    transform: translateX(-50%);
}

/* for small screens */
@media (max-width: 720px) {
  #cp-menuBar_ID:before {
    content: 'Your Short Text';
    min-width: 79px;
  }
}

.loginLogo, .productName {
  display: none !important;
}

.splashScreen {
  border-radius: 0 0 3px 3px !important;
}

.loginWrapper:before {
    content: '';
    background: url("");
    background-size: contain;
    background-repeat: no-repeat;
    background-position: 60px;
    border-radius: 3px 3px 0 0;
    padding: 40px 40px 24px 40px;
    margin: auto;
    height: 120px;
    box-sizing: border-box;
    display: block;
    width: 360px;
    position: relative;
    font-size: 32px;
    font-family: 'bernina-regular', Arial, 'Arial Unicode MS', Helvetica, sans-serif;
}

.loginWrapper:after {
    content: 'For support, please contact x'; /* Use this small block to add some text under the login box */
    text-align: center;
    position: inherit;
    width: 100%;
    padding-top: 32px;
    color: #E3E4E3;
    font-family: 'bernina-regular', Arial, 'Arial Unicode MS', Helvetica, sans-serif;
    font-size: 16px;
    letter-spacing: 0.02em;
}

.loginForm#footer:before {
  display: none;
}

.splashScreen.reloadContainer:after {
    content: 'You\'re a star!'; /* Use this to add text inside the login box but below the fields */
    color: black;
}

```

## Title Bar Header

Adds 'This is where you\'d make a full length title' to the header of each page and 'Your Short Text' when the width is below a certain size.

`wwwroot\script\login.js` _this requires a restart of the cas to take affect_

```js
/* ==================================================================================================== */
// Customization

makeHeader = function () {
	console.log('Applying Style customisations')
	var custom_nav = document.getElementById('cp-menuBar-list_ID');
	var custom_e = document.createElement('li');
	custom_e.style.cssText = 'line-height: 44px; font-size: 24px; position: absolute; left:50%; transform: translateX(-50%);';
	custom_e.id = 'custom-navlogo';
	custom_e.className = 'cp-menuBar-item cp-menuBar-item-level1 b-align-center';
	custom_e.innerHTML = '<div id=\'custom-fulltext\'>This is where you\'d make a full length title</div><div id=\'custom-shorttext\'>Your Short Text</div>';
	custom_nav.appendChild(custom_e);
};

if ( typeof jQuery !== 'undefined' && jQuery ) {
  jQuery(document).ready(makeHeader);
}

```

`wwwroot/style/sass/corestyle.css`

```css
/* ==================================================================================================== */
/* Custom Header text */

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
```

## Custom image in the LHS menu
`wwwroot/style/sass/component/WestCoastMenu.css`

```css
/* ======================================================================================= */
/* Replace Dynatrace logo in the LHS menu with an alternate image */

.cp-lmenu-header-logo { /* This image must be converted to base64 for compatability with IE8 */
    background: transparent no-repeat scroll left center url(""); /* Your image's url would go inside the brackets */
    background-size: contain;
}
```


## Full Screen Dashboard Styling

`wwwroot/style/sass/corestyle.css`

```css
/* ======================================================================================= */
/* Fullscreen DMI Report Edits */

.v-fullscreen #footer:after {
    content: '';
    height: 38px;
    width: 30%;
    position: absolute;
    right: 34px;
    margin-top: -20px;
    padding-top: 10px;
    background: transparent no-repeat scroll right center url(../../img/svg/dcrum_logo_mid_RGB_CPH_2898x340.svg);
    background-size: 30%;
}

.v-fullscreen.darkMode #footer:after {
      background-image: url(../../img/svg/dcrum_logo_mid_RGB_CNH_2898x340.svg);
}
```

`wwwroot/style/sass/coredmi.css`

```css
/* ======================================================================================= */
/* Fullscreen DMI Report Edits */

@media only screen and (max-width: 1366px)
.noc-header-logo, .v-fullscreen.darkMode .noc-header-logo {
    background-image: initial;
}
```

