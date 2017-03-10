# AppMon Webdashboard style changes

This document outlines which files need what alterations to fit APMRS requirements.
Currently this is only adding a Security Clearance Notification above and below web dashboards.

`plugins\com.dynatrace.diagnostics.webui-6.5.1.20160908-143001\webroot\static\css\bootstrap-datetimepicker-2.3.10.min`

```css
main:before {
    content: 'Security Classification Marking';
    left: 50%;
    margin-top: 3px;
    color:  red;
    position: absolute;
    transform: translateX(-50%);
}

main:after {
    content: 'Security Classification Marking';
    left: 50%;
    bottom: 10px;
    color: red;
    position: absolute;
    transform: translateX(-50%);
    z-index: 5000;
}

body > div.NVLTOYC-d-c.NVLTOYC-b-a > div.NVLTOYC-qb-a > div > main > div 
{
    top: 24px !important;
}
```