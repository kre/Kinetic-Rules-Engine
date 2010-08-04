{
   "dispatch": [
      {"domain": "luxor.com"},
      {"domain": "google.com"}
   ],
   "global": [{"emit": "\nalert (\"Global rule fired\");                    "}],
   "meta": {
      "description": "\ntest why things are not working on luxor.com    \n",
      "logging": "off",
      "name": "Luxor test"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "Rule 1"
            },
            {
               "type": "str",
               "val": "It actually fired!"
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
      "name": "rule_1",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "com",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a82x5"
}
