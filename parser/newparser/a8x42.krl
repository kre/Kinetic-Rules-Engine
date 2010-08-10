{
   "dispatch": [],
   "global": [
      {
         "cachable": {
            "period": "second",
            "value": "1"
         },
         "datatype": "JSON",
         "name": "maps",
         "source": "http://fmm.kynetx.com/lookup/",
         "type": "datasource"
      },
      {
         "lhs": "fullurl",
         "rhs": {
            "args": [{
               "type": "str",
               "val": "caller"
            }],
            "predicate": "env",
            "source": "page",
            "type": "qualified"
         },
         "type": "expr"
      },
      {
         "lhs": "d",
         "rhs": {
            "args": [{
               "type": "str",
               "val": "domain"
            }],
            "predicate": "url",
            "source": "page",
            "type": "qualified"
         },
         "type": "expr"
      },
      {
         "lhs": "maps",
         "rhs": {
            "args": [{
               "args": [{
                  "type": "str",
                  "val": "domain"
               }],
               "predicate": "url",
               "source": "page",
               "type": "qualified"
            }],
            "predicate": "maps",
            "source": "datasource",
            "type": "qualified"
         },
         "type": "expr"
      },
      {
         "content": "\n    #KOBJDetailBox {\n      background-color: white;\n      padding: 4px;\n      color: black;\n    }\n  ",
         "type": "css"
      }
   ],
   "meta": {
      "author": "Sam Curren",
      "description": " \n    Shows maps that exist for the current domain \n  ",
      "logging": "on",
      "name": "FormFill Inspector"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Maps for #{d}"
               },
               {
                  "type": "var",
                  "val": "detailbox"
               }
            ],
            "modifiers": [
               {
                  "name": "sticky",
                  "value": {
                     "type": "bool",
                     "val": "true"
                  }
               },
               {
                  "name": "width",
                  "value": {
                     "type": "str",
                     "val": "500"
                  }
               }
            ],
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
         "name": "lookupmaps",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "detailbox",
            "rhs": "\n      <div id=\"KOBJDetailBox\">\n        <b>Maps<\/b><br/>\n      <\/div>\n    ",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#KOBJDetailBox"
               },
               {
                  "type": "str",
                  "val": "#{regexstring}<br/> "
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
         "foreach": [[{
            "expr": {
               "type": "var",
               "val": "maps"
            },
            "var": ["map"]
         }]],
         "name": "listmaps",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "regexstring",
            "rhs": {
               "args": [{
                  "type": "str",
                  "val": "$.regex"
               }],
               "name": "ick",
               "obj": {
                  "type": "var",
                  "val": "map"
               },
               "type": "operator"
            },
            "type": "expr"
         }],
         "state": "active"
      },
      {
         "actions": null,
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
               "val": "maps"
            },
            "var": ["map"]
         }]],
         "name": "showmatchingmap",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      }
   ],
   "ruleset_name": "a8x42"
}
