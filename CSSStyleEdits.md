# CSS & RUM Console Style customisations

These changes need to be made to the large security.web_{version}.jar in the plugins directory of the CSS installation.

### Default Colours
- #3e54da
- #309432
- #df8722
- #fa8072
- #b624f9


## Login Screen

`\resources\css\login.css`

```css
/*************************************************************************************/
/* Custom style for login Navbar */

.langbar {
    background-color: #309432;
    box-shadow: inset 0 0 0 99999px rgba(0,0,0,0.2);
}

.lang.menu-right {
    display: none;
}
```

## Navbar

`\resources\css\core.css`

```css
div.page > div.page-menu,
.ace-cablebox .main-menu .wijmo-wijmenu,
.wijmo-wijmenu .ui-state-hover,
.wijmo-wijmenu .ui-state-hover:hover,
.ace-cablebox .ui-widget-header .ui-state-hover, 
.ace-cablebox .ui-state-focus, 
.ace-cablebox .ui-widget-header .ui-state-focus,
.ace-cablebox .ui-state-active,
.ace-cablebox .main-menu .wijmo-wijmenu .wijmo-wijmenu-parent .wijmo-wijmenu-child,
.ace-cablebox .main-menu .wijmo-wijmenu-child li.wijmo-wijmenu-item:hover, 
.ace-cablebox .main-menu .wijmo-wijmenu-child li.wijmo-wijmenu-item:hover > a 
{
    background-color: #309432 !important;
    box-shadow: inset 0 0 0 99999px rgba(0,0,0,0.2) !important;
    border: none  !important;
}
```