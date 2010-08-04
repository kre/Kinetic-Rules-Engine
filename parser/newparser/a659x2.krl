{
   "dispatch": [{"domain": "www.facebook.com"}],
   "global": [{
      "cachable": {
         "period": "second",
         "value": "1"
      },
      "datatype": "JSON",
      "name": "consoleFeed",
      "source": "http://pipes.yahoo.com/pipes/pipe.run?_id=b772ba4527b1a4cc836d0310122a57dd&_render=json",
      "type": "dataset"
   }],
   "meta": {
      "author": "Mark Mugleston",
      "description": " FT ",
      "logging": "on",
      "name": "Facebook Test"
   },
   "rules": [
      {
         "actions": [{"emit": " \n               if(KOBJ.watching) { } else {\n                 KOBJ.watchDOM(\"#pagelet_eventbox\",function(){\n                   KOBJ.get_application(\"a146x8\").reload();\n                   KOBJ.watching = true;\n                 });\n               }\n               \n               if($K('#FFT_Main').length) { } else {\n                 $K(\"#rightCol\").prepend(message);\n               }\n            "}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "facebook",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "message",
            "rhs": " \n             <div id=\"FFT_Main\" style=\"background:#f0f3f9; padding: 1px; margin: 0 0 15px 0;\">\n                <div id=\"FFT_Banner_Small\" style=\"padding: 0px; margin: 10px 10px 15px 10px;\">\n                  <img width=\"229\" height=\"46\" src=\"http://www.invisusdirect.com/brent/banner_small.png\" border=\"0\" />\n                <\/div>\n        \t\t      <div id=\"FFT_RecentVideos\" style=\"padding: 0px; margin: 10px 10px 15px 10px;\">\n        \t\t        <div style=\"border-bottom: 1px solid #CCC; width: 100%; font-weight: bold; padding-bottom: 3px;\">Money Tips & Tricks<\/div>\n        \t\t        <div id=\"recentvideos_list\" style=\"border-top: 1px solid #CCC;><\/div>\n        \t\t      <\/div> \n        \t\t      <div id=\"FFT_RecentBlogs\" style=\"padding: 0px; margin: 10px 10px 15px 10px;\"><b>Garretts Tweets<\/b>\n        \t\t        <div id=\"recentblogs_list\">  <\/div>\n        \t\t      <\/div> \n        \t\t      <div id=\"FFT_Recentpromotions\" style=\"padding: 0px; margin: 10px 10px 15px 10px;\"><b>FastTrack Deals<\/b>\n        \t\t        <div id=\"recentpromotions_list\">  <\/div>\n        \t\t      <\/div> \n        \t\t    <\/div>\n            ",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#recentvideos_list"
               },
               {
                  "type": "str",
                  "val": ""
               }
            ],
            "modifiers": null,
            "name": "replace_inner",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "clear_populate_videos",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#recentvideos_list"
               },
               {
                  "type": "var",
                  "val": "div"
               }
            ],
            "modifiers": null,
            "name": "append",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "populate_videos",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "div",
            "rhs": " <div style='margin:2px;' align='center'>\n                      <object width=\"210\" height=\"140\">\n\t\t\t\t<param name=\"movie\" value=\"http://www.youtube.com/v/uVye35oTvHc&hl=en_US&fs=1&\"><\/param>\n\t\t\t\t<param name=\"allowFullScreen\" value=\"true\"><\/param><param name=\"allowscriptaccess\" value=\"always\"><\/param>\n\t\t\t\t<embed src=\"http://www.youtube.com/v/uVye35oTvHc&hl=en_US&fs=1&\" type=\"application/x-shockwave-flash\" allowscriptaccess=\"always\" allowfullscreen=\"true\" width=\"210\" height=\"140\"><\/embed>\n\t\t\t<\/object>\n                  <\/div>\n                ",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#recenttweets_list"
               },
               {
                  "type": "str",
                  "val": ""
               }
            ],
            "modifiers": null,
            "name": "replace_inner",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "clear_populate_blogs",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#recenttweets_list"
               },
               {
                  "type": "var",
                  "val": "div"
               }
            ],
            "modifiers": null,
            "name": "append",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "populate_blogs",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "tweets",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "?a"
                  }],
                  "predicate": "tweets",
                  "source": "datasource",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "res",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.[0]..text"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "tweets"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "img",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.[0]..profile_image_url"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "tweets"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "user",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.[0]..screen_name"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "tweets"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "rssFeed",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..items[0]"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "consoleFeed"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "div",
               "rhs": " <div style='margin:2px' align='center'>\n                        <a href=\"#{rssFeed.link}\" class=\"KOBJ_fb_console\" target=\"_blank\">#{rssFeed[\"y:title\"]}<\/a>\n                     <\/div>\n                ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#recentpromotions_list"
               },
               {
                  "type": "str",
                  "val": ""
               }
            ],
            "modifiers": null,
            "name": "replace_inner",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "clear_populate_photos",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#recentpromotions_list"
               },
               {
                  "type": "var",
                  "val": "div"
               }
            ],
            "modifiers": null,
            "name": "append",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "populate_photos",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "div",
            "rhs": " <div style='margin:2px;' aligh='left'>\n                        <div style=\"margin: 7px 0px 0px 0px;\" align=\"left\">Like Breaking Rules? Then<a href=\"http:\\/\\/www.nightingale.com/accountpages/shoppingcart.aspx?add=25820cdd&promo=INTAF387A1/\" id=\"promo\" target=\"_blank\">\u201aÄúThe New Rules to Get Rich\u201aÄù<\/a> are for you! $1 gets you the entire video series. Spend $1 Now & break some rules!<\/div>\n                        <div style=\"margin: 10px 0px 0px 0px; font-weight: bold; font-size: 1.1em;\" align=\"center\">Call now to purchase!<br> 1 (800) 345-6789<br>or <a href=\"http:\\/\\/www.nightingale.com/accountpages/shoppingcart.aspx?add=25820cdd&promo=INTAF387A1/\" id=\"promo\" target=\"_blank\">Buy Online!<\/a><\/div>\n\t\t\t                     <div align=\"center\" style=\"margin: 15px 0 0 0;\"><a href=\"http:\\/\\/www.freedomfasttrack.com/\" target=\"blank\"><img src=\"http://www.mashworx.com/clients/freedom/FFT_BRAND-blue.png\" style=\"padding: 0px 0px; margin: 0px;\"><a href=\"http:\\/\\/www.mashworx.com/\" target=\"_blank\"><img src=\"http://www.mashworx.com/images/logo-mashworx-white-icon.png\" style=\"padding: 0 0 0 10px; margin: 0px;\"><\/a>\n\t\t\t<\/div>                        \n                     <\/div>\n                ",
            "type": "here_doc"
         }],
         "state": "active"
      }
   ],
   "ruleset_name": "a659x2"
}
