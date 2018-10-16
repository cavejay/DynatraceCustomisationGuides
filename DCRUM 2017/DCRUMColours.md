# DCRUM CSS tweaks for coloured UI

This file outlines the files and code necessary to add colour the the DCRUM UI.
Simply copy the code from here into the files and refresh your browser window to see the changes.

### Default Colours
- #494949
- #3e54da
- #309432
- #df8722
- #fa8072
- #b624f9

## CAS and ADS

`wwwroot/style/sass/corestyle.css`

```css
/* ================================================================================================================== */
/* Recolor for DCRUM UI */

#cp-menuBar-list_ID,
.cp-menuBar-item:hover:not(.b-nohover):not(.b-disabled):not(#custom-navlogo),
.cp-rmenu-root-menuIcon-selected, .cp-rmenu-root-menuIcon-selected:hover, 
.cp-rmenu-root-menuIcon-selected:focus, .cp-rmenu-root-menuIcon-selected:active,
.loginWrapper:before
{ /* Change only me */
  background-color: #df8722 !important
}

#cp-menuBar-list_ID, .loginWrapper:before
{
  box-shadow: inset 0 0 0 99999px rgba(255,255,255,0.1);
}
```