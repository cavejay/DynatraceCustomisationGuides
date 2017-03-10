# DCRUM CSS tweaks for coloured UI

This file outlines the files and code necessary to add colour the the DCRUM UI.
Simply copy the code from here into the files and refresh your browser window to see the changes.

## CAS and ADS

`wwwroot/style/sass/corestyle.css`

```css
/* ================================================================================================================== */
/* Recolor for DCRUM UI */

#cp-menuBar-list_ID,
.cp-menuBar-item:hover:not(.b-nohover):not(.b-disabled):not(#custom-navlogo),
.cp-rmenu-root-menuIcon-selected, .cp-rmenu-root-menuIcon-selected:hover, 
.cp-rmenu-root-menuIcon-selected:focus, .cp-rmenu-root-menuIcon-selected:active,
.loginWrapper:before, .noc-header
{ /* Change only me */
  background-color: #0080C0 !important
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

```

`wwwroot/style/sass/components/WestCoastMenu.css`

```css
/* ========================================================================================================================== */
/* Edit */

.cp-lmenu-header, .cp-lmenu-content, .cp-lmenu-leaf, .cp-lmenu-list-label, 
.cp-lmenu-header-user-link:hover, .cp-lmenu-list-wrap-level3:hover,
.cp-lmenu-header-collapsed .c-icon-svg-Menuclose:hover
{ /* match me to corestyle.css */
  background-color: #309432 !important
}

.cp-lmenu-header, .cp-lmenu-content, .cp-lmenu-leaf, .cp-lmenu-list-label
{
  box-shadow: inset 0 0 0 99999px rgba(0,0,0,0.1);
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
  box-shadow: inset 0 0 0 99999px rgba(0,0,0,0.2);
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
```

`wwwroot/style/sass/components/EastCoastMenu.css`

```css
/* ========================================================================================================================== */
/* Edit */

.cp-rmenu-header, .cp-rmenu-content, .cp-rmenu-leaf, .cp-rmenu-list-label, 
.cp-rmenu-header-user-link:hover, .cp-rmenu-list-wrap-level3:hover
{ /* Match me to corestyle.css */
  background-color: #309432 !important
}

.cp-rmenu-header, .cp-rmenu-content, .cp-rmenu-leaf, .cp-rmenu-list-label
{
  box-shadow: inset 0 0 0 99999px rgba(0,0,0,0.1);
}

.cp-rmenu-leaf-level2:hover, 
.cp-rmenu-leaf-level3:hover, 
.cp-rmenu-leaf-level4:hover,
.cp-rmenu-list-wrap-level3:hover,
.cp-rmenu-list-label-level3:hover,
.cp-rmenu-list-wrap-level3.cp-rmenu-list-wrap-expanded .cp-rmenu-list-label-level3, 
.cp-rmenu-header-user-link:hover 
{
  box-shadow: inset 0 0 0 99999px rgba(0,0,0,0.2);
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
```

## RUM Console
