{
   "dispatch": [
      {"domain": "www.facebook.com"},
      {"domain": "en.wikipedia.org"},
      {"domain": "www.google.com"}
   ],
   "global": [],
   "meta": {
      "author": "Azigo",
      "description": "\nDemo of serving ads     \n",
      "logging": "off",
      "name": "OpenX Demo"
   },
   "rules": [
      {
         "actions": [
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "#home_sponsor_nile"
                  },
                  {
                     "type": "var",
                     "val": "fb_200"
                  }
               ],
               "modifiers": null,
               "name": "prepend",
               "source": null
            }},
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "#ssponsor"
                  },
                  {
                     "type": "var",
                     "val": "fb_148"
                  }
               ],
               "modifiers": null,
               "name": "prepend",
               "source": null
            }}
         ],
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
            "pattern": "http://www.facebook.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "fb_200",
               "rhs": " \n<iframe id=\"a1aca7c2\" src=\"http://ads.ingenistics.com/www/delivery/afr.php?zoneid=2&cb=56\" name=\"a1aca7c2\"  frameborder=\"0\" scrolling=\"no\" width=\"200\" height=\"90\"><a href=\"http://ads.ingenistics.com/www/delivery/ck.php?n=a6e6a1a3&cb=56\" target=\"_blank\"><img src=\"http://ads.ingenistics.com/www/delivery/avw.php?zoneid=2&cb=56&n=a6e6a1a3\" border=\"0\" alt='' /><\/a><\/iframe>     \n ",
               "type": "here_doc"
            },
            {
               "lhs": "fb_148",
               "rhs": " \n\n ",
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
                  "val": "#p-search"
               },
               {
                  "type": "var",
                  "val": "wiki_148"
               }
            ],
            "modifiers": null,
            "name": "before",
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
         "name": "wikipedia",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "en.wikipedia.org/wiki",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "wiki_148",
            "rhs": " \n<div class=\"portlet\">  <h5 lang=\"en\" xml:lang=\"en\"><label>BBB Community Patron<\/label><\/h5>  <div class=\"pBody\">    <iframe id=\"a9a6a768\" name=\"a9a6a768\" src=\"http://ads.ingenistics.com/www/delivery/afr.php?zoneid=6&cb=876\" frameborder=\"0\" scrolling=\"no\" width=\"130\" height=\"60\"><a href=\"http://ads.ingenistics.com/www/delivery/ck.php?n=a6544b17&cb=876\" target=\"_blank\"><img src=\"http://ads.ingenistics.com/www/delivery/avw.php?zoneid=6&cb=876&n=a6544b17\" border=\"0\" alt='' /><\/a><\/iframe>      <\/div>  <\/div>       \n ",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#footer"
               },
               {
                  "type": "var",
                  "val": "google_video"
               }
            ],
            "modifiers": null,
            "name": "prepend",
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
         "name": "google",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "www.google.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "google_video",
            "rhs": " \n<iframe id=\"a6dc800e\" name=\"a6dc800e\" src=\"http://ads.ingenistics.com/www/delivery/afr.php?zoneid=7&cb=435\" frameborder=\"0\" scrolling=\"no\" width=\"480\" height=\"404\"><a href=\"http://ads.ingenistics.com/www/delivery/ck.php?n=a659e604&cb=435\" target=\"_blank\"><img src=\"http://ads.ingenistics.com/www/delivery/avw.php?zoneid=7&cb=435&n=a659e604\" border=\"0\" alt=\"\" /><\/a><\/iframe>    \n ",
            "type": "here_doc"
         }],
         "state": "active"
      }
   ],
   "ruleset_name": "a82x4"
}
