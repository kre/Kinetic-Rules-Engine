{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "bing.com"},
      {"domain": "yahoo.com"},
      {"domain": "cnn.com"},
      {"domain": "facebook.com"},
      {"domain": "google.co.uk"},
      {"domain": "google.com.pk"},
      {"domain": "msn.com"}
   ],
   "global": [],
   "meta": {
      "logging": "off",
      "name": "Side Tab"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [],
         "modifiers": [{
            "name": "message",
            "value": {
               "type": "str",
               "val": "HI!!! this is a test of the side<br> nav I am<br> not sure<br> what to do here <br>so I guess<br> Iw ill just do"
            }
         }],
         "name": "sidetab",
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
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a41x103"
}
