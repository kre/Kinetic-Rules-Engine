{
   "dispatch": [{"domain": "google.com"}],
   "global": [],
   "meta": {
      "logging": "on",
      "name": "farmer test"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "You searched!"
               },
               {
                  "args": [
                     {
                        "type": "str",
                        "val": "Your term is: "
                     },
                     {
                        "type": "var",
                        "val": "myterm"
                     }
                  ],
                  "op": "+",
                  "type": "prim"
               }
            ],
            "modifiers": [{
               "name": "sticky",
               "value": {
                  "type": "bool",
                  "val": "true"
               }
            }],
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
         "name": "newrule",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "www.google.com/search.*(?:&q|\\?q)=([^&]*)",
            "type": "prim_event",
            "vars": ["search_term"]
         }},
         "pre": [{
            "lhs": "myterm",
            "rhs": {
               "type": "var",
               "val": "search_term"
            },
            "type": "expr"
         }],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "You searched!"
               },
               {
                  "args": [
                     {
                        "type": "str",
                        "val": "Your term is: "
                     },
                     {
                        "type": "var",
                        "val": "myterm"
                     }
                  ],
                  "op": "+",
                  "type": "prim"
               }
            ],
            "modifiers": [{
               "name": "sticky",
               "value": {
                  "type": "bool",
                  "val": "true"
               }
            }],
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
         "name": "fail",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "www.google.com/search.*(?:&q|\\?q)=([^&]*)",
            "type": "prim_event",
            "vars": ["search_term"]
         }},
         "state": "active"
      }
   ],
   "ruleset_name": "a60x46"
}
