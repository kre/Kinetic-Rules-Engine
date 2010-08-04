{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "www.google.com"},
      {"domain": "www.kynetx.com"},
      {"domain": "www.baconsalt.com"}
   ],
   "global": [],
   "meta": {"description": "\ntest app \n"},
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "this worked"
            },
            {
               "type": "str",
               "val": "bx worked with fqdn"
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
      "name": "x",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a8x7"
}
