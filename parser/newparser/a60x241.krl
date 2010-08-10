{
   "dispatch": [{"domain": "google.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": "\n      for webinar\n    ",
      "logging": "on",
      "name": "Kynetx app demo"
   },
   "rules": [{
      "actions": [
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Hello Kynetx"
               },
               {
                  "type": "str",
                  "val": "I'm an app"
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
                  "val": "Hello again"
               },
               {
                  "type": "str",
                  "val": "I waited to show"
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 2
               }
            }],
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
      "name": "first_rule",
      "pagetype": {
         "event_expr": {
            "domain": "web",
            "op": "pageview",
            "pattern": ".*",
            "type": "prim_event",
            "vars": []
         },
         "foreach": []
      },
      "state": "active"
   }],
   "ruleset_name": "a60x241"
}
