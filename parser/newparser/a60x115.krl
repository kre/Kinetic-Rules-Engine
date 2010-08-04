{
   "dispatch": [{"domain": "sidereel.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": "\nMaking sidereel better and cleaner    \n",
      "logging": "on",
      "name": "Sidereel"
   },
   "rules": [{
      "actions": [
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "div#fauxMain"
               },
               {
                  "type": "str",
                  "val": ""
               }
            ],
            "modifiers": null,
            "name": "replace",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "div#fauxSidebar"
               },
               {
                  "type": "str",
                  "val": ""
               }
            ],
            "modifiers": null,
            "name": "replace",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "iframe"
               },
               {
                  "type": "str",
                  "val": ""
               }
            ],
            "modifiers": null,
            "name": "replace",
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
      "name": "ad_stripper",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x115"
}
