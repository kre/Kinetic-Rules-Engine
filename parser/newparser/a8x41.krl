{
   "dispatch": [{"domain": "www.baconsalt.com"}],
   "global": [],
   "meta": {
      "author": "Sam",
      "description": " \n    Google Calendar Demo \n  ",
      "keys": {"google": {
         "consumer_key": "sam.curren.ws",
         "consumer_secret": "x1bVodHKXlmenYKraZZO3WAm"
      }},
      "logging": "off",
      "name": "ImpactCal"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [{
               "type": "str",
               "val": "calendar"
            }],
            "modifiers": [
               {
                  "name": "opacity",
                  "value": {
                     "type": "num",
                     "val": 1
                  }
               },
               {
                  "name": "sticky",
                  "value": {
                     "type": "bool",
                     "val": "true"
                  }
               }
            ],
            "name": "authorize",
            "source": "google"
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "auth_app",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*",
            "type": "prim_event",
            "vars": []
         }},
         "post": {
            "cons": [{
               "statement": "last",
               "type": "control"
            }],
            "type": "fired"
         },
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Next Up"
               },
               {
                  "type": "var",
                  "val": "nexttitle"
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
         "name": "calevents",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "future",
               "rhs": {
                  "args": [
                     {
                        "type": "str",
                        "val": "calendar"
                     },
                     {
                        "type": "hashraw",
                        "val": [
                           {
                              "lhs": "feed",
                              "rhs": {
                                 "type": "str",
                                 "val": "event"
                              }
                           },
                           {
                              "lhs": "futureevents",
                              "rhs": {
                                 "type": "str",
                                 "val": "true"
                              }
                           }
                        ]
                     }
                  ],
                  "predicate": "get",
                  "source": "google",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "nexttitle",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..entry[0].title.$t"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "future"
                  },
                  "type": "operator"
               },
               "type": "expr"
            }
         ],
         "state": "active"
      }
   ],
   "ruleset_name": "a8x41"
}
