{
   "dispatch": [{"domain": "appbuilder.kynetx.com"}],
   "global": [],
   "meta": {
      "author": "MikeGrace",
      "description": "\nMaking the in browser AppBuilder better     \n",
      "logging": "off",
      "name": "Power AppBuilder"
   },
   "rules": [{
      "actions": [
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "body"
               },
               {
                  "type": "var",
                  "val": "insert"
               }
            ],
            "modifiers": null,
            "name": "append",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "inserted"
               },
               {
                  "type": "str",
                  "val": "alot"
               }
            ],
            "modifiers": null,
            "name": "notify",
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
      "name": "awesome",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "appbuilder.kynetx.com/apps",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [
         {
            "lhs": "caller",
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
            "lhs": "insert",
            "rhs": " \n<iframe src =\"#{caller}\" width=\"100%\" height=\"300\"><\/iframe>    \n ",
            "type": "here_doc"
         }
      ],
      "state": "active"
   }],
   "ruleset_name": "a60x40"
}
