{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "yahoo.com"},
      {"domain": "bing.com"},
      {"domain": "example.com"}
   ],
   "global": [],
   "meta": {
      "description": "\nTesting amazon lookup   \n",
      "logging": "off",
      "name": "Amazon Test"
   },
   "rules": [{
      "actions": [
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Search Engine"
               },
               {
                  "type": "var",
                  "val": "domain"
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
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Searched"
               },
               {
                  "type": "var",
                  "val": "searchterm"
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
         }},
         {"emit": "\nconsole.log(\"====================================\");      console.log(amazon_data);      console.log(\"====================================\");                    "}
      ],
      "blocktype": "every",
      "callbacks": null,
      "cond": {
         "type": "bool",
         "val": "true"
      },
      "emit": null,
      "foreach": [],
      "name": "response_group",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*(bing|google|yahoo?)\\.com.*[\\?,&][p,q]=(.*?)&.*",
         "type": "prim_event",
         "vars": [
            "domain",
            "searchterm"
         ]
      }},
      "pre": [
         {
            "lhs": "amazon_data",
            "rhs": {
               "args": [{
                  "type": "hashraw",
                  "val": [
                     {
                        "lhs": "index",
                        "rhs": {
                           "type": "str",
                           "val": "all"
                        }
                     },
                     {
                        "lhs": "keywords",
                        "rhs": {
                           "type": "var",
                           "val": "searchterm"
                        }
                     },
                     {
                        "lhs": "response_group",
                        "rhs": {
                           "type": "array",
                           "val": [{
                              "type": "str",
                              "val": "Reviews"
                           }]
                        }
                     }
                  ]
               }],
               "predicate": "item_search",
               "source": "amazon",
               "type": "qualified"
            },
            "type": "expr"
         },
         {
            "lhs": "item",
            "rhs": {
               "args": [{
                  "type": "str",
                  "val": "$..Item"
               }],
               "name": "ick",
               "obj": {
                  "type": "var",
                  "val": "amazon_data"
               },
               "type": "operator"
            },
            "type": "expr"
         }
      ],
      "state": "active"
   }],
   "ruleset_name": "a60x168"
}
