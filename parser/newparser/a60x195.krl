{
   "dispatch": [{"domain": "example.com"}],
   "global": [{
      "lhs": "latestNews",
      "rhs": {
         "type": "array",
         "val": [
            {
               "type": "hashraw",
               "val": [
                  {
                     "lhs": "title",
                     "rhs": {
                        "type": "str",
                        "val": "Mike Grace breaks 1,000 points!"
                     }
                  },
                  {
                     "lhs": "link",
                     "rhs": {
                        "type": "str",
                        "val": "http://geek.michaelgrace.org/"
                     }
                  }
               ]
            },
            {
               "type": "hashraw",
               "val": [
                  {
                     "lhs": "title",
                     "rhs": {
                        "type": "str",
                        "val": "Phil Windley shows off dialoguing at Impact"
                     }
                  },
                  {
                     "lhs": "link",
                     "rhs": {
                        "type": "str",
                        "val": "http://kynetx.com/"
                     }
                  }
               ]
            },
            {
               "type": "hashraw",
               "val": [
                  {
                     "lhs": "title",
                     "rhs": {
                        "type": "str",
                        "val": "Developers get awesome answers on Devex"
                     }
                  },
                  {
                     "lhs": "link",
                     "rhs": {
                        "type": "str",
                        "val": "http://devex.kynetx.com/"
                     }
                  }
               ]
            }
         ]
      },
      "type": "expr"
   }],
   "meta": {
      "author": "Mike Grace",
      "description": " \n    For devex question \n  ",
      "logging": "on",
      "name": "Append to notify"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Breaking news!"
               },
               {
                  "type": "var",
                  "val": "newsDiv"
               }
            ],
            "modifiers": null,
            "name": "notify",
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
         "name": "setup_notify",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://example.com/",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "newsDiv",
            "rhs": "\n      <div id=\"breaking-news\"><\/div>\n    ",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [{"emit": "\n        $K(\"#breaking-news\").append(newsItem);\n      "}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [[{
            "expr": {
               "type": "var",
               "val": "latestNews"
            },
            "var": ["item"]
         }]],
         "name": "loopty_loop",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://example.com/",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "title",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.title"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "item"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "link",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.link"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "item"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "newsItem",
               "rhs": "\n        <p><a href=\"#{link}\">#{title}<\/a><\/p>\n      ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      }
   ],
   "ruleset_name": "a60x195"
}
