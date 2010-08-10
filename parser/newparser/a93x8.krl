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
      "author": "Cid Dennis",
      "logging": "on",
      "name": "SnowTest"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [],
         "modifiers": null,
         "name": "let_it_snow",
         "source": "snow"
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
      "pre": [],
      "state": "active"
   }],
   "ruleset_name": "a93x8"
}
