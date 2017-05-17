# CSS & RUM Console Style customisations

These changes need to be made to the large security.web_{version}.jar in the plugins directory of the CSS installation.

### Default Colours
- #3e54da // Blue
- #309432 // Green
- #df8722 // Orange
- #fa8072 // Salmon
- #b624f9 // Violet

## Login Screen

`\resources\css\login.css` (For the RUM C: `\unauthorized\css\login.css`)

```css
/*************************************************************************************/
/* Custom style for login Navbar */

.langbar {
    background-color: #309432;
    box-shadow: inset 0 0 0 99999px rgba(255,255,255,0.1);
}

.lang.menu-right {
    display: none;
}
```

## Navbar

`\resources\css\core.css` (For the RUM C: `\css\core.css`)

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
    box-shadow: inset 0 0 0 99999px rgba(255,255,255,0.1) !important;
    border: none  !important;
}

.wijmo-wijmenu .wijmo-wijmenu-item .wijmo-wijmenu-text:hover {
    color: #ffffff !important;
}

.wijmo-wijmenu .wijmo-wijmenu-item .wijmo-wijmenu-text {
	color: #e4e4e4 !important;
}
```