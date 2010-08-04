{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "foo.com"}
   ],
   "global": [],
   "meta": {
      "logging": "off",
      "name": "popup"
   },
   "rules": [{
      "actions": [
         {"action": {
            "args": [
               {
                  "type": "num",
                  "val": 250
               },
               {
                  "type": "num",
                  "val": 250
               },
               {
                  "type": "num",
                  "val": 600
               },
               {
                  "type": "num",
                  "val": 600
               },
               {
                  "type": "str",
                  "val": "/foo"
               }
            ],
            "modifiers": null,
            "name": "popup",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Notify"
               },
               {
                  "type": "str",
                  "val": "<div id='KOBJ_notify_after_popup'>KOBJ_notify_after_popup<\/div>"
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
      "name": "popup",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a41x28"
}
