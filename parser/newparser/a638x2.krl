{
   "dispatch": [{"domain": "autotrader.com"}],
   "global": [],
   "meta": {
      "author": "Bart Elison",
      "description": "\n      search annotation on autotrader.com     \n    ",
      "logging": "on",
      "name": "autotrader search"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [],
            "modifiers": [
               {
                  "name": "message",
                  "value": {
                     "type": "var",
                     "val": "slideoutMessage"
                  }
               },
               {
                  "name": "backgroundColor",
                  "value": {
                     "type": "str",
                     "val": "white"
                  }
               },
               {
                  "name": "pathToTabImage",
                  "value": {
                     "type": "str",
                     "val": "http://master.moneydesktop.com/images/browser_tools/tab_noarrow.png"
                  }
               },
               {
                  "name": "tabColor",
                  "value": {
                     "type": "str",
                     "val": "transparent"
                  }
               },
               {
                  "name": "imageHeight",
                  "value": {
                     "type": "str",
                     "val": "168px"
                  }
               },
               {
                  "name": "imageWidth",
                  "value": {
                     "type": "str",
                     "val": "41px"
                  }
               },
               {
                  "name": "width",
                  "value": {
                     "type": "str",
                     "val": "310px"
                  }
               },
               {
                  "name": "height",
                  "value": {
                     "type": "str",
                     "val": "180px"
                  }
               }
            ],
            "name": "sidetab",
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
         "name": "sideTabRule",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "slideoutMessage",
            "rhs": "\n          <div style='height:168px;'>\n            <h1>Login<\/h1>\n            username: <input type='text'/><br/>\n            password: <input type='text'/><br/>\n          <\/div>\n        ",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [
            {"emit": "\n          function my_super_selector(obj) {\n            var match = $K(obj).find(\".listing-title\").text().match(/2009/gi);\n            if(match) {\n              return \"<h2>Get Financing From MD!<\/h2>\";\n            } else {\n              return false;\n            }\n          }\n      "},
            {"action": {
               "args": [{
                  "type": "var",
                  "val": "my_super_selector"
               }],
               "modifiers": [{
                  "name": "domains",
                  "value": {
                     "type": "hashraw",
                     "val": [{
                        "lhs": "www.autotrader.com",
                        "rhs": {
                           "type": "hashraw",
                           "val": [
                              {
                                 "lhs": "selector",
                                 "rhs": {
                                    "type": "str",
                                    "val": ".search-result"
                                 }
                              },
                              {
                                 "lhs": "modify",
                                 "rhs": {
                                    "type": "str",
                                    "val": ".ad-description"
                                 }
                              },
                              {
                                 "lhs": "watcher",
                                 "rhs": {
                                    "type": "str",
                                    "val": ""
                                 }
                              },
                              {
                                 "lhs": "urlsel",
                                 "rhs": {
                                    "type": "str",
                                    "val": ".listing-title"
                                 }
                              }
                           ]
                        }
                     }]
                  }
               }],
               "name": "annotate_search_results",
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
         "name": "custom_search_annotation",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "/fyc/searchresults.jsp",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      }
   ],
   "ruleset_name": "a638x2"
}
