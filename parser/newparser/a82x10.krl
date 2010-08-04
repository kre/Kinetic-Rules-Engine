{
   "dispatch": [
      {"domain": "www.google.com"},
      {"domain": "search.yahoo.com"},
      {"domain": "www.bing.com"}
   ],
   "global": [
      {
         "content": "#spotlight-reminders-wrapper{    \theight:24px;    \tbackground:#e4effd;    \tpadding:0 0 0 9px;    \tmargin:15px 0;    \tfont-size:small;    }        .remindme-reminders-wrapper{    \theight:24px;    \tbackground:white;    \tpadding:0;    \tmargin:0;    \tfont-size:small;    \twidth:450px;    }        p.descriptive-text{    \tfloat:right;    \tmargin:4px 9px 0 0;    \tpadding:0;    \tcolor:#7a7a7a;    \tfont-size:small;    }        ul.spotlightReminders{    \tfloat:left;    \tmargin:0;    \tpadding:0;    \tlist-style:none;    \theight:24px;    }        ul.spotlightReminders li{    \tdisplay:block;    \tfloat:left !important;    \tmargin:3px 3px 0 0;    }        ul.spotlightReminders li.azigo-logo{    \tmargin:4px 0 0 0;    }        ul.spotlightReminders li.txt-reminder{    \tpadding:0 0 0 4px;    \tmargin:4px 3px 0 0;    \tcolor:#2b30d1;    }        .clear{    \tclear:both;    }               .remindme-flyout-wrapper{    \tborder: 3px solid #e471ac;    \twidth:450px;    \tmargin:0 0 0 20px;    \tposition: absolute;            background-color: white;    \tdisplay: none;    \tz-index: 1;    \ttext-align:left;    }        .flyout-pointer{    \tbackground:url(\"http://www.azigo.com/images/rm/FlyoutPoint.png\") no-repeat;    \theight:11px;    \twidth:15px;    \tposition:relative;    \tmargin:-11px 0 0 20px;    }        .flyout-reminder-details{    \tpadding:8px 10px;    \tborder-bottom:1px solid #c2c2c2;            color: black;    \tfloat: left;    }        p.flyout-reminder-url{    \tmargin:0 0 5px 0;    \tpadding:0;    }        .flyout-reminder-details ul{    \tmargin:0;    \tpadding:0;    \tlist-style:none;    \tline-height:14px;    }        .flyout-reminder-details ul li{    \tdisplay:block;    \tfloat:left !important;    \tmargin:0 4px 0 0;    \tpadding:0;    }        .flyout-reminder-details ul li.flyout-reminder-url{    \tmargin:0 0 5px 0;    \tpadding:0;    \twidth:250px;    }        .flyout-reminder-details ul li.flyout-reminder-text{    \twidth:230px;    }        .flyout-reminder-details ul li.flyout-reminder-button{    \tmargin:0;    }        a.flyout-reminder-button{    \tdisplay:block;    \tfont-size:10px;    \tfont-weight:bold;    \tfont-family:Verdana, sans-serif, Arial, Helvetica;    \tbackground:#57b6e3;    \ttext-align:center;    \ttext-decoration:none;    \theight:16px;    \twidth:96px;    \tcolor:#fff;    \tpadding:2px 0 0 0;    \tmargin:0;    }            .clearfix:after {        content: \".\";        display: block;        clear: both;        visibility: hidden;        line-height: 0;        height: 0;    }        .clearfix {        display: inline-block;    }        html[xmlns] .clearfix {        display: block;    }        * html .clearfix {        height: 1%;    }           .flyout-wrapper{    \tborder: 3px solid #e471ac;    \twidth:450px;    \tmargin:-15px 0 0 29px;    \tposition: absolute;            background-color: white;    \tdisplay: none;    \tz-index: 1;    }                .flyout-reminder-details{    \tpadding:8px 10px;    \tborder-bottom:1px solid #c2c2c2;    \tfont-size: small;            width:430px;    }    ",
         "type": "css"
      },
      {"emit": "\nvar globalData = {                                    \"Source\" : \"wwm\",    \t\t\t\t\"RemindMeIconUrl\" : \"http://www.azigo.com/images/card/wwm_24x18.png\",                                    \"FlyoutIconUrl\" : \"http://www.azigo.com/images/card/wwm_90x60.png\"    \t\t\t };        \tfunction remindMeSelector(obj) {                    var annotationContent;    \t\tvar remindMeDomain = obj.domain.replace(/http:\\/\\/([A-Za-z0-9.-]+)\\/.*/,\"$1\");            \tremindMeDomain = remindMeDomain.replace(\"http://\",\"\");    \t\tremindMeDomain = remindMeDomain.replace(\"www.\",\"\");    \t\tremindMeDomain = remindMeDomain.replace(\"www1.\",\"\");    \t\tremindMeDomain = remindMeDomain.replace(/\\./, \"\");    \t\tremindMeDomain = remindMeDomain.replace(/\\.[^.]+$/,\"\");                    remindMeDomain = remindMeDomain.replace(/[&]/g,\"and\");                    remindMeDomain = remindMeDomain.replace(/\\s+/g,\"\");    \t\tremindMeDomain = remindMeDomain.replace(/[']/g,\"\");    \t\tremindMeDomain = remindMeDomain.replace(/[-]/g,\"\");                    remindMeDomain = remindMeDomain.toLowerCase();                        var remindMeDivId = \"remindMe_\"+remindMeDomain;                    var remindMeFlyoutDivId = \"remindMeFlyout_\"+remindMeDomain;    \t\tvar remindMeWrapper = \"remindMeWrapper_\"+remindMeDomain;        \t\tif($K(\"#\"+remindMeDivId).length == 0) {     \t\t   var remindMeMainDiv = createRemindMeDiv(remindMeDivId);                        var remindMeFlyoutDiv = createRemindMeFlyoutDiv(remindMeFlyoutDivId);         \t\t   remindMeFlyoutDiv.append(    \t\t\tgetFlyoutDetails(                                                     obj.name,                                                     obj.link,                                                      globalData.FlyoutIconUrl,                                                      obj.text,                                                      obj.icon                                              )    \t\t   );         \t           var remindMeDiv = $K(\"<div><\/div>\");                           var wrapperDiv = $K(\"<div id='\"+remindMeWrapper+\"' class='remindme-reminders-wrapper'><\/div>\");    \t\t   wrapperDiv.append(remindMeMainDiv);        \t\t   remindMeDiv.append(wrapperDiv);        \t           remindMeDiv.append(remindMeFlyoutDiv);                           annotationContent = remindMeDiv;                       registerEvents(remindMeDivId, remindMeFlyoutDivId, false);                    }                    else {                        if($K(\"#\"+remindMeDivId).find(\"#img_\"+globalData.Source+\"_remindMe\").length) {                            return false;                       }        \t\t   if($K(\"#\"+remindMeDivId).children(\".txt-reminder\").length) {                          $K(\"#\"+remindMeDivId).children(\".txt-reminder\").after(                                                  makeListItem(    \t\t                                    null,     \t\t                                    null,     \t\t                                    $K(\"<img id='img_\"+globalData.Source+\"_remindMe' src='\"+globalData.RemindMeIconUrl+\"' />\")    \t\t                              )                          );                       }        \t\t   if($K(\"#\"+remindMeFlyoutDivId).length) {    \t\t\t$K(\"#\"+remindMeFlyoutDivId).append(    \t\t\t                   getFlyoutDetails(                                                                    obj.name,                                                                    obj.link,                                                                     globalData.FlyoutIconUrl,                                                                     obj.text,                                                                     obj.icon                                               )    \t\t        );      \t\t   }        \t\t     \t\t   var spanReminders = $K(\"#\"+remindMeDivId).children(\".txt-reminder\").children(\".spanRemindMeNReminders\");                       if (spanReminders.length > 0)                       {                           var totalReminders = parseInt(spanReminders.text());                           if (!isNaN(totalReminders))                           {    \t                    totalReminders = totalReminders + 1;                                spanReminders.text(String(totalReminders));    \t                    if(totalReminders == 1) {    \t\t               $K(\"#\"+remindMeDivId).children(\".txt-reminder\").children(\".spanRemindMeTextReminders\").text(\"Reminder\");    \t                    }    \t                    else {    \t\t               $K(\"#\"+remindMeDivId).children(\".txt-reminder\").children(\".spanRemindMeTextReminders\").text(\"Reminders\");    \t                    }                           }                    \t\t   }                       annotationContent = false;                    }    \t     return annotationContent;            }                function registerEvents(remindMeDivId, remindMeFlyoutDivId, isSpotlightEvent) {\t\t    \t     $K(\"#\"+remindMeDivId).live('mouseover', function () {    \t\t   $K('#'+remindMeDivId).css({'cursor':'hand','cursor':'pointer'});                       $K('#'+remindMeFlyoutDivId).show();    \t     });        \t     $K(\"#\"+remindMeDivId).live('mouseout', function () {                                              if(isSpotlightEvent) {                          $K(\"#spotlight-reminders-wrapper\").live('mouseover', function() {                               $K('#'+remindMeFlyoutDivId).show();                                                     });                          $K(\"#spotlight-reminders-wrapper\").live('mouseout', function() {                               $K('#'+remindMeFlyoutDivId).hide();       \t\t\t   $K(\"#spotlight-reminders-wrapper\").die('mouseover');    \t\t\t   $K(\"#spotlight-reminders-wrapper\").die('mouseout');                          });                       }    \t\t   else {    \t\t\t$K(\"#\"+remindMeDivId).parent().mouseover(function() {                               $K('#'+remindMeFlyoutDivId).show();        \t\t\t});                          $K(\"#\"+remindMeDivId).parent().mouseout(function() {                               $K('#'+remindMeFlyoutDivId).hide();       \t\t\t   $K(\"#\"+remindMeDivId).parent().unbind('mouseover');    \t\t\t   $K(\"#\"+remindMeDivId).parent().unbind('mouseout');                          });    \t\t   }        \t\t   $K('#'+remindMeFlyoutDivId).hide();    \t     });        \t     $K(\"#\"+remindMeFlyoutDivId).live('mouseover', function () {            \t   $K('#'+remindMeFlyoutDivId).show();    \t     });        \t     $K(\"#\"+remindMeFlyoutDivId).live('mouseout', function () {    \t\t   $K('#'+remindMeFlyoutDivId).hide();    \t\t   if(isSpotlightEvent) {    \t\t\t   $K(\"#spotlight-reminders-wrapper\").die('mouseover');    \t\t\t   $K(\"#spotlight-reminders-wrapper\").die('mouseout');    \t\t   }    \t\t   else {    \t\t\t   $K(\"#\"+remindMeDivId).parent().unbind('mouseover');    \t\t\t   $K(\"#\"+remindMeDivId).parent().unbind('mouseout');    \t\t   }                 });            }        \tfunction createRemindMeDiv(remindMeDivId) {                 var remindMeMainUl = $K(\"<ul><\/ul>\");                 remindMeMainUl.attr({\"id\":remindMeDivId, \"class\":\"spotlightReminders\"});                     remindMeMainUl.append(                      makeListItem(null, \"azigo-logo\", $K(\"<img src='http://www.azigo.com/images/rm/azigo_16x16.png' />\"))                 );                     remindMeMainUl.append(                      makeListItem(    \t\t     \"remindme-txt-reminder\",     \t\t     \"txt-reminder\",     \t\t     \"<span class='spanRemindMeNReminders'>1<\/span> <span class='spanRemindMeTextReminders'>Reminder<\/span>\"    \t\t  )                 );                     remindMeMainUl.append(                      makeListItem(    \t\t     null,     \t\t     null,     \t\t     $K(\"<img id='img_\"+globalData.Source+\"_remindMe' src='\"+globalData.RemindMeIconUrl+\"' />\")    \t\t  )                 );                     remindMeMainUl.append(                      makeListItem(null, null, $K(\"<img src='http://www.azigo.com/images/rm/FlyoutIndicator.png' />\"))                 );                     return remindMeMainUl;            }        \tfunction createRemindMeFlyoutDiv(remindMeFlyoutDivId)            {    \t    var remindMeFlyoutDiv = $K(\"<div><\/div>\");    \t    remindMeFlyoutDiv.attr({\"id\":remindMeFlyoutDivId, \"class\":\"remindme-flyout-wrapper\"});    \t    remindMeFlyoutDiv.append($K(\"<div><\/div>\").attr(\"class\", \"flyout-pointer\"));                return remindMeFlyoutDiv;            }        \tfunction makeListItem(listItemId, listItemClass, listItemContent) {                 var listItem = $K(\"<li><\/li>\");                 if(listItemClass != null) {                     listItem.attr(\"class\", listItemClass);                 }    \t     if(listItemId != null) {    \t         listItem.attr(\"id\", listItemId);    \t     }                 listItem.append(listItemContent);                 return listItem;                    }        \tfunction makeAnchorTag(aUrl, aClass, aText)            {                 var anchorTag = $K(\"<a><\/a>\");                 anchorTag.attr(\"href\", aUrl);                 if(aClass != null) {                     anchorTag.attr(\"class\", aClass);                 }                 anchorTag.append(aText);                 return anchorTag;            }                    function getFlyoutDetails(clientName, clientUrl, clientLogo, displayText, buttonType)        { \t             \tvar flyoutDetailsDiv = $K(\"<div><\/div>\");    \tflyoutDetailsDiv.attr(\"class\",\"flyout-reminder-details clearfix\");                var flyoutDetailsUl = $K(\"<ul><\/ul>\");                flyoutDetailsUl.append(    \t\tmakeListItem(null, null, $K(\"<img src='\"+clientLogo+\"' />\"))    \t);            flyoutDetailsUl.append(                    makeListItem(null, \"flyout-reminder-url\", makeAnchorTag(clientUrl, null, clientName))            );            flyoutDetailsUl.append(    \t\tmakeListItem(null, \"flyout-reminder-text\", displayText)    \t);    \tvar discountButton = \"\";    \t  \t\tdiscountButton = makeAnchorTag(clientUrl, \"flyout-reminder-button\", \"Click and Save\");    \t          flyoutDetailsUl.append(    \t\tmakeListItem(null, null, discountButton)    \t);                        flyoutDetailsDiv.append(flyoutDetailsUl);                    \treturn flyoutDetailsDiv;        }                "}
   ],
   "meta": {
      "description": "\nWorld Wide Market - Dave Stewart   \n",
      "logging": "off",
      "name": "WWM Demo"
   },
   "rules": [
      {
         "actions": [
            {"action": {
               "args": [{
                  "type": "var",
                  "val": "remindMeSelector"
               }],
               "modifiers": [
                  {
                     "name": "remote",
                     "value": {
                        "type": "str",
                        "val": "https://service.azigo.com/remindmeac/fetch?callback=?&jsonData=true&source=wwm&type=regular"
                     }
                  },
                  {
                     "name": "outer_div_css",
                     "value": {
                        "type": "hashraw",
                        "val": [
                           {
                              "lhs": "float",
                              "rhs": {
                                 "type": "str",
                                 "val": "none"
                              }
                           },
                           {
                              "lhs": "margin-left",
                              "rhs": {
                                 "type": "str",
                                 "val": "0px"
                              }
                           },
                           {
                              "lhs": "padding-right",
                              "rhs": {
                                 "type": "str",
                                 "val": "0px"
                              }
                           }
                        ]
                     }
                  },
                  {
                     "name": "inner_div_css",
                     "value": {
                        "type": "hashraw",
                        "val": [
                           {
                              "lhs": "margin-left",
                              "rhs": {
                                 "type": "str",
                                 "val": "0px"
                              }
                           },
                           {
                              "lhs": "padding-right",
                              "rhs": {
                                 "type": "str",
                                 "val": "0px"
                              }
                           },
                           {
                              "lhs": "padding-top",
                              "rhs": {
                                 "type": "str",
                                 "val": "5px"
                              }
                           }
                        ]
                     }
                  },
                  {
                     "name": "li_css",
                     "value": {
                        "type": "hashraw",
                        "val": [
                           {
                              "lhs": "padding-left",
                              "rhs": {
                                 "type": "str",
                                 "val": "0px"
                              }
                           },
                           {
                              "lhs": "white-space",
                              "rhs": {
                                 "type": "str",
                                 "val": "normal"
                              }
                           }
                        ]
                     }
                  },
                  {
                     "name": "placement",
                     "value": {
                        "type": "str",
                        "val": "after"
                     }
                  },
                  {
                     "name": "domains",
                     "value": {
                        "type": "hashraw",
                        "val": [{
                           "lhs": "www.bing.com",
                           "rhs": {
                              "type": "hashraw",
                              "val": [{
                                 "lhs": "modify",
                                 "rhs": {
                                    "type": "str",
                                    "val": ".sa_cc"
                                 }
                              }]
                           }
                        }]
                     }
                  }
               ],
               "name": "annotate_search_results",
               "source": null
            }},
            {"action": {
               "args": [{
                  "type": "var",
                  "val": "remindMeSelector"
               }],
               "modifiers": [
                  {
                     "name": "remote",
                     "value": {
                        "type": "str",
                        "val": "https://service.azigo.com/remindmeac/fetch?callback=?&jsonData=true&source=wwm&type=local"
                     }
                  },
                  {
                     "name": "placement",
                     "value": {
                        "type": "str",
                        "val": "after"
                     }
                  },
                  {
                     "name": "domains",
                     "value": {
                        "type": "hashraw",
                        "val": [{
                           "lhs": "www.bing.com",
                           "rhs": {
                              "type": "hashraw",
                              "val": [{
                                 "lhs": "modify",
                                 "rhs": {
                                    "type": "str",
                                    "val": ".sc_ol1"
                                 }
                              }]
                           }
                        }]
                     }
                  }
               ],
               "name": "annotate_local_search_results",
               "source": null
            }}
         ],
         "blocktype": "every",
         "callbacks": {"success": [{
            "attribute": "class",
            "trigger": null,
            "type": "click",
            "value": "flyout-reminder-button"
         }]},
         "cond": {
            "args": [],
            "function_expr": {
               "type": "var",
               "val": "truth"
            },
            "type": "app"
         },
         "emit": "\n        ",
         "foreach": [],
         "name": "search_reminders",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "^http://www.google.com|^http://www.bing.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [],
         "state": "active"
      },
      {
         "actions": [
            {"action": {
               "args": [{
                  "type": "var",
                  "val": "remindMeSelector"
               }],
               "modifiers": [
                  {
                     "name": "remote",
                     "value": {
                        "type": "str",
                        "val": "https://service.azigo.com/remindmeac/fetch?callback=?&jsonData=true&source=wwm&type=regular"
                     }
                  },
                  {
                     "name": "outer_div_css",
                     "value": {
                        "type": "hashraw",
                        "val": [
                           {
                              "lhs": "float",
                              "rhs": {
                                 "type": "str",
                                 "val": "none"
                              }
                           },
                           {
                              "lhs": "height",
                              "rhs": {
                                 "type": "str",
                                 "val": "40px"
                              }
                           },
                           {
                              "lhs": "margin-left",
                              "rhs": {
                                 "type": "str",
                                 "val": "0px"
                              }
                           },
                           {
                              "lhs": "margin-top",
                              "rhs": {
                                 "type": "str",
                                 "val": "-10px"
                              }
                           },
                           {
                              "lhs": "padding-right",
                              "rhs": {
                                 "type": "str",
                                 "val": "0px"
                              }
                           }
                        ]
                     }
                  },
                  {
                     "name": "inner_div_css",
                     "value": {
                        "type": "hashraw",
                        "val": [
                           {
                              "lhs": "margin-left",
                              "rhs": {
                                 "type": "str",
                                 "val": "0px"
                              }
                           },
                           {
                              "lhs": "padding-right",
                              "rhs": {
                                 "type": "str",
                                 "val": "0px"
                              }
                           }
                        ]
                     }
                  },
                  {
                     "name": "li_css",
                     "value": {
                        "type": "hashraw",
                        "val": [
                           {
                              "lhs": "padding-left",
                              "rhs": {
                                 "type": "str",
                                 "val": "0px"
                              }
                           },
                           {
                              "lhs": "white-space",
                              "rhs": {
                                 "type": "str",
                                 "val": "normal"
                              }
                           }
                        ]
                     }
                  },
                  {
                     "name": "placement",
                     "value": {
                        "type": "str",
                        "val": "after"
                     }
                  },
                  {
                     "name": "domains",
                     "value": {
                        "type": "hashraw",
                        "val": [{
                           "lhs": "search.yahoo.com",
                           "rhs": {
                              "type": "hashraw",
                              "val": [
                                 {
                                    "lhs": "selector",
                                    "rhs": {
                                       "type": "str",
                                       "val": "#web > ol > li"
                                    }
                                 },
                                 {
                                    "lhs": "modify",
                                    "rhs": {
                                       "type": "str",
                                       "val": "div.res"
                                    }
                                 }
                              ]
                           }
                        }]
                     }
                  }
               ],
               "name": "annotate_search_results",
               "source": null
            }},
            {"action": {
               "args": [{
                  "type": "var",
                  "val": "remindMeSelector"
               }],
               "modifiers": [
                  {
                     "name": "remote",
                     "value": {
                        "type": "str",
                        "val": "https://service.azigo.com/remindmeac/fetch?callback=?&jsonData=true&source=wwm&type=local"
                     }
                  },
                  {
                     "name": "placement",
                     "value": {
                        "type": "str",
                        "val": "after"
                     }
                  },
                  {
                     "name": "domains",
                     "value": {
                        "type": "hashraw",
                        "val": [{
                           "lhs": "search.yahoo.com",
                           "rhs": {
                              "type": "hashraw",
                              "val": [{
                                 "lhs": "modify",
                                 "rhs": {
                                    "type": "str",
                                    "val": ".qlmr"
                                 }
                              }]
                           }
                        }]
                     }
                  }
               ],
               "name": "annotate_local_search_results",
               "source": null
            }}
         ],
         "blocktype": "every",
         "callbacks": {"success": [{
            "attribute": "class",
            "trigger": null,
            "type": "click",
            "value": "flyout-reminder-button"
         }]},
         "cond": {
            "args": [],
            "function_expr": {
               "type": "var",
               "val": "truth"
            },
            "type": "app"
         },
         "emit": "\n        ",
         "foreach": [],
         "name": "search_yahoo",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "^http://search.yahoo.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [],
         "state": "active"
      }
   ],
   "ruleset_name": "a82x10"
}
