{
   "dispatch": [{"domain": "example.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": "\ntesting to see if utf-8 characters work     \n",
      "logging": "on",
      "name": "utf-8 test"
   },
   "rules": [{
      "actions": [
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "utf-8 character test"
               },
               {
                  "type": "str",
                  "val": "\u201a¤µ"
               }
            ],
            "modifiers": null,
            "name": "notify",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "utf-8 character url encoded"
               },
               {
                  "type": "str",
                  "val": "%E2%A4%B5"
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
      "name": "notify_test",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x142"
}
