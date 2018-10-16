# DCRUM Customisation Guide

Sometimes it's necessary to customise the UI of your DCRUM deployment. I've been doing this for one of the deployments I currently work with and the following outlines the changes I've made.
Colour changes are outlined in DCRUMColours.md, with this document focused on other changes to the UI.

## Classification Markings

`wwwroot/style/sass/corestyle.css`

```css
/* ================================================================================================================== */
/* Custom classification markings on every page */

#footer:before,
.reportTitleBar:after {
  content: "Security Classification Marking"; /* This is the classification text in the header */
  display: block;
  color: rgb(192, 0, 0);
  font-family: "roboto-medium", Arial, "Arial Unicode MS", Helvetica, sans-serif;
  font-size: 13px;
  position: absolute;
  left: 50%;
  margin-left: -80px;
  margin-top: -5px;
}

.darkMode #footer:before,
#darkMode .reportTitleBar:after,
.darkMode.v-fullscreen .dmi-report-header:after {
  color: ##fa0000;
}

#footer:before {
  padding-bottom: 13px;
}

.v-fullscreen .dmi-report-header:after {
  line-height: 20px;
  height: 20px;
  content: "Security Classification Marking"; /* This is the classificiation text in the footer */
  display: block;
  color: rgb(192, 0, 0);
  font-family: "roboto-medium", Arial, "Arial Unicode MS", Helvetica, sans-serif;
  font-size: 13px;
  position: relative;
  width: 100%;
  left: 50%;
  margin-left: -80px;
  margin-top: 5px;
}
```

## Login Screen

Simplified. Will elaborate at some point
