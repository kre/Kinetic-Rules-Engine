{
   "dispatch": [{"domain": "google.com"}],
   "global": [],
   "meta": {
      "logging": "off",
      "name": "Test Google notify"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "A friendly note from the computer..."
            },
            {
               "type": "str",
               "val": "Michaela is the most beautiful woman in the whole wide world. This room included."
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
      "name": "google_notify",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "http://google.com",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a64x4"
}
